// // ignore_for_file: use_build_context_synchronously, avoid_print

// import 'dart:convert';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:princesses/core/global_navigator.dart';
// import 'package:princesses/home/application/notification_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/data/latest.dart' as tz_data;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:googleapis_auth/auth_io.dart' as auth;

// /// Notification Service for party/event reminders
// @pragma('vm:entry-point')
// class NotificationService {
//   // Singleton
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   static const String channelId = "party_channel_v4";
//   static const String channelName = "Party Reminders";
//   static const String _storagePrefix = "alarm_";

//   // مفتاح السيرفر الخاص بـ Firebase FCM (يمكنك استبداله بالسيرفر كي الخاص بك)

//   Future<void> init() async {
//     tz_data.initializeTimeZones();
//     await AndroidAlarmManager.initialize();

//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//     const iosSettings = DarwinInitializationSettings(
//       defaultPresentAlert: true,
//       defaultPresentSound: true,
//       defaultPresentBadge: true,
//     );
//     const settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _plugin.initialize(settings: settings);

//     // إنشاء القناة وتأكيد الأذونات فوراً
//     await _createNotificationChannel();
//     await requestLocalPermissions();

//     // تفعيل ظهور إشعارات Firebase في Foreground (المقدمة)
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );

//     // الاستماع لإشعارات Firebase عند فتح التطبيق
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         final context = globalNavigatorKey.currentContext;
//         final rawId = message.data['id']?.toString();
//         final int notifId = rawId != null
//             ? rawId.hashCode
//             : DateTime.now().millisecondsSinceEpoch ~/ 1000;
//         final title =
//             message.notification?.title ??
//             message.data['title'] ??
//             "بدون عنوان";
//         final body =
//             message.notification?.body ?? message.data['body'] ?? "بدون محتوى";

//         // إظهار إشعار النظام فوراً بشكل منبثق
//         await showNotificationImmediately(
//           id: notifId,
//           title: title,
//           body: body,
//         );

//         if (context != null) {
//           final container = ProviderScope.containerOf(context);
//           final notification = AppNotification(
//             id: notifId.toString(),
//             title: title,
//             body: body,
//             date: DateTime.now(),
//           );

//           container
//               .read(notificationsProvider.notifier)
//               .addNotification(notification);

//           await saveNotificationToHistory(
//             notification.hashCode,
//             title,
//             body,
//             customId: notifId.toString(),
//           );
//         }
//       });
//     });
//   }

//   /// إنشاء القناة بخصائص الأهمية القصوى للصوت والانبثاق
//   Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       channelId,
//       channelName,
//       description: 'تنبيهات مواعيد الحجوزات',
//       importance: Importance.max,
//       playSound: true,
//       enableVibration: true,
//       showBadge: true,
//     );

//     final androidPlugin = _plugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >();
//     await androidPlugin?.createNotificationChannel(channel);
//   }

//   // أضف هذه الدالة داخل كلاس NotificationService
//   Future<void> subscribeToUserTopics({
//     required String city,
//     required bool isAdmin,
//   }) async {
//     try {
//       final messaging = FirebaseMessaging.instance;

//       // 1. اشتراك الأدمن في موضوع المدراء
//       if (isAdmin) {
//         await messaging.subscribeToTopic('admins');
//       } else {
//         await messaging.unsubscribeFromTopic('admins');
//       }

//       // 2. معالجة وتنظيف اسم المدينة لتنسيق مقبول في FCM Topics (بدون مسافات/رموز)
//       if (city.isNotEmpty) {
//         final cleanCity = city.trim().toLowerCase().replaceAll(
//           RegExp(r'[^a-zA-Z0-9_]'),
//           '_',
//         );
//         await messaging.subscribeToTopic('city_$cleanCity');
//       }
//     } catch (e) {
//       print("خطأ أثناء الاشتراك في موضوع FCM: $e");
//     }
//   }

