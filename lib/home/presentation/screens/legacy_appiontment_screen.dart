import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:princesses/home/application/app_provider.dart';
import 'package:princesses/home/application/appoitment_service.dart';
import 'package:princesses/home/application/check_box_provider.dart';
import 'package:princesses/home/application/notification_provider.dart';
import 'package:princesses/home/domain/notifications_services.dart';
import 'package:princesses/home/presentation/screens/details_screen.dart';
import 'package:intl/intl.dart';

class LegacyAppointmentsListScreen extends ConsumerWidget {
  const LegacyAppointmentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legacyAppsAsync = ref.watch(legacyAppointmentsProvider);
    final checkBoxState = ref.watch(checkBoxProvider);

    // تجميع المعرفات المختارة التي قيمتها true
    final selectedIds = checkBoxState.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    return legacyAppsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text(
            "الحجوزات السابقة العامة",
            style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: const Text(
            "الحجوزات السابقة العامة",
            style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
          ),
        ),
        body: Center(child: Text("خطأ: $err")),
      ),
      data: (apps) {
        final bool isAllSelected =
            apps.isNotEmpty &&
            apps.every((app) => checkBoxState[app.id] == true);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "الحجوزات السابقة العامة",
              style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
            ),
            actions: [
              if (apps.isNotEmpty) ...[
                // زر تحديد الكل / إلغاء تحديد الكل
                IconButton(
                  icon: Icon(
                    isAllSelected
                        ? Icons.select_all_rounded
                        : Icons.deselect_rounded,
                  ),
                  tooltip: isAllSelected ? "إلغاء تحديد الكل" : "تحديد الكل",
                  onPressed: () {
                    final updatedState = <String, bool>{};
                    for (var app in apps) {
                      updatedState[app.id] = !isAllSelected;
                    }
                    ref.read(checkBoxProvider.notifier).state = updatedState;
                  },
                ),
                // زر الحذف للتطبيقات المحددة
                if (selectedIds.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: "حذف المحددة",
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("تأكيد الحذف"),
                          content: Text(
                            "هل أنت تأكد من حذف ${selectedIds.length} من الحجوزات؟",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("إلغاء"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                "حذف",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final service = ref.read(appoitmentServiceProvider);
                        await Future.wait(
                          selectedIds.map((id) async {
                            await service.deleteAppointment(id);
                            await NotificationService().cancelPartyReminder(id);
                            ref
                                .read(notificationsProvider.notifier)
                                .removeByPartyId(id);
                          }),
                        );

                        if (!context.mounted) return;
                        ref.read(checkBoxProvider.notifier).state = {};
                      }
                    },
                  ),
              ],
            ],
          ),
          body: apps.isEmpty
              ? const Center(
                  child: Text(
                    "لا توجد حجوزات في المجلد الرئيسي القديم",
                    style: TextStyle(fontSize: 18, fontFamily: "Amiri"),
                  ),
                )
              : ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final isSelected = checkBoxState[app.id] ?? false;
                    final formattedDate = DateFormat(
                      'yyyy-MM-dd',
                    ).format(app.date);

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.deepPurple.withOpacity(0.5)
                              : Colors.deepPurple.withAlpha(80),
                          borderRadius: BorderRadius.circular(15),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 1.5)
                              : null,
                        ),
                        child: ListTile(
                          title: Text(
                            app.name,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Checkbox(
                            value: isSelected,
                            activeColor: Colors.white,
                            checkColor: Colors.deepPurple,
                            onChanged: (value) {
                              ref.read(checkBoxProvider.notifier).state = {
                                ...ref.read(checkBoxProvider.notifier).state,
                                app.id: value ?? false,
                              };
                            },
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "المدينة: ${app.city}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                "التاريخ: $formattedDate",
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                "الصالة: ${app.place}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailsAppScreen(appId: app.id),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
