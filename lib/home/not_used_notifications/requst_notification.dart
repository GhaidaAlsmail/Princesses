// // ignore_for_file: use_build_context_synchronously, unnecessary_import
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Future<void> showNotificationPermissionDialog(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//   bool shouldShowDialog = prefs.getBool('show_notification_dialog') ?? true;
//   if (shouldShowDialog) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text(
//           "السماح بالإشعارات",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).colorScheme.primary,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.notifications_active,
//               size: 60,
//               color: Theme.of(context).colorScheme.secondary,
//             ),
//             SizedBox(height: 15),
//             Text(
//               "لتصلك تنبيهات مواقيت الصلاة والأذكار المهمة، يرجى السماح بالإشعارات",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Theme.of(context).colorScheme.onSurface,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//         actions: [
//           Row(
//             children: [
//               SizedBox(width: 10),
//               Expanded(
//                 child: TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () async {
//                     Navigator.pop(context);
//                     prefs.setBool('show_notification_dialog', false);
//                     await Permission.notification.request();
//                   },
//                   child: Text(
//                     "السماح الآن",
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
