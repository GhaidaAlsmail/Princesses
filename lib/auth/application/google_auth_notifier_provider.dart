// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks, avoid_print, prefer_conditional_assignment, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:princesses/auth/application/app_user_service.dart';
import 'package:princesses/auth/application/auth_notifier_provider.dart';
import 'package:princesses/auth/domain/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

Future<void> signInWithGoogle(WidgetRef ref) async {
  try {
    final googleSignIn = GoogleSignIn(
      // signInOption: SignInOption.standard,
      // serverClientId:
      //     "953191066647-1fcgifnngo4iv52qnuo69i55mh8gcsre.apps.googleusercontent.com",
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    final user = userCredential.user;
    if (user == null) return;

    final appUserService = ref.read(appUserServiceProvider);

    var existing = await appUserService.getAccountByEmail(user.email!);

    if (existing == null) {
      existing = await appUserService.createAccount(
        AppUser(
          id: user.uid,
          email: user.email!,
          name: user.displayName ?? "",
          city: '',
        ),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", existing.id!);

    ref.read(authNotifierProvider.notifier).state = existing;
  } catch (e) {
    print("Google login error: $e");
  }
}
