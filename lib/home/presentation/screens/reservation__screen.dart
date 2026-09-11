// ignore_for_file: use_build_context_synchronously, deprecated_member_use, prefer_interpolation_to_compose_strings, depend_on_referenced_packages

import 'package:princesses/home/application/appointment_provider.dart';
import 'package:princesses/home/application/appoitment_service.dart';
import 'package:princesses/home/application/check_box_provider.dart';
import 'package:princesses/home/application/current_user_provider.dart';
import 'package:princesses/home/application/notification_provider.dart';
import 'package:princesses/home/domain/appointment_model.dart';
import 'package:princesses/home/presentation/screens/details_screen.dart';
import 'package:princesses/home/domain/notifications_services.dart';
import 'package:princesses/home/presentation/widgets/transportation_fare_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n_extension/default.i18n.dart';
import 'package:intl/intl.dart';
import 'package:reactive_phone_form_field/reactive_phone_form_field.dart';

class ReservationScreen extends ConsumerWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var form = ref.read(appointmentProvider);
    final myRes = ref.watch(reservationsProvider);
    final checkBoxState = ref.watch(checkBoxProvider);
    final unread = ref
        .watch(notificationsProvider)
        .where((n) => !n.read)
        .length;
    form.valueChanges.listen((_) {
      calculateAppointmentPricing(form);
    });
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go("/home"),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.primary.withAlpha(150),
          ),
        ),
        title: Center(
          child: Text(
            "الحجوزات",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
              fontSize: 40,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
            ),
            onPressed: () async {
              final selectedIds = checkBoxState.entries
                  .where((entry) => entry.value == true)
                  .map((entry) => entry.key)
                  .toList();

              if (selectedIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("الرجاء تحديد حجز للحذف!".i18n)),
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("جاري حذف الحجوزات المحددة...".i18n),
                  duration: const Duration(seconds: 1),
                ),
              );

              try {
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

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("تم حذف الحجوزات المحددة بنجاح".i18n),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                debugPrint("خطأ الحذف التفصيلي: $e");

                if (!context.mounted) return;

                String errorMessage = "حدث خطأ أثناء الحذف: $e".i18n;
                if (e.toString().contains("UnknownHostException") ||
                    e.toString().contains("UNAVAILABLE")) {
                  errorMessage =
                      "تعذر الاتصال بالسيرفر. يرجى التحقق من اتصال الإنترنت في المحاكي."
                          .i18n;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          IconButton(
            onPressed: () {
              context.push("/notifications");
            },
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.primary.withAlpha(150),
                  size: 30,
                ),
                if (unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: myRes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text("Error: $error")),
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
              child: Text(
                "لا يوجد حجوزات".i18n,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Amiri",
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary.withAlpha(150),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentUserProvider);
              ref.invalidate(reservationsProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                AppointmentModel app = apps[index];

                final onlyNumber = app.phone.toString().replaceAll(
                  RegExp(r'[^0-9+]'),
                  '',
                );
                final isSelected = checkBoxState[app.id] ?? false;
                final place = app.place;
                final formattedDate = DateFormat('yyyy-MM-dd').format(app.date);
                final formattedTime = DateFormat('hh:mm a').format(app.date);
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink.withAlpha(80),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.only(top: 6),
                    child: ListTile(
                      titleAlignment: ListTileTitleAlignment.top,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      title: Text(
                        app.name,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          ref.read(checkBoxProvider.notifier).state = {
                            ...ref.read(checkBoxProvider.notifier).state,
                            app.id: value ?? false,
                          };
                        },
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          app.city,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "الهاتف: $onlyNumber",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "التاريخ: $formattedDate",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "الوقت: $formattedTime",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "الصالة: $place",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                      ),
                      onTap: () {
                        // 🌟 التعديل هنا: يفتح صفحة التفاصيل أولاً ويمرر معها الـ ID
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
      ),
      floatingActionButton: FloatingActionButton.large(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        backgroundColor: Colors.pinkAccent.withAlpha(30),
        onPressed: () {
          form.reset(
            value: {'phone': PhoneNumber(nsn: '', isoCode: IsoCode.SY)},
            removeFocus: true,
          );
          context.go("/appointment");
        },
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
