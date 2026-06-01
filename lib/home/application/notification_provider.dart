import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String title;
  final String body;
  final DateTime date;
  final bool read;

  AppNotification({
    required this.title,
    required this.body,
    required this.date,
    this.read = false,
  });

  AppNotification copyWith({
    String? title,
    String? body,
    DateTime? date,
    bool? read,
  }) {
    return AppNotification(
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "body": body,
    "date": date.toIso8601String(),
    "read": read,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      title: json["title"],
      body: json["body"],
      date: DateTime.parse(json["date"]),
      read: json["read"] ?? false,
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super([]) {
    _loadFromStorage();
  }

  /// إضافة إشعار جديد + حفظه
  Future<void> addNotification(AppNotification n) async {
    state = [n, ...state];
    await _saveToStorage();
  }

  /// تعليم الكل كمقروء + حفظ
  Future<void> markAllRead() async {
    state = state.map((n) => n.copyWith(read: true)).toList();
    await _saveToStorage();
  }

  /// تعليم إشعار واحد كمقروء + حفظ
  Future<void> markRead(int index) async {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(read: true) else state[i],
    ];
    await _saveToStorage();
  }

  /// حذف إشعار + حفظ
  Future<void> deleteNotification(int index) async {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
    await _saveToStorage();
  }

  /// عدد الإشعارات غير المقروءة
  int unreadCount() => state.where((n) => !n.read).length;

  /// ✅ دالة تعديل الإشعار عن طريق العنوان
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
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList("notifications", jsonList);
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList("notifications");
    if (savedList == null) return;
    state = savedList
        .map((s) => AppNotification.fromJson(jsonDecode(s)))
        .toList();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      (ref) => NotificationsNotifier(),
    );
