// // ignore_for_file: avoid_print

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'auth_service.g.dart';

// @riverpod
// AuthService authService(Ref ref) => AuthService();

// class AuthService {
//   AuthService() {
//     _firebaseAuth = FirebaseAuth.instance;
//   }

//   late FirebaseAuth _firebaseAuth;
//   User? get currenUser => _firebaseAuth.currentUser;

//   Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

//   Future<UserCredential?> createUserWithEmailAndPassword({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       UserCredential userCredential = await _firebaseAuth
//           .createUserWithEmailAndPassword(email: email, password: password);

//       // Send email verification
//       await userCredential.user?.sendEmailVerification();
//       return userCredential;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<UserCredential?> signInWIthEmailANdPass({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       UserCredential userCredential = await _firebaseAuth
//           .signInWithEmailAndPassword(email: email, password: password);
//       return userCredential;
//     } catch (e) {
//       print("Error during sign-in: $e");
//       return null;
//     }
//   }

//   Future<void> resetPassword({required String email}) async {
//     try {
//       await _firebaseAuth.sendPasswordResetEmail(email: email);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> signOut() async {
//     await _firebaseAuth.signOut();
//   }

//   Future<void> resendVerificationEmail() async {
//     final user = _firebaseAuth.currentUser;
//     if (user != null && !user.emailVerified) {
//       await user.reload();
//       await user.sendEmailVerification();
//     }
//   }
// }
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(Ref ref) => AuthService();

class AuthService {
  AuthService() {
    _firebaseAuth = FirebaseAuth.instance;
  }

  late FirebaseAuth _firebaseAuth;
  User? get currenUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Send email verification
      await userCredential.user?.sendEmailVerification();
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWIthEmailANdPass({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } catch (e) {
      print("Error during sign-in: $e");
      return null;
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // تعديل دالة تسجيل الخروج لإلغاء اشتراكات الإشعارات تلقائياً
  Future<void> signOut({String? userId}) async {
    try {
      final uid = userId ?? _firebaseAuth.currentUser?.uid;

      if (uid != null && uid.isNotEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('appUsers')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          final rawCity = data?['city'] as String? ?? '';
          final isAdmin = data?['isAdmin'] as bool? ?? false;

          // إلغاء اشتراك الأدمن
          if (isAdmin) {
            await FirebaseMessaging.instance.unsubscribeFromTopic('admins');
          }

          // إلغاء اشتراك المدينة
          if (rawCity.isNotEmpty) {
            final cleanCity = rawCity.trim().toLowerCase().replaceAll(
              RegExp(r'[^a-zA-Z0-9_]'),
              '_',
            );
            await FirebaseMessaging.instance.unsubscribeFromTopic(
              'city_$cleanCity',
            );
          }
        }
      }
    } catch (e) {
      print("Error unsubscribing from topics during sign out: $e");
    } finally {
      await _firebaseAuth.signOut();
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.reload();
      await user.sendEmailVerification();
    }
  }
}
