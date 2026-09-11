import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class BookingNotificationHelper {
  /// توليد Access Token ديناميكي من ملف الخدمة
  static Future<String?> _getAccessToken() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/service_account.json',
      );
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final credentials = ServiceAccountCredentials.fromJson(jsonMap);

      final client = await clientViaServiceAccount(credentials, scopes);
      final accessToken = client.credentials.accessToken.data;

      client.close();
      return accessToken;
    } catch (e) {
      print('خطأ في استخراج Access Token: $e');
      return null;
    }
  }

  /// دالة إرسال طلب FCM مباشرة معتمدة على HTTP v1 API
  static Future<void> sendFcmNotification({
    required String target,
    required String title,
    required String body,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        print('تعذر الحصول على Token الإرسال');
        return;
      }

      // جلب معرف المشروع تلقائياً من ملف JSON
      final jsonString = await rootBundle.loadString(
        'assets/json/service_account.json',
      );
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final String projectId = jsonMap['project_id'];

      final Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      // تجهيز هيكل البيانات القياسي لـ HTTP v1
      final Map<String, dynamic> payload = {
        'message': {
          if (target.startsWith('/topics/'))
            'topic': target.replaceAll('/topics/', '')
          else
            'token': target,
          'notification': {'title': title, 'body': body},
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': 'party_channel_v4',
              'sound': 'default',
            },
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
          },
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        print('FCM Send Error: ${response.body}');
      } else {
        print('تم إرسال الإشعار بنجاح لـ: $target');
      }
    } catch (e) {
      print('Exception in sendFcmNotification: $e');
    }
  }

  /// دالة إشعارات جميع المعنيين بالحجز
  static Future<void> notifyAllStakeholders({
    required String currentUserId,
    String assignedUserId = "", // تجعله اختياري بحال لم تضعيه
    required String bookingTitle,
    required String bookingDetails,
    required bool isCreatedByAdmin,
    required String city,
  }) async {
    final String cleanCity = city.trim().toLowerCase();

    // 1. إرسال إلى موضوع المدراء
    await sendFcmNotification(
      target: "/topics/admins",
      title: "تحديث حجز: $bookingTitle",
      body: bookingDetails,
    );

    // 2. إرسال إلى موضوع المدينة
    if (cleanCity.isNotEmpty) {
      await sendFcmNotification(
        target: "/topics/city_$cleanCity",
        title: "حجز جديد في $city",
        body: "$bookingTitle - $bookingDetails",
      );
    }

    // 3. إرسال إشعار مباشر للشخص المسند إليه الحجز (فقط إذا تم تمريره)
    if (assignedUserId.isNotEmpty) {
      final userDoc = await FirebaseFirestore.instance
          .collection('appUsers')
          .doc(assignedUserId)
          .get();

      final token = userDoc.data()?['fcmToken'];
      if (token != null && token.toString().isNotEmpty) {
        await sendFcmNotification(
          target: token.toString(),
          title: "حجز جديد/مُسند إليك",
          body: "$bookingTitle: $bookingDetails",
        );
      }
    }
  }
}