//   /// إظهار الإشعار المباشر المنبثق مع الصوت والظهور أعلى الشاشة
//   Future<void> showNotificationImmediately({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     await _plugin.show(
//       id: id,
//       title: title,
//       body: body,
//       notificationDetails: const NotificationDetails(
//         android: AndroidNotificationDetails(
//           channelId,
//           channelName,
//           channelDescription: 'تنبيهات مواعيد الحجوزات',
//           importance: Importance.max,
//           priority: Priority.max,
//           playSound: true,
//           enableVibration: true,
//           fullScreenIntent: true,
//           visibility: NotificationVisibility.public,
//         ),
//         iOS: DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//     );
//   }

//   /// دالة جدولة الإشعار الدقيق في وقت محدد مسبقاً
//   Future<void> scheduleZonedNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   }) async {
//     if (scheduledDate.isBefore(DateTime.now())) return;

//     final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
//       scheduledDate,
//       tz.local,
//     );

//     await _plugin.zonedSchedule(
//       id: id,
//       title: title,
//       body: body,
//       scheduledDate: scheduledTZDate,
//       notificationDetails: const NotificationDetails(
//         android: AndroidNotificationDetails(
//           channelId,
//           channelName,
//           channelDescription: 'إشعارات مواعيد الحجز',
//           importance: Importance.max,
//           priority: Priority.high,
//           fullScreenIntent: true,
//           playSound: true,
//           enableVibration: true,
//         ),
//         iOS: DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }

//   /// الحصول على Access Token ديناميكي من ملف الـ JSON
//   static Future<String?> _getAccessToken() async {
//     try {
//       // قراءة ملف JSON من الـ assets
//       final jsonString = await rootBundle.loadString(
//         'assets/json/service_account.json',
//       );
//       final jsonMap = jsonDecode(jsonString);

//       // تحديد الأذونات الخاصة بـ Firebase Messaging
//       final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

//       final client = await auth.clientViaServiceAccount(
//         auth.ServiceAccountCredentials.fromJson(jsonMap),
//         scopes,
//       );

//       final credentials = client.credentials;
//       return credentials.accessToken.data;
//     } catch (e) {
//       print('خطأ في استخراج Access Token: $e');
//       return null;
//     }
//   }

//   /// إرسال إشعار FCM باستخدام HTTP v1 API
//   static Future<void> sendFcmNotification({
//     required String
//     target, // يمكن أن يكون Token جهاز أو Topic مثل "/topics/admins"
//     required String title,
//     required String body,
//   }) async {
//     try {
//       final token = await _getAccessToken();
//       if (token == null) {
//         print('تعذر الحصول على Token الإرسال');
//         return;
//       }

//       // قراءة Project ID تلقائياً من ملف JSON
//       final jsonString = await rootBundle.loadString(
//         'assets/json/service_account.json',
//       );
//       final jsonMap = jsonDecode(jsonString);
//       final String projectId = jsonMap['project_id'];

//       final url = Uri.parse(
//         'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
//       );

//       // تجهيز هيكل البيانات القياسي لـ HTTP v1
//       final Map<String, dynamic> bodyPayload = {
//         'message': {
//           if (target.startsWith('/topics/'))
//             'topic': target.replaceAll('/topics/', '')
//           else
//             'token': target,
//           'notification': {'title': title, 'body': body},
//           'android': {
//             'priority': 'high',
//             'notification': {
//               'channel_id': channelId, // channelId المعرف في الكلاس
//               'sound': 'default',
//             },
//           },
//           'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
//         },
//       };

//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(bodyPayload),
//       );

//       if (response.statusCode == 200) {
//         print('تم إرسال الإشعار بنجاح عبر FCM HTTP v1');
//       } else {
//         print('فشل إرسال الإشعار: ${response.body}');
//       }
//     } catch (e) {
//       print('خطأ أثناء إرسال إشعار FCM: $e');
//     }
//   }

//   // -------------------------------------------------------------------------
//   // Save and load alarm data in SharedPreferences
//   // -------------------------------------------------------------------------
//   static Future<void> _saveAlarmData(
//     int id,
//     String title,
//     String body, {
//     String? partyId,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(
//       '$_storagePrefix$id',
//       jsonEncode({"title": title, "body": body, "partyId": partyId ?? ""}),
//     );
//   }

