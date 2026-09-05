// ignore_for_file: use_build_context_synchronously, avoid_print

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

  static const String channelId =
      "party_channel_v4"; // قناة جديدة بحجم أولوية أعلى
  static const String channelName = "Party Reminders";
  static const String _storagePrefix = "alarm_";

  Future<void> init() async {
    tz.initializeTimeZones();
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

    // إنشاء القناة وتأكيد الأذونات فوراً
    await _createNotificationChannel();
    await requestLocalPermissions();

    // تفعيل ظهور إشعارات Firebase في Foreground (المقدمة)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // الاستماع لإشعارات Firebase عند فتح التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final context = globalNavigatorKey.currentContext;

        final title =
            message.notification?.title ??
            message.data['title'] ??
            "بدون عنوان";
        final body =
            message.notification?.body ?? message.data['body'] ?? "بدون محتوى";
        final notifId =
            message.data['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();

        // إظهار إشعار النظام فوراً في البرداية
        await showNotificationImmediately(
          id: notifId.hashCode,
          title: title,
          body: body,
        );

        if (context != null) {
          final container = ProviderScope.containerOf(context);
          final notification = AppNotification(
            id: notifId,
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
            customId: notifId,
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
      importance: Importance.max, // إجباري للظهور في البرداية مع تنبيه صوتي
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

  // إظهار الإشعار المباشر
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
          importance: Importance.max, // إجباري
          priority: Priority.max, // إجباري للتنبيه المنبثق والبرداية
          playSound: true,
          enableVibration: true,
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

  // -------------------------------------------------------------------------
  // Save and load alarm data in SharedPreferences
  // -------------------------------------------------------------------------
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

  static Future<Map<String, String>> loadAlarmData(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_storagePrefix$id');

    if (jsonStr == null) return {"title": "تذكير", "body": "", "partyId": ""};

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return {
      "title": map["title"]?.toString() ?? "تذكير",
      "body": map["body"]?.toString() ?? "",
      "partyId": map["partyId"]?.toString() ?? "",
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
      alarmClock: true, // يضمن تنفيذ المنبه بدقة متناهية وفي البرداية
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
        partyId: partyId,
      );
    }

    // قبل ساعة
    if (hourBefore.isAfter(now)) {
      await scheduleExactAlarm(
        id: ("hour_$partyId").hashCode,
        time: hourBefore,
        title: "$title (قبل ساعة)",
        body: body,
        partyId: partyId,
      );
    }

    // الإشعار الرئيسي في الموعد
    if (date.isAfter(now)) {
      await scheduleExactAlarm(
        id: ("party_$partyId").hashCode,
        time: date,
        title: title,
        body: body,
        partyId: partyId,
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

  /// طلب أذونات الإشعارات والمنبهات من الجهاز
  Future<void> requestLocalPermissions() async {
    // 1. طلب إذن الإشعارات العام (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // 2. طلب إذن المنبهات الدقيقة (Schedule Exact Alarm)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    // 3. طلب الأذونات عبر Flutter Local Notifications Plugin
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

// -------------------------------------------------------------------------
// دوال الخلفية العامة المستقلة (Top-Level Functions)
// -------------------------------------------------------------------------

@pragma("vm:entry-point")
Future<void> alarmCallback(int id) async {
  print("🚨🚨 ALARM CALLBACK اشتغل! ID = $id");

  final plugin = FlutterLocalNotificationsPlugin();

  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await plugin.initialize(settings: settings);

  // إعداد القناة لضمان الإنشاء إذا انطلقت العملية والخلفية مغلقة تماماً
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
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationService.channelId,
        NotificationService.channelName,
        channelDescription: 'تنبيهات مواعيد الحجوزات',
        importance: Importance.max, // أقصى أولوية لظهور البرداية
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );

  await saveNotificationToHistory(id, title, body, customId: partyId);
}

// الدالة الموحدة لحفظ السجل
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
