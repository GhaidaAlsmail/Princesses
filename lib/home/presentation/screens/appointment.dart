// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'dart:async';
import 'package:princesses/core/presentation/widgets/button.dart';
import 'package:princesses/home/application/appointment_provider.dart';
import 'package:princesses/home/application/current_user_provider.dart';
import 'package:princesses/home/application/notification_provider.dart';
import 'package:princesses/home/domain/appointment_model.dart';
import 'package:princesses/home/domain/notifications.dart';
import 'package:princesses/home/presentation/widgets/container_card.dart';
import 'package:princesses/home/presentation/widgets/container_card_date.dart';
import 'package:princesses/home/presentation/widgets/container_card_mony.dart';
import 'package:princesses/home/presentation/widgets/heart_row.dart';
import 'package:princesses/home/presentation/widgets/transportation_fare_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart'
    show PhoneNumber, IsoCode;
import 'package:reactive_forms/reactive_forms.dart';

class Appointment extends ConsumerStatefulWidget {
  const Appointment({super.key});

  @override
  ConsumerState<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends ConsumerState<Appointment> {
  StreamSubscription? _formSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = ref.read(appointmentProvider);

      // حساب القيمة الأولية فور فتح الشاشة
      calculateAppointmentPricing(form);

      // الاستماع لأي تغيير في قيم الفورم وحساب الباقي فورااااً
      _formSubscription = form.valueChanges.listen((_) {
        calculateAppointmentPricing(form);
      });
    });
  }

  @override
  void dispose() {
    _formSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.read(appointmentProvider);
    final notifier = ref.read(appointmentNotifierProvider.notifier);
    final state = ref.watch(appointmentNotifierProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.4),
              Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.4),
              Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ReactiveForm(
            formGroup: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(30),
                Row(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                        onPressed: () {
                          context.go("/");
                        },
                      ),
                    ),
                    const Gap(90),
                    Center(
                      child: Text(
                        "حجز موعد",
                        style: TextStyle(
                          fontFamily: "Amiri",
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 35,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    right: 25.0,
                    left: 25,
                    top: 0,
                    bottom: 10,
                  ),
                  child: HeartRow(),
                ),
                const ContainerCard(), // 💡 ملاحظة: الشيك بوكس الجديد يجب وضعه داخل كرت الخدمات هذا أو أسفله مباشرة
                const Gap(10),
                const ContainerCardDate(),
                const Gap(10),
                const ContainerCardMoney(),
                const Gap(20),

                // 🌟 عرض المبلغ الكامل الإجمالي بشكل ديناميكي ومباشر
                ReactiveFormConsumer(
                  builder: (context, formGroup, child) {
                    final double rest =
                        double.tryParse(
                          formGroup.control('rest').value?.toString() ?? '0',
                        ) ??
                        0.0;
                    final double paid =
                        double.tryParse(
                          formGroup.control('paid').value?.toString() ?? '0',
                        ) ??
                        0.0;
                    final double totalAmount = rest + paid;

                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "المبلغ كاملاً: ",
                              style: TextStyle(
                                fontFamily: "Amiri",
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Text(
                              "${totalAmount.toStringAsFixed(0)} \$",
                              style: TextStyle(
                                fontFamily: "Amiri",
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                Center(
                  child: ReactiveFormConsumer(
                    builder: (context, formGroup, child) {
                      return MyButton(
                        text: state.isLoading ? "جارٍ الحفظ..." : "حجز",
                        textColor: Colors.white,
                        width: 350,
                        iconColor: Colors.white,
                        fillColor: Theme.of(context).colorScheme.secondary,
                        onpressed: () async {
                          final computedTransportFees =
                              calculateAppointmentPricing(form);

                          final appointment = AppointmentModel(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: form.control("name").value ?? '',
                            place: form.control("place").value ?? '',
                            mediator: form.control("mediator").value ?? '',
                            city: form.control("city").value ?? '',
                            notes: form.control("notes").value ?? '',
                            phone:
                                form.control("phone").value?.toString() ?? '',
                            date: form.control("date").value as DateTime,
                            number: form.control("number").value ?? '',
                            email: form.control("email").value ?? '',
                            paid: form.control("paid").value ?? '',
                            rest: form.control("rest").value ?? '',
                            hasMemoriesCorner:
                                form.control("hasMemoriesCorner").value
                                    as bool? ??
                                false,
                            hasSafesCorner:
                                form.control("hasSafesCorner").value as bool? ??
                                false,

                            // 🛠️ تثبيت القيمة المضافة لخدمة الكفرات في الموديل عند الإرسال
                            hasCoversService:
                                form.control("hasCoversService").value
                                    as bool? ??
                                false,

                            isRural:
                                form.control("isRural").value as bool? ?? false,
                            ruralLocation:
                                form.control("ruralLocation").value ?? '',
                            transportFees: computedTransportFees,
                          );
                          await notifier.add(appointment);

                          await NotificationService().schedulePartyReminders(
                            partyId: appointment.id.toString(),
                            title: "لديك موعد",
                            body:
                                "موعدك في ${appointment.name} مع ${appointment.place} تاريخ ${appointment.date}",
                            date: appointment.date,
                          );

                          final container = ProviderScope.containerOf(context);
                          container
                              .read(notificationsProvider.notifier)
                              .addNotification(
                                AppNotification(
                                  title: "لديك موعد",
                                  body:
                                      "موعدك في ${appointment.place} مع ${appointment.name} تاريخ ${appointment.date}",
                                  date: DateTime.now(),
                                ),
                              );
                          await saveNotificationToHistory(
                            appointment.id.hashCode,
                            "لديك موعد",
                            "موعدك في ${appointment.place} مع ${appointment.name} تاريخ ${appointment.date}",
                          );
                          // await NotificationService().saveNotificationToHistory(
                          //   appointment.id.hashCode,
                          //   "لديك موعد",
                          //   "موعدك في ${appointment.place} مع ${appointment.name} تاريخ ${appointment.date}",
                          // );

                          form.reset(
                            value: {
                              'phone': PhoneNumber(
                                nsn: '',
                                isoCode: IsoCode.SY,
                              ),
                              'city':
                                  ref.read(currentUserProvider).value?.city ??
                                  'idleb',
                              // إعادة تعيين الخيارات لقيمها الافتراضية
                              'hasMemoriesCorner': false,
                              'hasSafesCorner': false,
                              'hasCoversService': false,
                              'isRural': false,
                            },
                            removeFocus: true,
                          );

                          context.go("/reservations");

                          state.whenOrNull(
                            data: (_) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("تم حفظ الحجز بنجاح!"),
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      209,
                                      92,
                                      131,
                                    ),
                                  ),
                                ),
                            error: (e, _) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("حدث خطأ: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                          );
                        },
                        icon: Icons.app_registration_rounded,
                      );
                    },
                  ),
                ),
                const Gap(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
