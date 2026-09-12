// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:princesses/home/domain/notifications_services.dart';

// class BookingNotificationHelper {
//   static String normalizeCityKey(String rawCity) {
//     final clean = rawCity.trim().toLowerCase();
//     switch (clean) {
//       case 'إدلب':
//       case 'ادلب':
//       case 'idleb':
//       case 'idlib':
//         return 'idleb';
//       case 'حلب':
//       case 'aleppo':
//         return 'aleppo';
//       case 'حمص':
//       case 'homs':
//         return 'homs';
//       case 'دمشق':
//       case 'damascus':
//         return 'damascus';
//       default:
//         return clean.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
//     }
//   }

//   static Future<void> notifyAllStakeholders({
//     required String currentUserId,
//     String? assignedUserId,
//     required String bookingTitle,
//     required String bookingDetails,
//     required bool isCreatedByAdmin,
//     required String city,
//   }) async {
//     final String cityKey = normalizeCityKey(city);

//     // 1. إرسال لجميع المدراء عبر FCM Topic
//     await NotificationService.sendFcmNotification(
//       target: '/topics/admins',
//       title: isCreatedByAdmin ? 'حجز جديد (من الأدمن)' : 'حجز جديد',
//       body: '$bookingTitle - $bookingDetails',
//     );

//     // 2. إرسال لموظفي المدينة المحددة عبر FCM Topic
//     if (cityKey.isNotEmpty) {
//       await NotificationService.sendFcmNotification(
//         target: '/topics/city_$cityKey',
//         title: 'حجز جديد في $city',
//         body: '$bookingTitle - $bookingDetails',
//       );
//     }

//     // 3. إرسال إشعار مباشر عبر Token للموظف المسند إليه
//     if (assignedUserId != null &&
//         assignedUserId.isNotEmpty &&
//         assignedUserId != currentUserId) {
//       try {
//         final userDoc = await FirebaseFirestore.instance
//             .collection('appUsers')
//             .doc(assignedUserId)
//             .get();

//         final token = userDoc.data()?['fcmToken'] as String?;
//         if (token != null && token.isNotEmpty) {
//           await NotificationService.sendFcmNotification(
//             target: token,
//             title: 'حجز جديد مُسند إليك',
//             body: '$bookingTitle - $bookingDetails',
//           );
//         }
//       } catch (e) {
//         debugPrint('خطأ أثناء جلب FCM Token للمستخدم $assignedUserId: $e');
//       }
//     }
//   }

//   static Future<void> sendNotificationToAllUsers({
//     required String title,
//     required String body,
//     required String bookingCity,
//     required DateTime appointmentDate,
//   }) async {
//     final firestore = FirebaseFirestore.instance;

//     try {
//       final usersSnapshot = await firestore.collection('appUsers').get();

//       if (usersSnapshot.docs.isEmpty) return;

//       final batch = firestore.batch();
//       int count = 0;

//       final cleanBookingCity = _normalizeCityKey(bookingCity);

//       for (var userDoc in usersSnapshot.docs) {
//         final userData = userDoc.data();

//         final userCity = userData['city']?.toString() ?? '';
//         final isAdmin =
//             userData['isAdmin'] == true || userData['isAdmin'] == 'true';

//         final cleanUserCity = _normalizeCityKey(userCity);

//         // الشرط المطلوبة: يصل الإشعار إذا كان المستخدم أدمن OR ينتمي لنفس مدينة الحجز
//         if (isAdmin ||
//             (cleanUserCity.isNotEmpty && cleanUserCity == cleanBookingCity)) {
//           final notificationRef = userDoc.reference
//               .collection('notifications')
//               .doc();

//           batch.set(notificationRef, {
//             'title': title,
//             'body': body,
//             'createdAt': FieldValue.serverTimestamp(),
//             'appointmentDate': Timestamp.fromDate(
//               appointmentDate,
//             ), // تاريخ الموعد الفعلي المختار
//             'read': false,
//             'bookingCity': bookingCity,
//           });

//           count++;
//         }
//       }

//       if (count > 0) {
//         await batch.commit();
//       }
//     } catch (e) {
//       debugPrint("خطأ أثناء كتابة الإشعارات في Firestore: $e");
//     }
//   }

//   static String _normalizeCityKey(String city) {
//     if (city.isEmpty) return '';

