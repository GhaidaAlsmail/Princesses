// import 'package:intl/intl.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class localNotification {
//   static FlutterLocalNotificationsPlugin localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future init() async {
//     InitializationSettings initializationSettings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     );
//     localNotificationsPlugin.initialize(
//       initializationSettings,
//     );
//   }

//   static void schduledNotification(
//     String id,
//     String title,
//     String body,
//     String prayerTime,
//   ) async {
//     NotificationDetails details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         "id",
//         "schduled",
//         playSound: true,
//         importance: Importance.max,
//         priority: Priority.high,
//         sound: RawResourceAndroidNotificationSound('notification.mp3'.split('.').first),
//       ),
//     );

//     final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
//     tz.initializeTimeZones();
//     tz.setLocalLocation(tz.getLocation(currentTimeZone));
//     final DateTime now = DateTime.now();
//     final DateTime prayerDateTime = DateFormat('h:mm a').parse(prayerTime);

//     tz.TZDateTime timenotification = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       prayerDateTime.hour,
//       prayerDateTime.minute,
//     );
//     await localNotificationsPlugin.zonedSchedule(
//       id.hashCode,
//       title,
//       body,
//       timenotification,
//       details,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }
// }
