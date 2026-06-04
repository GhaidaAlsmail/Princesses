// //------------------------------1-----------------------------------------------
// import 'dart:convert';
// import 'package:princesses/core/global_navigator.dart';
// import 'package:princesses/home/application/notification_provider.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/data/latest_all.dart' as tz;

// /// Notification Service for party/event reminders
// @pragma('vm:entry-point')
// class NotificationService {
//   // Singleton
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   static const String channelId = "party_channel";
//   static const String channelName = "Party Reminders";
//   static const String _storagePrefix = "alarm_";

//   Future<void> init() async {
//     tz.initializeTimeZones();
//     await AndroidAlarmManager.initialize();

//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//     const iosSettings = DarwinInitializationSettings();
//     const settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _plugin.initialize(settings: settings);

//     await _createNotificationChannel();
//     await _requestPermissions();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         final context = globalNavigatorKey.currentContext;
//         if (context != null) {
//           final container = ProviderScope.containerOf(context);
//           final title =
//               message.notification?.title ??
//               message.data['title'] ??
//               "بدون عنوان";
//           final body =
//               message.notification?.body ??
//               message.data['body'] ??
//               "بدون محتوى";

//           final notification = AppNotification(
//             title: title,
//             body: body,
//             date: DateTime.now(),
//           );

//           container
//               .read(notificationsProvider.notifier)
//               .addNotification(notification);

//           // حفظ في التاريخ
//           await _saveNotificationToHistory(notification.hashCode, title, body);
//         }
//       });
//     });
//   }

//   Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       channelId,
//       channelName,
//       importance: Importance.max,
//     );

//     final androidPlugin = _plugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >();
//     await androidPlugin?.createNotificationChannel(channel);
//   }

//   // -------------------------------------------------------------------------
//   // Save and load alarm data in SharedPreferences
//   // -------------------------------------------------------------------------
//   static Future<void> _saveAlarmData(int id, String title, String body) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(
//       '$_storagePrefix$id',
//       jsonEncode({"title": title, "body": body}),
//     );
//   }

//   static Future<Map<String, String>> loadAlarmData(int id) async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonStr = prefs.getString('$_storagePrefix$id');

//     if (jsonStr == null) return {"title": "تذكير", "body": ""};

//     final map = jsonDecode(jsonStr) as Map<String, dynamic>;
//     return {
//       "title": map["title"]?.toString() ?? "تذكير",
//       "body": map["body"]?.toString() ?? "",
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
//   }) async {
//     if (time.isBefore(DateTime.now())) return;

//     await _saveAlarmData(id, title, body);
//     await Future.delayed(Duration(milliseconds: 100));

//     await AndroidAlarmManager.oneShotAt(
//       time,
//       id,
//       alarmCallback, // callback الخارجي
//       wakeup: true,
//       rescheduleOnReboot: true,
//       exact: true,
//       params: {"title": title, "body": body},
//     );
//   }

//   Future<void> schedulePartyReminders({
//     required String partyId,
//     required String title,
//     required String body,
//     required DateTime date,
//   }) async {
//     final now = DateTime.now();

//     final dayBefore = date.subtract(const Duration(days: 1));
//     final hourBefore = date.subtract(const Duration(hours: 1));

//     // قبل يوم
//     if (dayBefore.isAfter(now)) {
//       await scheduleExactAlarm(
//         id: ("day_$partyId").hashCode,
//         time: dayBefore,
//         title: "$title (قبل يوم)",
//         body: body,
//       );
//     }

//     // قبل ساعة
//     if (hourBefore.isAfter(now)) {
//       await scheduleExactAlarm(
//         id: ("hour_$partyId").hashCode,
//         time: hourBefore,
//         title: "$title (قبل ساعة)",
//         body: body,
//       );
//     }

//     // الإشعار الرئيسي في الموعد
//     if (date.isAfter(now)) {
//       await scheduleExactAlarm(
//         id: ("party_$partyId").hashCode,
//         time: date,
//         title: title,
//         body: body,
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

//   Future<void> cancelPartyReminder(String partyId) async {
//     await AndroidAlarmManager.cancel(("day_$partyId").hashCode);
//     await AndroidAlarmManager.cancel(("hour_$partyId").hashCode);
//     await AndroidAlarmManager.cancel(("party_$partyId").hashCode);
//   }

