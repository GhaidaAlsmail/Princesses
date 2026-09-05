// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:princesses/auth/domain/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_user_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
part 'firestore_app_user_repository.g.dart';

@riverpod
FirestoreAppUserRepository firestoreAppUserRepository(Ref ref) {
  return FirestoreAppUserRepository();
}

class FirestoreAppUserRepository implements AppUserRepository {
  FirestoreAppUserRepository() {
    _firebase = FirebaseFirestore.instance;
  }

  late FirebaseFirestore _firebase;
  final String collectionName = "appUsers";

  @override
  Future<void> saveUserFcmToken(String userId) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && userId.isNotEmpty) {
        await _firebase.collection(collectionName).doc(userId).update({
          'fcmToken': token,
        });
        debugPrint("✅ تم تحديث FCM Token للمستخدم: $userId");
      }
    } catch (e) {
      debugPrint("❌ خطأ أثناء حفظ FCM Token: $e");
    }
  }

  @override
  Future<AppUser> createUser({required AppUser appUser}) async {
    try {
      String docId = appUser.id!;

      var createdUser = appUser.copyWith(id: docId);
      await _firebase
          .collection(collectionName)
          .doc(docId)
          .set(createdUser.toJson());
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUser?> getUserByEmail({required String email}) async {
    try {
      var users = await _firebase
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .get(); // Get all users with this email

      if (users.docs.isNotEmpty) {
        return AppUser.fromJson(users.docs.first.data());
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteUser({required String id, String? userId}) async {
    try {
      final docRef = _firebase.collection(collectionName).doc(id);

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception("المستخدم غير موجود أو تم حذفه مسبقًا.");
      }

      await docRef.delete();
      print(" تم حذف المستخدم بنجاح (ID: $id)");
    } catch (e) {
      print(" خطأ أثناء حذف المستخدم: $e");
      rethrow;
    }
  }

  @override
  Future<AppUser?> readUser({required String id}) async {
    try {
      var users = await _firebase.collection(collectionName).doc(id).get();

      if (users.data() != null) {
        return AppUser.fromJson(users.data()!);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUser({required AppUser appUser}) async {
    try {
      await _firebase
          .collection(collectionName)
          .doc(appUser.id)
          .update(appUser.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<AppUser?> streamUserById({required String id}) {
    return _firebase
        .collection(collectionName)
        .doc(id)
        .snapshots()
        .map((doc) => AppUser.fromJson(doc.data() as Map<String, dynamic>));
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    try {
      // 1. جلب لقطة (Snapshot) لجميع المستندات في المجموعة الصحيحة
      final QuerySnapshot snapshot = await _firebase
          .collection(collectionName)
          .get();

      // 2. تحويل المستندات إلى كائنات AppUser باستخدام fromJson
      final List<AppUser> users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // التأكد من تضمين الـ ID الخاص بالوثيقة في الـ Map إذا لم يكن موجوداً
        // لكننا نفترض أن AppUser.fromJson يمكنه التعامل مع الـ Map
        return AppUser.fromJson(data);
      }).toList();

      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<void> toggleAdminStatus(String uid, bool newStatus) async {
    try {
      await _firebase.collection(collectionName).doc(uid).update({
        'isAdmin': newStatus,
      });
      print("✅ User $uid admin status set to $newStatus.");
    } catch (e) {
      print("❌ Error toggling admin status for user $uid: $e");
      rethrow;
    }
  }
}
