// import 'package:intl/intl.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class LocalNotification {
//   static final FlutterLocalNotificationsPlugin localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   /// ⚙️ تهيئة خدمة الإشعارات المحلية
//   static Future<void> init() async {
//     // تهيئة وقواعد التوقيت الزمني
//     tz.initializeTimeZones();

//     // جلب اسم المنطقة الزمنية المحدث للـ v5+
//     final timezoneInfo = await FlutterTimezone.getLocalTimezone();
//     final String currentTimeZone = timezoneInfo.identifier;

//     tz.setLocalLocation(tz.getLocation(currentTimeZone));

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//           android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//           iOS: DarwinInitializationSettings(),
//         );

//     await localNotificationsPlugin.initialize(settings: initializationSettings);
//   }

//   /// 🔔 تفاصيل إعدادات الإشعار
//   static NotificationDetails _notificationDetails() {
//     return NotificationDetails(
//       android: AndroidNotificationDetails(
//         "booking_channel_id",
//         "تنبيهات الحجوزات والمواعيد",
//         channelDescription: "إشعارات للتذكير بمواعيد الحفلات والحجوزات القادمة",
//         playSound: true,
//         importance: Importance.max,
//         priority: Priority.high,
//         enableVibration: true, // تفعيل الهزاز

//         sound: RawResourceAndroidNotificationSound(
//           'notification'.split('.').first,
//         ),
//       ),
//       iOS: const DarwinNotificationDetails(),
//     );
//   }

//   /// 📅 1. جدولة إشعار في وقت محدد (مواقيت / أوقات يومية)
//   static Future<void> scheduledNotification({
//     required String id,
//     required String title,
//     required String body,
//     required String timeStr, // بصيغة hh:mm a
//   }) async {
//     final DateTime now = DateTime.now();
//     final DateTime parsedTime = DateFormat('h:mm a').parse(timeStr);

//     tz.TZDateTime scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       parsedTime.hour,
//       parsedTime.minute,
//     );

//     // إذا كان الوقت قد مضى اليوم، يتم جدولة التنبيه للغد
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }

//     await localNotificationsPlugin.zonedSchedule(
//       id: id.hashCode,
//       title: title,
//       body: body,
//       scheduledDate: scheduledDate,
//       notificationDetails: _notificationDetails(),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }

//   /// 🕒 2. جدولة إشعارات الحجز (قبل يوم وقبل ساعة تلقائياً)
//   static Future<void> scheduleBookingReminders({
//     required String bookingId,
//     required String title,
//     required DateTime eventDateTime, // تاريخ ووقت الحفلة/الحجز
//   }) async {
//     final tz.TZDateTime eventTz = tz.TZDateTime.from(eventDateTime, tz.local);
//     final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

//     // 🔴 1. إشعار قبل الحجز بيوم (24 ساعة)
//     final tz.TZDateTime oneDayBefore = eventTz.subtract(
//       const Duration(days: 1),
//     );
//     if (oneDayBefore.isAfter(now)) {
//       await localNotificationsPlugin.zonedSchedule(
//         id: '${bookingId}_1day'.hashCode,
//         title: 'تذكير بالحجز غداً 📅',
//         body:
//             'لديك حجز ($title) غداً في تمام الساعة ${DateFormat('hh:mm a').format(eventDateTime)}',
//         scheduledDate: oneDayBefore,
//         notificationDetails: _notificationDetails(),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       );
//     }

//     // 🟡 2. إشعار قبل الحجز بساعة واحدة
//     final tz.TZDateTime oneHourBefore = eventTz.subtract(
//       const Duration(hours: 1),
//     );
//     if (oneHourBefore.isAfter(now)) {
//       await localNotificationsPlugin.zonedSchedule(
//         id: '${bookingId}_1hour'.hashCode,
//         title: 'تذكير بالحجز بعد ساعة ⏰',
//         body: 'اقترب موعد حجز ($title)، يرجى الاستعداد!',
//         scheduledDate: oneHourBefore,
//         notificationDetails: _notificationDetails(),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       );
//     }
//   }

//   /// ❌ إلغاء الإشعارات المجدولة لحجز معين
//   static Future<void> cancelBookingReminders(String bookingId) async {
//     await localNotificationsPlugin.cancel(id: '${bookingId}_1day'.hashCode);
//     await localNotificationsPlugin.cancel(id: '${bookingId}_1hour'.hashCode);
//   }
// }