//   static Future<Map<String, String>> loadAlarmData(int id) async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonStr = prefs.getString('$_storagePrefix$id');

//     if (jsonStr == null) return {"title": "تذكير", "body": "", "partyId": ""};

//     final map = jsonDecode(jsonStr) as Map<String, dynamic>;
//     return {
//       "title": map["title"]?.toString() ?? "تذكير",
//       "body": map["body"]?.toString() ?? "",
//       "partyId": map["partyId"]?.toString() ?? "",
//     };
//   }

//   // -------------------------------------------------------------------------
//   // Schedule a single alarm
//   // -------------------------------------------------------------------------
//   Future<void> scheduleExactAlarm({
//     required int id,
//     required DateTime time,
//     required String title,
//     required String body,
//     String? partyId,
//   }) async {
//     if (time.isBefore(DateTime.now())) return;

//     await _saveAlarmData(id, title, body, partyId: partyId);
//     await Future.delayed(const Duration(milliseconds: 100));

//     await AndroidAlarmManager.oneShotAt(
//       time,
//       id,
//       alarmCallback,
//       wakeup: true,
//       rescheduleOnReboot: true,
//       exact: true,
//       alarmClock: true,
//     );
//   }

//   Future<void> schedulePartyReminders({
//     required String partyId,
//     required String title,
//     required String body,
//     required DateTime date,
//   }) async {
//     final now = DateTime.now();

//     final hourBefore = date.subtract(const Duration(hours: 1));

//     // تنبيه قبل ساعة باستخدام zonedSchedule
//     if (hourBefore.isAfter(now)) {
//       await scheduleZonedNotification(
//         id: ("hour_$partyId").hashCode,
//         title: "تذكير بالحجز",
//         body: "لديك موعد حجز بعد ساعة",
//         scheduledDate: hourBefore,
//       );
//     }

//     // تنبيه الموعد الرئيسي
//     if (date.isAfter(now)) {
//       await scheduleZonedNotification(
//         id: ("party_$partyId").hashCode,
//         title: title,
//         body: body,
//         scheduledDate: date,
//       );
//     }

//     // جدولة AlarmManager لضمان الاستيقاظ في الخلفية
//     if (hourBefore.isAfter(now)) {
//       await scheduleExactAlarm(
//         id: ("hour_$partyId").hashCode,
//         time: hourBefore,
//         title: "$title (قبل ساعة)",
//         body: body,
//         partyId: partyId,
//       );
//     }
//   }

//   Future<void> updatePartyReminder({
//     required String partyId,
//     required String title,
//     required String body,
//     required DateTime date,
//   }) async {
//     await cancelPartyReminder(partyId);
//     await schedulePartyReminders(
//       partyId: partyId,
//       title: title,
//       body: body,
//       date: date,
//     );
//   }

//   Future<void> removeNotificationFromHistory(String partyId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<String> history =
//         prefs.getStringList('notifications_history') ?? [];

//     history.removeWhere((item) {
//       final Map<String, dynamic> data = jsonDecode(item);
//       return data['id'] == partyId || data['customId'] == partyId;
//     });

//     await prefs.setStringList('notifications_history', history);
//   }

//   Future<void> cancelPartyReminder(String partyId) async {
//     await AndroidAlarmManager.cancel(("day_$partyId").hashCode);
//     await AndroidAlarmManager.cancel(("hour_$partyId").hashCode);
//     await AndroidAlarmManager.cancel(("party_$partyId").hashCode);

//     await removeNotificationFromHistory(partyId);
//   }

//   /// طلب أذونات الإشعارات والمنبهات من الجهاز
//   Future<void> requestLocalPermissions() async {
//     if (await Permission.notification.isDenied) {
//       await Permission.notification.request();
//     }

//     if (await Permission.scheduleExactAlarm.isDenied) {
//       await Permission.scheduleExactAlarm.request();
//     }

//     final androidPlugin = _plugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >();
//     await androidPlugin?.requestNotificationsPermission();
//     await androidPlugin?.requestExactAlarmsPermission();
//   }