//   Future<void> _requestPermissions() async {
//     // طلب إذن الإشعارات الأساسي (مهم لـ Android 13+)
//     if (!await Permission.notification.isGranted) {
//       await Permission.notification.request();
//     }
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

//   Future<void> saveNotificationToHistory(
//     int id,
//     String? title,
//     String? body,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();

//     // جلب قائمة الإشعارات الحالية من التخزين
//     List<String> history = prefs.getStringList("notifications_history") ?? [];

//     // إنشاء إدخال جديد للإشعار
//     final entry = jsonEncode({
//       "id": id, // معرف فريد للإشعار
//       "title": title ?? "بدون عنوان", // العنوان
//       "body": body ?? "بدون محتوى", // محتوى الإشعار
//       "time": DateTime.now().toIso8601String(), // توقيت الإشعار
//     });

//     // إضافة الإشعار الجديد للقائمة
//     history.add(entry);

//     // حفظ القائمة المحدثة في SharedPreferences
//     await prefs.setStringList("notifications_history", history);
//   }
// }

// @pragma("vm:entry-point")
// Future<void> alarmCallback(int id, Map<String, dynamic> params) async {
//   final plugin = FlutterLocalNotificationsPlugin();

//   const settings = InitializationSettings(
//     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     iOS: DarwinInitializationSettings(),
//   );
//   await plugin.initialize(settings: settings);

//   final title = params["title"] ?? "تذكير";
//   final body = params["body"] ?? "";
//   await plugin.show(
//     id: id,
//     title: title,
//     body: body,
//     notificationDetails: const NotificationDetails(
//       android: AndroidNotificationDetails(
//         NotificationService.channelId,
//         NotificationService.channelName,
//         importance: Importance.max,
//       ),
//     ),
//   );

//   await _saveNotificationToHistory(id, title, body);
// }

// // @pragma("vm:entry-point")
// // Future<void> alarmCallback(int id) async {
// //   final FlutterLocalNotificationsPlugin plugin =
// //       FlutterLocalNotificationsPlugin();

// //   const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
// //   const iosSettings = DarwinInitializationSettings();
// //   const settings = InitializationSettings(
// //     android: androidSettings,
// //     iOS: iosSettings,
// //   );

// //   await plugin.initialize(settings);

// //   final data = await NotificationService.loadAlarmData(id);

// //   await plugin.show(
// //     id,
// //     data["title"],
// //     data["body"],
// //     const NotificationDetails(
// //       android: AndroidNotificationDetails(
// //         NotificationService.channelId,
// //         NotificationService.channelName,
// //         importance: Importance.max,
// //         priority: Priority.high,
// //       ),
// //     ),
// //   );

// //   await _saveNotificationToHistory(id, data["title"], data["body"]);
// // }

// Future<void> _saveNotificationToHistory(
//   int id,
//   String? title,
//   String? body,
// ) async {
//   final prefs = await SharedPreferences.getInstance();

//   List<String> history = prefs.getStringList("notifications_history") ?? [];

//   final entry = jsonEncode({
//     "id": id,
//     "title": title,
//     "body": body,
//     "time": DateTime.now().toIso8601String(),
//   });

//   history.add(entry);
//   await prefs.setStringList("notifications_history", history);
// }
import 'dart:convert';
import 'package:princesses/core/global_navigator.dart';
import 'package:princesses/home/application/notification_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

