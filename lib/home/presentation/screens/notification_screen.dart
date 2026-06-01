import 'package:princesses/home/application/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("الإشعارات"),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllRead();
            },
            child: Text("تعيين كمقروء", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text("لا يوجد إشعارات", style: TextStyle(fontSize: 20)),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Card(
                  color: n.read ? Colors.grey[300] : Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(n.title),
                    subtitle: Text(n.body),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر تعيين كمقروء
                        IconButton(
                          icon: Icon(
                            n.read
                                ? Icons.check_circle
                                : Icons.mark_email_unread,
                            color: n.read ? Colors.pink : Colors.grey,
                          ),
                          onPressed: () {
                            ref
                                .read(notificationsProvider.notifier)
                                .markRead(index);
                          },
                        ),
                        // زر حذف الإشعار
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            ref
                                .read(notificationsProvider.notifier)
                                .deleteNotification(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
