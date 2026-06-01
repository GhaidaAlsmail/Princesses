import 'package:princesses/auth/data/firestore_app_user_repository.dart';
import 'package:princesses/auth/domain/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.watch(firestoreAppUserRepositoryProvider);

    // دالة لتحديث واجهة المستخدم بعد أي تغيير
    Future<void> refreshUsers() async {
      ref.invalidate(firestoreAppUserRepositoryProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المشرفين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => refreshUsers(),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            context.go('/home');
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      // استخدام FutureBuilder لجلب وعرض قائمة المستخدمين
      body: FutureBuilder<List<AppUser>>(
        future: userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا يوجد مستخدمون لعرضهم.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserListItem(
                user: user,
                onUpdate: () =>
                    refreshUsers(), // إعادة تحميل القائمة بعد الإجراء
              );
            },
          );
        },
      ),
    );
  }
}

class UserListItem extends ConsumerWidget {
  final AppUser user;
  final VoidCallback onUpdate; // دالة لإعادة تحميل القائمة

  const UserListItem({required this.user, required this.onUpdate, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.read(firestoreAppUserRepositoryProvider);

    // دالة لتبديل حالة الإدارة

    // دالة للحذف
    Future<void> deleteAccount() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف المستخدم ${user.email}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await userService.deleteUser(userId: user.id, id: '${user.id}');
        onUpdate(); // إعادة تحميل الواجهة
      }
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: user.isAdmin
            ? Colors.pink.shade300
            : Colors.grey.shade400,
        child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U'),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر جعل/إلغاء Admin
          ElevatedButton(
            onPressed: () => userService
                .toggleAdminStatus(user.id!, !user.isAdmin)
                .then((_) => onUpdate()),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isAdmin
                  ? Colors.pink.shade300
                  : Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              user.isAdmin ? 'إلغاء الإدارة' : 'جعله مشرفاً',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          // زر الحذف
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: deleteAccount,
          ),
        ],
      ),
    );
  }
}
