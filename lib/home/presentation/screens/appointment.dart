// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'dart:async';
import 'package:princesses/core/presentation/widgets/button.dart';
import 'package:princesses/home/application/appointment_provider.dart';
import 'package:princesses/home/application/booking_notification_helper.dart';
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

      // الاستماع لأي تغيير في قيم الفورم وحساب الأسعار تلقائياً
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
                const ContainerCard(),
                const Gap(10),
                const ContainerCardDate(),
                const Gap(10),
                const ContainerCardMoney(),
                const Gap(20),

                // عرض السعر الإجمالي الكلي المحدث تلقائياً وبدقة عالية
                ReactiveFormConsumer(
                  builder: (context, formGroup, child) {
                    final double covers =
                        double.tryParse(
                          formGroup
                                  .control('coversServicePrice')
                                  .value
                                  ?.toString() ??
                              '0',
                        ) ??
                        0.0;
                    final double memories =
                        double.tryParse(
                          formGroup
                                  .control('memoriesCornerPrice')
                                  .value
                                  ?.toString() ??
                              '0',
                        ) ??
                        0.0;
                    final double safes =
                        double.tryParse(
                          formGroup
                                  .control('safesCornerPrice')
                                  .value
                                  ?.toString() ??
                              '0',
                        ) ??
                        0.0;
                    final double transport =
                        double.tryParse(
                          formGroup
                                  .control('transportFees')
                                  .value
                                  ?.toString() ??
                              '0',
                        ) ??
                        0.0;

                    // مجموع المكونات الفعلي قبل خصم المدفوعات لتجنب المشاكل الحسابية بالواجهة
                    final double totalAmount =
                        covers + memories + safes + transport;

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
                        onpressed: state.isLoading
                            ? null
                            : () async {
                                final computedTransportFees =
                                    calculateAppointmentPricing(form);

                                bool isRuralValue =
                                    form.control("isRural").value as bool? ??
                                    false;
                                String ruralLocationValue =
                                    form.control("ruralLocation").value ?? '';
                                String customRural =
                                    form.control("customRuralLocation").value ??
                                    '';

                                if (isRuralValue &&
                                    (ruralLocationValue == 'غير ذلك' ||
                                        ruralLocationValue.isEmpty)) {
                                  if (customRural.isNotEmpty) {
                                    ruralLocationValue = customRural;
                                  }
                                }

                                final appointment = AppointmentModel(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  name: form.control("name").value ?? '',
                                  place: form.control("place").value ?? '',
                                  mediator:
                                      form.control("mediator").value ?? '',
                                  city: form.control("city").value ?? '',
                                  notes: form.control("notes").value ?? '',
                                  phone:
                                      form.control("phone").value?.toString() ??
                                      '',
                                  date: form.control("date").value as DateTime,
                                  number: form.control("number").value ?? '',
                                  email: form.control("email").value ?? '',
                                  hasMemoriesCorner:
                                      form.control("hasMemoriesCorner").value
                                          as bool? ??
                                      false,
                                  hasSafesCorner:
                                      form.control("hasSafesCorner").value
                                          as bool? ??
                                      false,
                                  hasCoversService:
                                      form.control("hasCoversService").value
                                          as bool? ??
                                      false,
                                  isRural: isRuralValue,
                                  ruralLocation: ruralLocationValue,
                                  transportFees: computedTransportFees,
                                  paid: form.control("paid").value ?? '0',
                                  rest: form.control("rest").value ?? '0',
                                  memoriesCornerPrice:
                                      double.tryParse(
                                        form
                                                .control('memoriesCornerPrice')
                                                .value
                                                ?.toString() ??
                                            '0',
                                      ) ??
                                      0.0,
                                  safesCornerPrice:
                                      double.tryParse(
                                        form
                                                .control('safesCornerPrice')
                                                .value
                                                ?.toString() ??
                                            '0',
                                      ) ??
                                      0.0,
                                  coversServicePrice:
                                      double.tryParse(
                                        form
                                                .control('coversServicePrice')
                                                .value
                                                ?.toString() ??
                                            '0',
                                      ) ??
                                      0.0,
                                );

                                try {
                                  await notifier.add(appointment);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "فشل الاتصال بالشبكة، يرجى التحقق من الإنترنت.",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final currentState = ref.read(
                                  appointmentNotifierProvider,
                                );
                                if (currentState.hasError) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "حدث خطأ: ${currentState.error}",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // فحص حالة المستخدم الحالي (هل هو أدمن؟)
                                final currentUser = ref
                                    .read(currentUserProvider)
                                    .value;
                                final bool isCreatedByAdmin =
                                    currentUser?.isAdmin ?? false;

                                // إرسال إشعار الـ FCM للسيرفر
                                await BookingNotificationHelper.onNewBookingCreated(
                                  assignedUserId: currentUser?.id ?? "",
                                  bookingTitle: appointment.name,
                                  bookingDetails:
                                      "المكان: ${appointment.place} - التاريخ: ${appointment.date}",
                                  isCreatedByAdmin: isCreatedByAdmin,
                                  city: appointment.city,
                                );

                                if (!context.mounted) return;

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
                                );

                                // التنبيهات المحلية وسجل التطبيق الفردي
                                final partyIdStr = appointment.id.toString();
                                final notificationBody =
                                    "موعدك في ${appointment.place} مع ${appointment.name} تاريخ ${appointment.date}";

                                await NotificationService()
                                    .schedulePartyReminders(
                                      partyId: partyIdStr,
                                      title: "لديك موعد",
                                      body: notificationBody,
                                      date: appointment.date,
                                    );

                                ref
                                    .read(notificationsProvider.notifier)
                                    .addNotification(
                                      AppNotification(
                                        id: partyIdStr,
                                        title: "لديك موعد",
                                        body: notificationBody,
                                        date: DateTime.now(),
                                      ),
                                    );

                                await saveNotificationToHistory(
                                  appointment.id.hashCode,
                                  "لديك موعد",
                                  notificationBody,
                                  customId: partyIdStr,
                                );

                                form.reset(
                                  value: {
                                    'phone': PhoneNumber(
                                      nsn: '',
                                      isoCode: IsoCode.SY,
                                    ),
                                    'city':
                                        ref
                                            .read(currentUserProvider)
                                            .value
                                            ?.city ??
                                        'idleb',
                                    'hasMemoriesCorner': false,
                                    'hasSafesCorner': false,
                                    'hasCoversService': false,
                                    'isRural': false,
                                  },
                                  removeFocus: true,
                                );

                                if (!context.mounted) return;
                                context.go("/reservations");
                              },
                        icon: Icons.app_registration_rounded,
                      );
                      // return MyButton(
                      //   text: state.isLoading ? "جارٍ الحفظ..." : "حجز",
                      //   textColor: Colors.white,
                      //   width: 350,
                      //   iconColor: Colors.white,
                      //   fillColor: Theme.of(context).colorScheme.secondary,
                      //   onpressed: state.isLoading
                      //       ? null
                      //       : () async {
                      //           final computedTransportFees =
                      //               calculateAppointmentPricing(form);

                      //           bool isRuralValue =
                      //               form.control("isRural").value as bool? ??
                      //               false;
                      //           String ruralLocationValue =
                      //               form.control("ruralLocation").value ?? '';
                      //           String customRural =
                      //               form.control("customRuralLocation").value ??
                      //               '';

                      //           if (isRuralValue &&
                      //               (ruralLocationValue == 'غير ذلك' ||
                      //                   ruralLocationValue.isEmpty)) {
                      //             if (customRural.isNotEmpty) {
                      //               ruralLocationValue = customRural;
                      //             }
                      //           }

                      //           final appointment = AppointmentModel(
                      //             id: DateTime.now().millisecondsSinceEpoch
                      //                 .toString(),
                      //             name: form.control("name").value ?? '',
                      //             place: form.control("place").value ?? '',
                      //             mediator:
                      //                 form.control("mediator").value ?? '',
                      //             city: form.control("city").value ?? '',
                      //             notes: form.control("notes").value ?? '',
                      //             phone:
                      //                 form.control("phone").value?.toString() ??
                      //                 '',
                      //             date: form.control("date").value as DateTime,
                      //             number: form.control("number").value ?? '',
                      //             email: form.control("email").value ?? '',
                      //             hasMemoriesCorner:
                      //                 form.control("hasMemoriesCorner").value
                      //                     as bool? ??
                      //                 false,
                      //             hasSafesCorner:
                      //                 form.control("hasSafesCorner").value
                      //                     as bool? ??
                      //                 false,
                      //             hasCoversService:
                      //                 form.control("hasCoversService").value
                      //                     as bool? ??
                      //                 false,
                      //             isRural: isRuralValue,
                      //             ruralLocation: ruralLocationValue,
                      //             transportFees: computedTransportFees,
                      //             paid: form.control("paid").value ?? '0',
                      //             rest: form.control("rest").value ?? '0',
                      //             memoriesCornerPrice:
                      //                 double.tryParse(
                      //                   form
                      //                           .control('memoriesCornerPrice')
                      //                           .value
                      //                           ?.toString() ??
                      //                       '0',
                      //                 ) ??
                      //                 0.0,
                      //             safesCornerPrice:
                      //                 double.tryParse(
                      //                   form
                      //                           .control('safesCornerPrice')
                      //                           .value
                      //                           ?.toString() ??
                      //                       '0',
                      //                 ) ??
                      //                 0.0,
                      //             coversServicePrice:
                      //                 double.tryParse(
                      //                   form
                      //                           .control('coversServicePrice')
                      //                           .value
                      //                           ?.toString() ??
                      //                       '0',
                      //                 ) ??
                      //                 0.0,
                      //           );

                      //           try {
                      //             await notifier.add(appointment);
                      //           } catch (e) {
                      //             ScaffoldMessenger.of(context).showSnackBar(
                      //               const SnackBar(
                      //                 content: Text(
                      //                   "فشل الاتصال بالشبكة، يرجى التحقق من الإنترنت.",
                      //                 ),
                      //               ),
                      //             );
                      //             return;
                      //           }

                      //           final currentState = ref.read(
                      //             appointmentNotifierProvider,
                      //           );

                      //           if (currentState.hasError) {
                      //             ScaffoldMessenger.of(context).showSnackBar(
                      //               SnackBar(
                      //                 content: Text(
                      //                   "حدث خطأ: ${currentState.error}",
                      //                 ),
                      //                 backgroundColor: Colors.red,
                      //               ),
                      //             );
                      //             return;
                      //           }

                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             const SnackBar(
                      //               content: Text("تم حفظ الحجز بنجاح!"),
                      //               backgroundColor: Color.fromARGB(
                      //                 255,
                      //                 209,
                      //                 92,
                      //                 131,
                      //               ),
                      //             ),
                      //           );
                      //           final partyIdStr = appointment.id.toString();
                      //           final notificationBody =
                      //               "موعدك في ${appointment.place} مع ${appointment.name} تاريخ ${appointment.date}";

                      //           await NotificationService()
                      //               .schedulePartyReminders(
                      //                 partyId: partyIdStr,
                      //                 title: "لديك موعد",
                      //                 body: notificationBody,
                      //                 date: appointment.date,
                      //               );

                      //           ref
                      //               .read(notificationsProvider.notifier)
                      //               .addNotification(
                      //                 AppNotification(
                      //                   id: partyIdStr,
                      //                   title: "لديك موعد",
                      //                   body: notificationBody,
                      //                   date: DateTime.now(),
                      //                 ),
                      //               );

                      //           await saveNotificationToHistory(
                      //             appointment.id.hashCode,
                      //             "لديك موعد",
                      //             notificationBody,
                      //             customId: partyIdStr,
                      //           );

                      //           form.reset(
                      //             value: {
                      //               'phone': PhoneNumber(
                      //                 nsn: '',
                      //                 isoCode: IsoCode.SY,
                      //               ),
                      //               'city':
                      //                   ref
                      //                       .read(currentUserProvider)
                      //                       .value
                      //                       ?.city ??
                      //                   'idleb',
                      //               'hasMemoriesCorner': false,
                      //               'hasSafesCorner': false,
                      //               'hasCoversService': false,
                      //               'isRural': false,
                      //             },
                      //             removeFocus: true,
                      //           );

                      //           context.go("/reservations");
                      //         },
                      //   icon: Icons.app_registration_rounded,
                      // );
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
