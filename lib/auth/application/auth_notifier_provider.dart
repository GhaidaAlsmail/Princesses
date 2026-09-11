// ignore_for_file: avoid_print

import 'package:princesses/auth/application/app_user_service.dart';
import 'package:princesses/auth/application/auth_service.dart';
import 'package:princesses/auth/domain/app_user.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier extends StateNotifier<AppUser?> {
  final AuthService authService;
  final AppUserService appUserServices;

  // داخل constructor الخاص بـ AuthNotifier:
  AuthNotifier(this.authService, this.appUserServices) : super(null) {
    authService.authStateChanges.listen((user) async {
      if (user == null) {
        state = null;
        return;
      }

      if (user.providerData.any((p) => p.providerId == "password")) {
        if (!user.emailVerified) {
          state = null;
          return;
        }
      }

      state = await appUserServices.getAccountByEmail(user.email ?? "-");

      // 🌟 تحديث الـ Token والاشتراك في الموضوعات للحسابات القديمة والحالية تلقائياً
      if (state != null) {
        await _setupFcmTopics(state!);
      }
    });
  }
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
    AppUser appUser,
  ) async {
    try {
      BotToast.showLoading();
      final credentials = await authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credentials?.user == null) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "خطأ في إنشاء الحساب");
        return null;
      }

      await appUserServices.createAccount(
        appUser.copyWith(id: credentials?.user?.uid ?? ""),
      );
      final createdUser = await appUserServices.getAccountByEmail(email);
      print("Firestore User: ${createdUser?.id}");

      state = await appUserServices.getAccountByEmail(email);
      if (state == null) {
        print("خطأ: لم يتم العثور على المستخدم في Firestore.");
      }

      BotToast.closeAllLoading();
      BotToast.showText(
        text: "لقد تم ارسال البريد الإلكتروني، قم بالتحقق ثم تسجيل الدخول",
      );
      return credentials;
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: "خطأ");
      return null;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      BotToast.showLoading();
      final credentials = await authService.signInWIthEmailANdPass(
        email: email,
        password: password,
      );

      if (credentials?.user == null) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "البريد الإلكتروني أو كلمة المرور غير صحيحة");
        return;
      }

      User? user = credentials!.user;

      await user?.reload();

      user = FirebaseAuth.instance.currentUser;

      if (!user!.emailVerified) {
        BotToast.showText(
          text: "الرجاء التحقق من البريد الإلكتروني قبل تسجيل الدخول",
        );
        BotToast.closeAllLoading();
        return;
      }

      state = await appUserServices.getAccountByEmail(email);
      if (state == null) {
        print("خطأ: لم يتم العثور على المستخدم في Firestore.");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", state?.id ?? "");

      if (state?.id != null && state!.id!.isNotEmpty) {
        await appUserServices.saveUserFcmToken(state!.id!);
        await _setupFcmTopics(state!);
      }

      await FirebaseMessaging.instance.subscribeToTopic('all_users');
      BotToast.closeAllLoading();
    } catch (e) {
      print("خطأ أثناء تسجيل الدخول: $e");
      BotToast.closeAllLoading();
      BotToast.showText(text: "خطأ في البريد الإلكتروني أو كلمة المرور");
    }
  }
  // إضافة الدالة التالية داخل كلاس AuthNotifier:

  Future<void> _setupFcmTopics(AppUser user) async {
    try {
      // 1. حفظ / تحديث الـ Token في Firestore
      if (user.id != null && user.id!.isNotEmpty) {
        await appUserServices.saveUserFcmToken(user.id!);
      }

      // 2. الاشتراك في الموضوع العام
      await FirebaseMessaging.instance.subscribeToTopic('all_users');

      // 3. الاشتراك في topic المدراء إذا كان أدمن
      if (user.isAdmin) {
        await FirebaseMessaging.instance.subscribeToTopic('admins');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('admins');
      }

      // 4. الاشتراك في topic المدينة بحسب المفتاح المنظم
      if (user.city.isNotEmpty) {
        final cityKey = user.city.trim().toLowerCase();
        await FirebaseMessaging.instance.subscribeToTopic('city_$cityKey');
      }
    } catch (e) {
      print("خطأ في إعداد موضوعات الإشعارات: $e");
    }
  }

  // Future<void> logOut() async {
  //   final prefs = SharedPreferencesAsync();
  //   await prefs.setString("userId", "");
  //   await authService.signOut();
  // }
  Future<void> logOut() async {
    final prefs = SharedPreferencesAsync();
    final String? storedUserId = await prefs.getString("userId");

    // مسح المعرف المحلي
    await prefs.setString("userId", "");

    // استدعاء signOut وتمرير الـ userId لإلغاء الاشتراكات
    await authService.signOut(userId: storedUserId);
  }

  Future<void> resetPassword(String email) async {
    try {
      BotToast.showLoading();
      await authService.resetPassword(email: email);
      BotToast.showText(text: "Password changing email has been sent");
      BotToast.closeAllLoading();
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: "Something went wrong");
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      BotToast.showLoading();
      if (authService.currenUser == null) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "سجل دخول أولاً من فضلك");
      } else {
        await authService.resendVerificationEmail();
        BotToast.showText(text: "تم ارسال بريد التحقق");
        BotToast.closeAllLoading();
      }
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: "يوجد خطأ ما");
    }
  }

  Future<void> refreshUser() async {
    try {
      if (authService.currenUser != null) {
        final email = authService.currenUser?.email ?? "";
        state = await appUserServices.getAccountByEmail(email);
      } else {}
    } catch (e) {
      BotToast.showText(text: "يوجد خطأ في التحديث");
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AppUser?>((
  ref,
) {
  final authService = ref.read(authServiceProvider);
  final appUserService = ref.read(appUserServiceProvider);
  return AuthNotifier(authService, appUserService);
});