//     String normalized = city.trim().toLowerCase();
//     normalized = normalized
//         .replaceAll(RegExp(r'[أإآ]'), 'ا')
//         .replaceAll('ة', 'ه')
//         .replaceAll('ى', 'ي');

//     return normalized;
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:princesses/home/domain/notifications_services.dart';

class BookingNotificationHelper {
  static String normalizeCityKey(String rawCity) {
    final clean = rawCity.trim().toLowerCase();
    switch (clean) {
      case 'إدلب':
      case 'ادلب':
      case 'idleb':
      case 'idlib':
        return 'idleb';
      case 'حلب':
      case 'aleppo':
        return 'aleppo';
      case 'حمص':
      case 'homs':
        return 'homs';
      case 'دمشق':
      case 'damascus':
        return 'damascus';
      default:
        return clean.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    }
  }

  static Future<void> notifyAllStakeholders({
    required String currentUserId,
    String? assignedUserId,
    required String bookingTitle,
    required String bookingDetails,
    required bool isCreatedByAdmin,
    required String city,
    required String partyId,
    required DateTime appointmentDate,
    required String place,
  }) async {
    final String cityKey = normalizeCityKey(city);

    // بناء الـ Data Payload ليصل لجميع الأجهزة وتجدول التذكير محلياً
    final Map<String, dynamic> customData = {
      'partyId': partyId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'place': place,
      'title': bookingTitle,
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    };

    // 1. إرسال لجميع المدراء عبر FCM Topic
    await NotificationService.sendFcmNotification(
      target: '/topics/admins',
      title: isCreatedByAdmin ? 'حجز جديد (من الأدمن)' : 'حجز جديد',
      body: '$bookingTitle - $bookingDetails',
      data: customData,
    );

    // 2. إرسال لموظفي المدينة المحددة عبر FCM Topic
    if (cityKey.isNotEmpty) {
      await NotificationService.sendFcmNotification(
        target: '/topics/city_$cityKey',
        title: 'حجز جديد في $city',
        body: '$bookingTitle - $bookingDetails',
        data: customData,
      );
    }

    // 3. إرسال إشعار مباشر عبر Token للموظف المسند إليه
    if (assignedUserId != null &&
        assignedUserId.isNotEmpty &&
        assignedUserId != currentUserId) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('appUsers')
            .doc(assignedUserId)
            .get();

        final token = userDoc.data()?['fcmToken'] as String?;
        if (token != null && token.isNotEmpty) {
          await NotificationService.sendFcmNotification(
            target: token,
            title: 'حجز جديد مُسند إليك',
            body: '$bookingTitle - $bookingDetails',
            data: customData,
          );
        }
      } catch (e) {
        debugPrint('خطأ أثناء جلب FCM Token للمستخدم $assignedUserId: $e');
      }
    }
  }

  static Future<void> sendNotificationToAllUsers({
    required String title,
    required String body,
    required String bookingCity,
    required DateTime appointmentDate,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final usersSnapshot = await firestore.collection('appUsers').get();

      if (usersSnapshot.docs.isEmpty) return;

      final batch = firestore.batch();
      int count = 0;

      final cleanBookingCity = _normalizeCityKey(bookingCity);

      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();

        final userCity = userData['city']?.toString() ?? '';
        final isAdmin =
            userData['isAdmin'] == true || userData['isAdmin'] == 'true';

        final cleanUserCity = normalizeCityKey(userCity);
        // final cleanUserCity = normalizeCityKey(userCity);
        if (isAdmin ||
            (cleanUserCity.isNotEmpty && cleanUserCity == cleanBookingCity)) {
          final notificationRef = userDoc.reference
              .collection('notifications')
              .doc();

          batch.set(notificationRef, {
            'title': title,
            'body': body,
            'createdAt': FieldValue.serverTimestamp(),
            'appointmentDate': Timestamp.fromDate(appointmentDate),
            'read': false,
            'bookingCity': bookingCity,
          });

          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint("خطأ أثناء كتابة الإشعارات في Firestore: $e");
    }
  }

  static String _normalizeCityKey(String city) {
    if (city.isEmpty) return '';

    String normalized = city.trim().toLowerCase();
    normalized = normalized
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');

    return normalized;
  }
}
