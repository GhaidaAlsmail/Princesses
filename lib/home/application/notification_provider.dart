import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.read = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? date,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "body": body,
    "date": date.toIso8601String(),
    "read": read,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json["id"] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json["title"] ?? '',
      body: json["body"] ?? '',
      date: json["date"] != null
          ? (DateTime.tryParse(json["date"].toString()) ?? DateTime.now())
          : DateTime.now(),
      read: json["read"] ?? false,
    );
  }

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedDate = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      parsedDate = DateTime.tryParse(data['date']) ?? DateTime.now();
    }

    return AppNotification(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      read: data['read'] as bool? ?? false,
      date: parsedDate,
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  static const String _storageKey = "notifications_history";

  NotificationsNotifier() : super([]) {
    _loadFromStorage();
  }

  /// إسناد القائمة القادمة من Firestore للحالة وتحديث التخزين المحلي
  void setNotificationsFromStream(List<AppNotification> list) {
    state = list;
    _saveToStorage();
  }

  /// إضافة إشعار جديد + حفظه
  Future<void> addNotification(AppNotification n) async {
    state = [n, ...state];
    await _saveToStorage();
  }

  // /// تعليم الكل كمقروء + حفظ
  // Future<void> markAllRead() async {
  //   state = state.map((n) => n.copyWith(read: true)).toList();
  //   await _saveToStorage();
  // }
  Future<void> markAllRead() async {
    state = state.map((n) => n.copyWith(read: true)).toList();
    await _saveToStorage();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final collection = FirebaseFirestore.instance
        .collection('appUsers')
        .doc(userId)
        .collection('notifications');

    for (final n in state) {
      batch.update(collection.doc(n.id), {'read': true});
    }

    await batch.commit();
  }

  /// تعليم إشعار واحد كمقروء + حفظ
  Future<void> markRead(int index) async {
    if (index < 0 || index >= state.length) return;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(read: true) else state[i],
    ];
    await _saveToStorage();
  }

  /// حذف إشعار عبر الـ index + حفظ
  Future<void> deleteNotification(int index) async {
    if (index < 0 || index >= state.length) return;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
    await _saveToStorage();
  }

  /// حذف إشعار بواسطة الـ ID الخاص به + حفظ
  // Future<void> deleteNotificationById(String id) async {
  //   state = state.where((notification) => notification.id != id).toList();
  //   await _saveToStorage();
  // }
  /// حذف الإشعار المرتبط بموعد معين (Party/Appointment ID) + حفظ
  // Future<void> removeByPartyId(String partyId) async {
  //   state = state.where((notification) => notification.id != partyId).toList();
  //   await _saveToStorage();
  // }
  /// حذف الإشعار من Firestore والتخزين المحلي
  Future<void> deleteNotificationById(String id) async {
    state = state.where((n) => n.id != id).toList();
    await _saveToStorage();

    // حذف المستند من Firestore
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('appUsers')
            .doc(userId)
            .collection('notifications')
            .doc(id)
            .delete();
      } catch (e) {
        debugPrint("خطأ أثناء حذف الإشعار من Firestore: $e");
      }
    }
  }

  /// حذف الإشعار المرتبط بحجز معين
  Future<void> removeByPartyId(String partyId) async {
    await deleteNotificationById(partyId);
  }

  /// عدد الإشعارات غير المقروءة
  int unreadCount() => state.where((n) => !n.read).length;

  /// تعديل الإشعار بدقة عبر الـ ID
  Future<void> updateNotificationById({
    required String id,
    required String newTitle,
    required String newBody,
  }) async {
    bool updated = false;

    final newState = <AppNotification>[];
    for (final n in state) {
      if (n.id == id) {
        newState.add(n.copyWith(title: newTitle, body: newBody));
        updated = true;
      } else {
        newState.add(n);
      }
    }

    if (updated) {
      state = newState;
      await _saveToStorage();
    }
  }

  /// تعديل الإشعار عن طريق العنوان
  Future<void> updateNotificationByTitle({
    required String title,
    required String newBody,
  }) async {
    bool updated = false;

    final newState = <AppNotification>[];
    for (final n in state) {
      if (n.title == title) {
        newState.add(n.copyWith(body: newBody));
        updated = true;
      } else {
        newState.add(n);
      }
    }

    if (updated) {
      state = newState;
      await _saveToStorage();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      debugPrint("خطأ في حفظ الإشعارات محلياً: $e");
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_storageKey);
      if (savedList == null) return;
      state = savedList
          .map((s) => AppNotification.fromJson(jsonDecode(s)))
          .toList();
    } catch (e) {
      debugPrint("خطأ في تحميل الإشعارات محلياً: $e");
    }
  }
}

// 1. بروفايدر للتحكم المباشر وحفظ التعديلات المحلية
// final notificationsProvider =
//     StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
//       (ref) => NotificationsNotifier(),
//     );
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
      final notifier = NotificationsNotifier();

      // استماع للـ Stream وتحديث الـ State فور ورود بيانات من Firestore
      ref.listen<AsyncValue<List<AppNotification>>>(
        notificationsStreamProvider,
        (previous, next) {
          next.whenData((notifications) {
            notifier.setNotificationsFromStream(notifications);
          });
        },
      );

      return notifier;
    });
// 2. StreamProvider يستمع للتعديلات المباشرة من Firestore بأمان دون التأثير المباشر على المزود الآخر أثناء البناء
final notificationsStreamProvider =
    StreamProvider.autoDispose<List<AppNotification>>((ref) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return Stream.value([]);

      return FirebaseFirestore.instance
          .collection('appUsers')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => AppNotification.fromFirestore(doc))
                .toList();
          });
    });
