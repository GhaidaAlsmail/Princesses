import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:princesses/home/application/notification_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  // دالة تحديد الكل كمقروء في Firestore
  Future<void> _markAllAsRead() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final batch = FirebaseFirestore.instance.batch();
      final query = await FirebaseFirestore.instance
          .collection('appUsers')
          .doc(userId)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      for (var doc in query.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint("خطأ أثناء تحديث الكل كمقروء: $e");
    }
  }

  // دالة تحديث حالة إشعار منفرد
  Future<void> _toggleReadStatus(String id, bool currentReadState) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection('appUsers')
          .doc(userId)
          .collection('notifications')
          .doc(id)
          .update({'read': !currentReadState});
    } catch (e) {
      debugPrint("خطأ في تحديث حالة الإشعار: $e");
    }
  }

  // دالة حذف إشعار
  Future<void> _deleteNotification(String id) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection('appUsers')
          .doc(userId)
          .collection('notifications')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint("خطأ أثناء حذف الإشعار: $e");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifications = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("الإشعارات"),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              "تعيين كمقروء",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: asyncNotifications.when(
        data: (rawNotifications) {
          // فلترة وحذف العناصر المكررة بناءً على n.id
          final notifications = <AppNotification>[];
          final seenIds = <String>{};

          for (var n in rawNotifications) {
            if (seenIds.add(n.id)) {
              notifications.add(n);
            }
          }

          if (notifications.isEmpty) {
            return const Center(
              child: Text("لا يوجد إشعارات", style: TextStyle(fontSize: 20)),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Card(
                color: n.read ? Colors.grey[200] : Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.read ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(n.body),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          n.read ? Icons.check_circle : Icons.mark_email_unread,
                          color: n.read ? Colors.pink : Colors.grey,
                        ),
                        onPressed: () => _toggleReadStatus(n.id, n.read),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => _deleteNotification(n.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text("حدث خطأ في تحميل الإشعارات: $err")),
      ),
    );
  }
}
