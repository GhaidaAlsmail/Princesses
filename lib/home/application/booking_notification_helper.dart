import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:princesses/home/domain/notifications_services.dart';

class BookingNotificationHelper {
  /// تحويل اسم المدينة لرمز مفتاح نظيف وموحد للـ Topics
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
        // تنظيف الأحرف الخاصة والمسافات مع مراعاة اللغة الإنكليزية إن وجدت
        return clean.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    }
  }

  /// إرسال الإشعارات لجميع الأطراف المعنية بالحجز
  static Future<void> notifyAllStakeholders({
    required String currentUserId,
    String? assignedUserId,
    required String bookingTitle,
    required String bookingDetails,
    required bool isCreatedByAdmin,
    required String city,
  }) async {
    final String cityKey = normalizeCityKey(city);

    // 1. إرسال إشعار لكافة المدراء (Admins Topic)
    await NotificationService.sendFcmNotification(
      target: '/topics/admins',
      title: isCreatedByAdmin ? 'حجز جديد (من الأدمن)' : 'حجز جديد',
      body: '$bookingTitle - $bookingDetails',
    );

    // 2. إرسال إشعار لموظفي هذه المدينة تحديداً (City Topic)
    if (cityKey.isNotEmpty) {
      await NotificationService.sendFcmNotification(
        target: '/topics/city_$cityKey',
        title: 'حجز جديد في $city',
        body: '$bookingTitle - $bookingDetails',
      );
    }

    // 3. إرسال إشعار مباشر عبر التوكن للموظف المُسند إليه الحجز (إن وجد)
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
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final usersSnapshot = await firestore.collection('appUsers').get();

      if (usersSnapshot.docs.isEmpty) {
        debugPrint("لم يتم العثور على أي مستخدمين في appUsers");
        return;
      }

      final batch = firestore.batch();
      int count = 0;

      final cleanBookingCity = _normalizeCityKey(bookingCity);

      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();

        // التحقق من القيم مع التعامل مع احتمالية كليبات البيانات المختلطة
        final userCity = userData['city']?.toString() ?? '';
        final isAdmin =
            userData['isAdmin'] == true || userData['isAdmin'] == 'true';

        final cleanUserCity = _normalizeCityKey(userCity);

        // الشرط: إما أدمن (يستلم الكل) أو من نفس المدينة (يستلم إشعارات مدينته فقط)
        if (isAdmin ||
            (cleanUserCity.isNotEmpty && cleanUserCity == cleanBookingCity)) {
          final notificationRef = userDoc.reference
              .collection('notifications')
              .doc();

          batch.set(notificationRef, {
            'title': title,
            'body': body,
            'createdAt': FieldValue.serverTimestamp(),
            'read': false,
            'bookingCity': bookingCity,
          });

          count++;
          debugPrint(
            "تم تضمين المستخدم: ${userDoc.id} | أدمن: $isAdmin | المدينة: $userCity",
          );
        } else {
          debugPrint(
            "تم استبعاد المستخدم: ${userDoc.id} | المدينة: $userCity لا تطابق $bookingCity",
          );
        }
      }

      if (count > 0) {
        await batch.commit();
        debugPrint("تم إرسال الإشعار بنجاح إلى $count مستخدم في Firestore");
      } else {
        debugPrint("لم يطابق أي مستخدم الشروط المطلوبة إطلاقاً!");
      }
    } catch (e) {
      debugPrint("خطأ أثناء كتابة الإشعارات في Firestore: $e");
    }
  }

  // دالة تنظيف ومطابقة المدن (تتعامل مع العربية والإنكليزية والمسافات)
  static String _normalizeCityKey(String city) {
    if (city.isEmpty) return '';

    String normalized = city.trim().toLowerCase();

    // توحيد الأحرف العربية الأكثر عرضة للأخطاء
    normalized = normalized
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');

    return normalized;
  }
}
