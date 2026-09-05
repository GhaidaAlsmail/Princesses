import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingNotificationHelper {
  /// دالة تُستدعى فور إنشاء أو تعديل الحجز لإرسال الإشعار للشخص المناسب
  static Future<void> onNewBookingCreated({
    required String assignedUserId, // ID الموظف/الشخص المسند له الحجز
    required String bookingTitle,
    required String bookingDetails,
    required bool isCreatedByAdmin, // هل قام أدمن بإنشاء الحجز؟
    required String city, // 👈 تم إضافة معلمة المدينة
  }) async {
    // توحيد اسم المدينة للحروف الصغيرة لتفادي مشاكل المطابقة (مثل homs)
    final String cleanCity = city.trim().toLowerCase();

    // 1. جلب Token الشخص المسند له الحجز من مجموعتك appUsers
    String? assignedUserFcmToken;
    if (assignedUserId.isNotEmpty) {
      final userDoc = await FirebaseFirestore.instance
          .collection('appUsers')
          .doc(assignedUserId)
          .get();
      assignedUserFcmToken = userDoc.data()?['fcmToken'];
    }

    // 2. إذا كان الحجز تم بواسطة الأدمن
    if (isCreatedByAdmin) {
      // إرسال إشعار للموظف/الشخص المسؤول عن الحجز (إن وجد)
      if (assignedUserFcmToken != null && assignedUserFcmToken.isNotEmpty) {
        await _sendFcmNotification(
          target: assignedUserFcmToken,
          title: "حجز جديد مُسند إليك",
          body: "قام المدير بإضافة حجز جديد باسمك: $bookingTitle",
        );
      }

      // إرسال إشعار لموظفي المدينة المعنية عبر Topic
      if (cleanCity.isNotEmpty) {
        await _sendFcmNotification(
          target: "/topics/city_$cleanCity",
          title: "حجز جديد في منطقتك",
          body: "تم إضافة حجز جديد في $city: $bookingTitle",
        );
      }

      // إرسال إشعار لبقية المدراء عبر Topic
      await _sendFcmNotification(
        target: "/topics/admins",
        title: "تم إضافة حجز بواسطة مدير",
        body: "تم إنشاء حجز جديد في $city: $bookingTitle",
      );
    }
    // 3. إذا كان الحجز تم بواسطة موظف / زبون
    else {
      // إرسال إشعار لجميع المدراء
      await _sendFcmNotification(
        target: "/topics/admins",
        title: "حجز جديد من موظف/زبون",
        body: "تم إضافة حجز جديد في $city: $bookingTitle",
      );

      // إرسال إشعار لموظفي المدينة المعنية عبر Topic
      if (cleanCity.isNotEmpty) {
        await _sendFcmNotification(
          target: "/topics/city_$cleanCity",
          title: "حجز جديد في منطقتك",
          body: "تم إضافة حجز جديد في $city: $bookingTitle",
        );
      }

      // إرسال إشعار تأكيد للموظف/الزبون نفسه
      if (assignedUserFcmToken != null && assignedUserFcmToken.isNotEmpty) {
        await _sendFcmNotification(
          target: assignedUserFcmToken,
          title: "تم استلام حجزك بنجاح",
          body: "تأكيد حجز: $bookingTitle",
        );
      }
    }
  }

  /// إرسال طلب HTTP إلى FCM Legacy HTTP API
  static Future<void> _sendFcmNotification({
    required String target,
    required String title,
    required String body,
  }) async {
    const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
    // ضعي مفتاح الـ Server Key الخاص بمشروعكِ من Firebase Console
    const String serverKey = 'YOUR_FIREBASE_SERVER_KEY';

    try {
      await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': target,
          'notification': {'title': title, 'body': body, 'sound': 'default'},
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'title': title,
            'body': body,
          },
        }),
      );
    } catch (e) {
      debugPrint("خطأ أثناء إرسال الإشعار عبر FCM: $e");
    }
  }
}