//   Future<List<Map<String, dynamic>>> getNotificationHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> history = prefs.getStringList("notifications_history") ?? [];

//     return history
//         .map((e) => jsonDecode(e) as Map<String, dynamic>)
//         .toList()
//         .reversed
//         .toList();
//   }
// }

// // -------------------------------------------------------------------------
// // دوال الخلفية العامة المستقلة (Top-Level Functions)
// // -------------------------------------------------------------------------

// @pragma("vm:entry-point")
// Future<void> alarmCallback(int id) async {
//   print("🚨🚨 ALARM CALLBACK اشتغل! ID = $id");

//   final plugin = FlutterLocalNotificationsPlugin();

//   const settings = InitializationSettings(
//     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     iOS: DarwinInitializationSettings(),
//   );
//   await plugin.initialize(settings: settings);

//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     NotificationService.channelId,
//     NotificationService.channelName,
//     description: 'تنبيهات مواعيد الحجوزات',
//     importance: Importance.max,
//     playSound: true,
//     enableVibration: true,
//   );

//   final androidPlugin = plugin
//       .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin
//       >();
//   await androidPlugin?.createNotificationChannel(channel);

//   final data = await NotificationService.loadAlarmData(id);
//   final title = data["title"] ?? "تذكير";
//   final body = data["body"] ?? "";
//   final partyId = data["partyId"];

//   await plugin.show(
//     id: id,
//     title: title,
//     body: body,
//     notificationDetails: NotificationDetails(
//       android: AndroidNotificationDetails(
//         NotificationService.channelId,
//         NotificationService.channelName,
//         channelDescription: 'تنبيهات مواعيد الحجوزات',
//         importance: Importance.max,
//         priority: Priority.max,
//         playSound: true,
//         enableVibration: true,
//         styleInformation: BigTextStyleInformation(body),
//         visibility: NotificationVisibility.public,
//       ),
//       iOS: const DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     ),
//   );

//   await saveNotificationToHistory(id, title, body, customId: partyId);
// }

// // الدالة الموحدة لحفظ السجل
// Future<void> saveNotificationToHistory(
//   int id,
//   String? title,
//   String? body, {
//   String? customId,
// }) async {
//   final prefs = await SharedPreferences.getInstance();
//   List<String> history = prefs.getStringList("notifications_history") ?? [];

//   final String notificationId = (customId != null && customId.isNotEmpty)
//       ? customId
//       : id.toString();

//   final entry = jsonEncode({
//     "id": notificationId,
//     "title": title ?? "بدون عنوان",
//     "body": body ?? "بدون محتوى",
//     "time": DateTime.now().toIso8601String(),
//   });