/// Notification Service for party/event reminders
@pragma('vm:entry-point')
class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = "party_channel";
  static const String channelName = "Party Reminders";
  static const String _storagePrefix = "alarm_";

  Future<void> init() async {
    tz.initializeTimeZones();
    await AndroidAlarmManager.initialize();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);
    await _createNotificationChannel();
    await _requestPermissions();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final context = globalNavigatorKey.currentContext;
        if (context != null) {
          final container = ProviderScope.containerOf(context);
          final title =
              message.notification?.title ??
              message.data['title'] ??
              "بدون عنوان";
          final body =
              message.notification?.body ??
              message.data['body'] ??
              "بدون محتوى";

          final notification = AppNotification(
            title: title,
            body: body,
            date: DateTime.now(),
          );

          container
              .read(notificationsProvider.notifier)
              .addNotification(notification);

          // 🌟 استدعاء الدالة العامة بالأسفل لحفظ الإشعار المستلم فوراً
          await saveNotificationToHistory(notification.hashCode, title, body);
        }
      });
    });
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.max,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(channel);
  }

  // -------------------------------------------------------------------------
  // Save and load alarm data in SharedPreferences
  // -------------------------------------------------------------------------
  static Future<void> _saveAlarmData(int id, String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_storagePrefix$id',
      jsonEncode({"title": title, "body": body}),
    );
  }

  static Future<Map<String, String>> loadAlarmData(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_storagePrefix$id');

    if (jsonStr == null) return {"title": "تذكير", "body": ""};

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return {
      "title": map["title"]?.toString() ?? "تذكير",
      "body": map["body"]?.toString() ?? "",
    };
  }

  // -------------------------------------------------------------------------
  // Schedule a single alarm
  // -------------------------------------------------------------------------
  Future<void> scheduleExactAlarm({
    required int id,
    required DateTime time,
    required String title,
    required String body,
  }) async {
    if (time.isBefore(DateTime.now())) return;

    await _saveAlarmData(id, title, body);
    await Future.delayed(const Duration(milliseconds: 100));

    await AndroidAlarmManager.oneShotAt(
      time,
      id,
      alarmCallback,
      wakeup: true,
      rescheduleOnReboot: true,
      exact: true,
    );
  }

  Future<void> schedulePartyReminders({
    required String partyId,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    final now = DateTime.now();

    final dayBefore = date.subtract(const Duration(days: 1));
    final hourBefore = date.subtract(const Duration(hours: 1));

    // قبل يوم
    if (dayBefore.isAfter(now)) {
      await scheduleExactAlarm(
        id: ("day_$partyId").hashCode,
        time: dayBefore,
        title: "$title (قبل يوم)",
        body: body,
      );
    }

    // قبل ساعة
    if (hourBefore.isAfter(now)) {
      await scheduleExactAlarm(
        id: ("hour_$partyId").hashCode,
        time: hourBefore,
        title: "$title (قبل ساعة)",
        body: body,
      );
    }

    // الإشعار الرئيسي في الموعد
    if (date.isAfter(now)) {
      await scheduleExactAlarm(
        id: ("party_$partyId").hashCode,
        time: date,
        title: title,
        body: body,
      );
    }
  }

  Future<void> updatePartyReminder({
    required String partyId,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    await cancelPartyReminder(partyId);
    await schedulePartyReminders(
      partyId: partyId,
      title: title,
      body: body,
      date: date,
    );
  }

  Future<void> cancelPartyReminder(String partyId) async {
    await AndroidAlarmManager.cancel(("day_$partyId").hashCode);
    await AndroidAlarmManager.cancel(("hour_$partyId").hashCode);
    await AndroidAlarmManager.cancel(("party_$partyId").hashCode);
  }

  Future<void> _requestPermissions() async {
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
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

// -------------------------------------------------------------------------
// دوال الخلفية العامة المستقلة (Top-Level Functions)
// -------------------------------------------------------------------------

@pragma("vm:entry-point")
Future<void> alarmCallback(int id) async {
  final plugin = FlutterLocalNotificationsPlugin();

  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await plugin.initialize(settings: settings);

  final data = await NotificationService.loadAlarmData(id);
  final title = data["title"] ?? "تذكير";
  final body = data["body"] ?? "";

  await plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationService.channelId,
        NotificationService.channelName,
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );

  await saveNotificationToHistory(id, title, body);
}

// 🌟 الدالة الموحدة والمستخدمة في كل الملف لحفظ التاريخ
// إزالة الـ (_) تجعل الدالة مكشوفة لكل الملفات التي تعمل import للملف
Future<void> saveNotificationToHistory(
  int id,
  String? title,
  String? body,
) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> history = prefs.getStringList("notifications_history") ?? [];

  final entry = jsonEncode({
    "id": id,
    "title": title ?? "بدون عنوان",
    "body": body ?? "بدون محتوى",
    "time": DateTime.now().toIso8601String(),
  });

  history.add(entry);
  await prefs.setStringList("notifications_history", history);
}
