import 'package:princesses/auth/application/auth_notifier_provider.dart';
import 'package:princesses/auth/presentation/screens/main_screen.dart';
import 'package:princesses/auth/presentation/screens/sign_up_screen.dart';
import 'package:princesses/core/global_navigator.dart';
import 'package:princesses/core/presentation/screens/edit_profile_page.dart';
import 'package:princesses/core/presentation/screens/home_page.dart';
import 'package:princesses/core/screens/splash_screen.dart';
import 'package:princesses/excel_file/screen/attendes_screen.dart';
import 'package:princesses/excel_file/screen/event_import_screen.dart';
import 'package:princesses/excel_file/screen/event_list_screen.dart';
import 'package:princesses/excel_file/screen/qr_screen.dart';
import 'package:princesses/home/presentation/screens/appointment.dart';
import 'package:princesses/home/presentation/screens/details_screen.dart';
import 'package:princesses/home/presentation/screens/edit_screen.dart';
import 'package:princesses/admin/presentation/screens/admin_screen.dart';
import 'package:princesses/home/presentation/screens/notification_screen.dart';
import 'package:princesses/home/presentation/screens/reservation__screen.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, _) {
      notifyListeners();
    });
  }
}

final router = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: "/splash", // سيبدأ هنا دائماً بشكل نظيف
    observers: [BotToastNavigatorObserver()],
    refreshListenable: RouterRefreshNotifier(ref),

    routes: [
      GoRoute(
        path: "/splash",
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: "/",
        builder: (context, state) => MainScreen(appBarColor: Colors.white),
      ),
      GoRoute(path: "/home", builder: (context, state) => const HomePage()),
      GoRoute(path: "/admin", builder: (context, state) => const AdminScreen()),
      GoRoute(
        path: "/reservations",
        builder: (context, state) => const ReservationScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/reservation-details/:appId',
        builder: (context, state) {
          // التقاط الـ appId من الـ pathParameters
          final appId = state.pathParameters['appId']!;
          return DetailsAppScreen(appId: appId);
        },
      ),
      GoRoute(
        path: "/notifications",
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventListScreen(),
      ),
      GoRoute(
        path: '/attendees/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return AttendeeListScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/import-event',
        builder: (context, state) => const EventImportScreen(),
      ),
      GoRoute(
        path: '/scanner/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return QrScannerScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: "/appointment",
        builder: (context, state) => const Appointment(),
      ),
      GoRoute(
        path: "/signup",
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: "/edit",
        builder: (context, state) => const EditAppScreen(appId: ''),
      ),
    ],

    redirect: (context, state) async {
      // 🌟 الحل السحري: إذا كان المستخدم في شاشة الـ Splash، لا تفعل أي شيء واترك الأنميشن يعمل
      if (state.fullPath == "/splash") {
        return null;
      }

      String? userId = ref.read(authNotifierProvider)?.id;
      final prefs = SharedPreferencesAsync();
      final savedId = await prefs.getString("userId");

      if (state.fullPath == "/") {
        if (userId == null && (savedId == null || savedId.isEmpty)) {
          return "/";
        } else if (userId == null && savedId != null && savedId.isNotEmpty) {
          return "/splash"; // سيعود للسبلاش إذا كان هناك كاش لتهيئة البيانات
        } else {
          return "/home";
        }
      } else {
        if (userId == null && (savedId == null || savedId.isEmpty)) {
          if (state.fullPath == "/signup") return null;
          return "/";
        } else if (userId == null && savedId != null && savedId.isNotEmpty) {
          return "/reservations";
        } else {
          return null;
        }
      }
    },
  );
});