//   history.add(entry);
//   await prefs.setStringList("notifications_history", history);
// }
// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:princesses/core/global_navigator.dart';
import 'package:princesses/home/application/booking_notification_helper.dart';
import 'package:princesses/home/application/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = "party_channel_v4";
  static const String channelName = "Party Reminders";
  static const String _storagePrefix = "alarm_";

  Future<void> init() async {
    tz_data.initializeTimeZones();
    await AndroidAlarmManager.initialize();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);

    await _createNotificationChannel();
    await requestLocalPermissions();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final context = globalNavigatorKey.currentContext;
        final rawId = message.data['id']?.toString();
        final int notifId = rawId != null
            ? rawId.hashCode
            : DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final title =
            message.notification?.title ??
            message.data['title'] ??
            "بدون عنوان";
        final body =
            message.notification?.body ?? message.data['body'] ?? "بدون محتوى";

        await showNotificationImmediately(
          id: notifId,
          title: title,
          body: body,
        );

        if (context != null) {
          final container = ProviderScope.containerOf(context);
          final notification = AppNotification(
            id: notifId.toString(),
            title: title,
            body: body,
            date: DateTime.now(),
          );

          container
              .read(notificationsProvider.notifier)
              .addNotification(notification);

          await saveNotificationToHistory(
            notification.hashCode,
            title,
            body,
            customId: notifId.toString(),
          );
        }
      });
    });
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'تنبيهات مواعيد الحجوزات',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(channel);
  }

  // Future<void> subscribeToUserTopics({
  //   required String city,
  //   required bool isAdmin,
  // }) async {
  //   try {
  //     final messaging = FirebaseMessaging.instance;

  //     if (isAdmin) {
  //       await messaging.subscribeToTopic('admins');
  //     } else {
  //       await messaging.unsubscribeFromTopic('admins');
  //     }

  //     if (city.isNotEmpty) {
  //       final cleanCity = city.trim().toLowerCase().replaceAll(
  //         RegExp(r'[^a-zA-Z0-9_]'),
  //         '_',
  //       );
  //       await messaging.subscribeToTopic('city_$cleanCity');
  //     }
  //   } catch (e) {
  //     print("خطأ أثناء الاشتراك في موضوع FCM: $e");
  //   }
  // }
  Future<void> subscribeToUserTopics({
    required String city,
    required bool isAdmin,
  }) async {
    try {
      final messaging = FirebaseMessaging.instance;

      if (isAdmin) {
        await messaging.subscribeToTopic('admins');
      } else {
        await messaging.unsubscribeFromTopic('admins');
      }

      if (city.isNotEmpty) {
        // 🌟 استخدام نفس منطق Normalize لضمان التطابق مع الإرسال (مثلاً: homs بدلاً من حمص)
        final cleanCity = BookingNotificationHelper.normalizeCityKey(city);
        await messaging.subscribeToTopic('city_$cleanCity');
      }
    } catch (e) {
      print("خطأ أثناء الاشتراك في موضوع FCM: $e");
    }
  }

  Future<void> showNotificationImmediately({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'تنبيهات مواعيد الحجوزات',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> scheduleZonedNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTZDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'إشعارات مواعيد الحجز',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<String?> _getAccessToken() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/service_account.json',
      );
      final jsonMap = jsonDecode(jsonString);

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(jsonMap),
        scopes,
      );

      final credentials = client.credentials;
      return credentials.accessToken.data;
    } catch (e) {
      print('خطأ في استخراج Access Token: $e');
      return null;
    }
  }

  static Future<void> sendFcmNotification({
    required String target,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        print('تعذر الحصول على Token الإرسال');
        return;
      }

      final jsonString = await rootBundle.loadString(
        'assets/json/service_account.json',
      );
      final jsonMap = jsonDecode(jsonString);
      final String projectId = jsonMap['project_id'];

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final Map<String, dynamic> bodyPayload = {
        'message': {
          if (target.startsWith('/topics/'))
            'topic': target.replaceAll('/topics/', '')
          else
            'token': target,
          'notification': {'title': title, 'body': body},
          'android': {
            'priority': 'high',
            'notification': {'channel_id': channelId, 'sound': 'default'},
          },
          'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyPayload),
      );

      if (response.statusCode == 200) {
        print('تم إرسال الإشعار بنجاح عبر FCM HTTP v1');
      } else {
        print('فشل إرسال الإشعار: ${response.body}');
      }
    } catch (e) {
      print('خطأ أثناء إرسال إشعار FCM: $e');
    }
  }

  static Future<void> _saveAlarmData(
    int id,
    String title,
    String body, {
    String? partyId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_storagePrefix$id',
      jsonEncode({"title": title, "body": body, "partyId": partyId ?? ""}),
    );
  }

  // static Future<Map<String, String>> loadAlarmData(int id) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final jsonStr = prefs.getString('$_storagePrefix$id');

  //   if (jsonStr == null) return {"title": "تذكير", "body": "", "partyId": ""};

  //   final map = jsonDecode(jsonStr) as Map<String, dynamic>;
  //   return {
  //     "title": map["title"]?.toString() ?? "تذكير",
  //     "body": map["body"]?.toString() ?? "",
  //     "partyId": map["partyId"]?.toString() ?? "",
  //   };
  // }
  // تعديل القيمة الافتراضية في loadAlarmData لتفادي كلمة "تذكير" المجردة
  static Future<Map<String, String>> loadAlarmData(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_storagePrefix$id');

    if (jsonStr == null) {
      return {
        "title": "إشعار موعد",
        "body": "لديك تذكير بموعد حجز",
        "partyId": "",
      };
    }

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return {
      "title": map["title"]?.toString() ?? "إشعار موعد",
      "body": map["body"]?.toString() ?? "تفاصيل الموعد غير متوفرة",
      "partyId": map["partyId"]?.toString() ?? "",
    };
  }

  Future<void> scheduleExactAlarm({
    required int id,
    required DateTime time,
    required String title,
    required String body,
    String? partyId,
  }) async {
    if (time.isBefore(DateTime.now())) return;

    await _saveAlarmData(id, title, body, partyId: partyId);
    await Future.delayed(const Duration(milliseconds: 100));

    await AndroidAlarmManager.oneShotAt(
      time,
      id,
      alarmCallback,
      wakeup: true,
      rescheduleOnReboot: true,
      exact: true,
      alarmClock: true,
    );
  }

  /// جدولة التنبيهات المخصصة للحجز (قبل 24 ساعة وقبل 1 ساعة والموعد نفسه)
  // Future<void> scheduleAppointmentReminders({
  //   required String partyId,
  //   required String title,
  //   required String place,
  //   required DateTime appointmentDate,
  // }) async {
  //   final now = DateTime.now();

  //   // 1. إشعار قبل يوم واحد (24 ساعة)
  //   final dayBefore = appointmentDate.subtract(const Duration(days: 1));
  //   if (dayBefore.isAfter(now)) {
  //     final dayId = ("day_$partyId").hashCode;
  //     await scheduleZonedNotification(
  //       id: dayId,
  //       title: "تذكير: موعد حجز غداً",
  //       body: "لديك موعد غداً مع $title في $place",
  //       scheduledDate: dayBefore,
  //     );
  //     await scheduleExactAlarm(
  //       id: dayId,
  //       time: dayBefore,
  //       title: "تذكير: موعد حجز غداً",
  //       body: "لديك موعد غداً مع $title في $place",
  //       partyId: partyId,
  //     );
  //   }

  //   // 2. إشعار قبل ساعة واحدة
  //   final hourBefore = appointmentDate.subtract(const Duration(hours: 1));
  //   if (hourBefore.isAfter(now)) {
  //     final hourId = ("hour_$partyId").hashCode;
  //     await scheduleZonedNotification(
  //       id: hourId,
  //       title: "تذكير: موعد حجز بعد ساعة",
  //       body: "موعدك بعد ساعة مع $title في $place",
  //       scheduledDate: hourBefore,
  //     );
  //     await scheduleExactAlarm(
  //       id: hourId,
  //       time: hourBefore,
  //       title: "تذكير: موعد حجز بعد ساعة",
  //       body: "موعدك بعد ساعة مع $title في $place",
  //       partyId: partyId,
  //     );
  //   }

  //   // 3. إشعار الموعد نفسه
  //   if (appointmentDate.isAfter(now)) {
  //     final partyIdHash = ("party_$partyId").hashCode;
  //     await scheduleZonedNotification(
  //       id: partyIdHash,
  //       title: "حان موعد الحجز: $title",
  //       body: "المكان: $place",
  //       scheduledDate: appointmentDate,
  //     );
  //   }
  // }
  Future<void> scheduleAppointmentReminders({
    required String partyId,
    required String title,
    required String place,
    required DateTime appointmentDate,
  }) async {
    final now = DateTime.now();

    // 1. إشعار قبل يوم واحد (24 ساعة)
    final dayBefore = appointmentDate.subtract(const Duration(days: 1));
    if (dayBefore.isAfter(now)) {
      final dayZonedId = ("day_zoned_$partyId").hashCode;
      final dayAlarmId = ("day_alarm_$partyId").hashCode;

      await scheduleZonedNotification(
        id: dayZonedId,
        title: "جدولة: موعد حجز غداً",
        body: "لديك موعد غداً مع $title في $place",
        scheduledDate: dayBefore,
      );

      await scheduleExactAlarm(
        id: dayAlarmId,
        time: dayBefore,
        title: "جدولة: موعد حجز غداً",
        body: "لديك موعد غداً مع $title في $place",
        partyId: partyId,
      );
    }

    // 2. إشعار قبل ساعة واحدة
    final hourBefore = appointmentDate.subtract(const Duration(hours: 1));
    if (hourBefore.isAfter(now)) {
      final hourZonedId = ("hour_zoned_$partyId").hashCode;
      final hourAlarmId = ("hour_alarm_$partyId").hashCode;

      await scheduleZonedNotification(
        id: hourZonedId,
        title: "جدولة: موعد حجز بعد ساعة",
        body: "موعدك بعد ساعة مع $title في $place",
        scheduledDate: hourBefore,
      );

      await scheduleExactAlarm(
        id: hourAlarmId,
        time: hourBefore,
        title: "جدولة: موعد حجز بعد ساعة",
        body: "موعدك بعد ساعة مع $title في $place",
        partyId: partyId,
      );
    }

    // 3. إشعار الموعد نفسه
    if (appointmentDate.isAfter(now)) {
      final partyIdHash = ("party_$partyId").hashCode;
      await scheduleZonedNotification(
        id: partyIdHash,
        title: "حان موعد الحجز: $title",
        body: "المكان: $place",
        scheduledDate: appointmentDate,
      );
    }
  }

  // Future<void> cancelPartyReminder(String partyId) async {
  //   await AndroidAlarmManager.cancel(("day_$partyId").hashCode);
  //   await AndroidAlarmManager.cancel(("hour_$partyId").hashCode);
  //   await AndroidAlarmManager.cancel(("party_$partyId").hashCode);

  //   await removeNotificationFromHistory(partyId);
  // }
  Future<void> cancelPartyReminder(String partyId) async {
    await AndroidAlarmManager.cancel(("day_alarm_$partyId").hashCode);
    await AndroidAlarmManager.cancel(("hour_alarm_$partyId").hashCode);
    await _plugin.cancel(id: ("day_zoned_$partyId").hashCode);
    await _plugin.cancel(id: ("hour_zoned_$partyId").hashCode);
    await _plugin.cancel(id: ("party_$partyId").hashCode);

    await removeNotificationFromHistory(partyId);
  }

  Future<void> removeNotificationFromHistory(String partyId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history =
        prefs.getStringList('notifications_history') ?? [];

    history.removeWhere((item) {
      final Map<String, dynamic> data = jsonDecode(item);
      return data['id'] == partyId || data['customId'] == partyId;
    });

    await prefs.setStringList('notifications_history', history);
  }

  Future<void> requestLocalPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList("notifications_history") ?? [];

    return history
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
  }
}

@pragma("vm:entry-point")
Future<void> alarmCallback(int id) async {
  final plugin = FlutterLocalNotificationsPlugin();

  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await plugin.initialize(settings: settings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    NotificationService.channelId,
    NotificationService.channelName,
    description: 'تنبيهات مواعيد الحجوزات',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  final androidPlugin = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await androidPlugin?.createNotificationChannel(channel);

  final data = await NotificationService.loadAlarmData(id);
  final title = data["title"] ?? "تذكير";
  final body = data["body"] ?? "";
  final partyId = data["partyId"];

  await plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationService.channelId,
        NotificationService.channelName,
        channelDescription: 'تنبيهات مواعيد الحجوزات',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
        visibility: NotificationVisibility.public,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );

  await saveNotificationToHistory(id, title, body, customId: partyId);
}

Future<void> saveNotificationToHistory(
  int id,
  String? title,
  String? body, {
  String? customId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> history = prefs.getStringList("notifications_history") ?? [];

  final String notificationId = (customId != null && customId.isNotEmpty)
      ? customId
      : id.toString();

  final entry = jsonEncode({
    "id": notificationId,
    "title": title ?? "بدون عنوان",
    "body": body ?? "بدون محتوى",
    "time": DateTime.now().toIso8601String(),
  });

  history.add(entry);
  await prefs.setStringList("notifications_history", history);
}
