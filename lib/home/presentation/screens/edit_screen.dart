// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, unnecessary_null_comparison, deprecated_member_use

import 'dart:async';
import 'package:princesses/core/presentation/widgets/button.dart';
import 'package:princesses/home/application/app_provider.dart';
import 'package:princesses/home/application/appointment_provider.dart';
import 'package:princesses/home/application/notification_provider.dart';
import 'package:princesses/home/domain/notifications.dart';
import 'package:princesses/home/presentation/widgets/container_card.dart';
import 'package:princesses/home/presentation/widgets/container_card_date.dart';
import 'package:princesses/home/presentation/widgets/container_card_mony.dart';
import 'package:princesses/home/presentation/widgets/heart_row.dart';
import 'package:princesses/home/presentation/widgets/transportation_fare_function.dart'; // دالة الحسابات الذكية
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n_extension/default.i18n.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:reactive_forms/reactive_forms.dart';

class EditAppScreen extends ConsumerStatefulWidget {
  final String appId;
  const EditAppScreen({super.key, required this.appId});

  @override
  ConsumerState<EditAppScreen> createState() => _EditAppScreenState();
}

class _EditAppScreenState extends ConsumerState<EditAppScreen> {
  StreamSubscription? _formSubscription;

  @override
  void dispose() {
    _formSubscription?.cancel();
    super.dispose();
  }

  void _setupFormListener(FormGroup form) {
    _formSubscription?.cancel();

    // الحساب الأولي الفوري عند فتح الشاشة وحقن البيانات
    calculateAppointmentPricing(form);

    // الاستماع للتغيرات في الحقول المؤثرة لتحديث الحسابات فوراً أثناء التعديل
    _formSubscription = form.valueChanges.listen((_) {
      calculateAppointmentPricing(form);
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.read(appointmentProvider);
    final notifier = ref.read(updateAppointmentNotifierProvider.notifier);
    final appAsync = ref.watch(getAppProvider(widget.appId));

    ref.listen(updateAppointmentNotifierProvider, (previous, next) {
      next.when(
        loading: () {
          BotToast.showLoading();
        },
        data: (_) {
          BotToast.closeAllLoading();
          BotToast.showText(text: "تم حفظ التعديلات بنجاح");
          if (context.mounted) {
            context.go("/reservation-details/${widget.appId}");
          }
        },
        error: (e, st) {
          BotToast.closeAllLoading();
          BotToast.showText(text: "حدث خطأ أثناء التعديل");
        },
      );
    });

    return Container(
      // نضع الخلفية المتدرجة هنا لتشمل كامل الشاشة بما فيها الـ AppBar
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.6),
            Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6),
            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          ],
        ),
      ),
      child: Scaffold(
        // جعل خلفية السكافولد شفافة لتظهر الخلفية المتدرجة من تحته
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go("/reservations");
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
            ),
          ),
          title: Center(
            child: Text(
              "تعديل حجز".i18n,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary.withAlpha(150),
                fontSize: 40,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: const [SizedBox(width: 48)],
        ),
        extendBodyBehindAppBar: false,
        body: appAsync.when(
          data: (app) {
            if (app == null) {
              return const Center(child: Text("Appointment not found!"));
            }

            /// ملء الحقول بالبيانات المتاحة داخل الـ Model
            if (!form.control("name").touched) {
              PhoneNumber? parsedPhone;
              try {
                parsedPhone = app.phone != null && app.phone.isNotEmpty
                    ? PhoneNumber.parse(app.phone)
                    : null;
              } catch (_) {}

              form.patchValue({
                "name": app.name,
                "phone": parsedPhone,
                "notes": app.notes,
                "place": app.place,
                "mediator": app.mediator,
                "city": app.city,
                "number": app.number,
                "email": app.email,
                "paid": app.paid,
                "rest": app.rest,
                "date": app.date,
                "isRural": app.isRural,
                "ruralLocation": app.ruralLocation,
                "hasMemoriesCorner": app.hasMemoriesCorner,
                "hasSafesCorner": app.hasSafesCorner,
                "hasCoversService": app.hasCoversService,
                "transportFees": app.transportFees,
                "memoriesCornerPrice": app.memoriesCornerPrice,
                "safesCornerPrice": app.safesCornerPrice,
                "coversServicePrice": app.coversServicePrice,
                "hasCar": app.transportFees > 0,
              });

              _setupFormListener(form);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: ReactiveForm(
                formGroup: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: HeartRow(),
                    ),
                    const SizedBox(height: 15),
                    const ContainerCard(),
                    const SizedBox(height: 10),
                    const ContainerCardDate(),
                    const SizedBox(height: 10),
                    const ContainerCardMoney(),
                    const SizedBox(height: 25),
                    Center(
                      child: ReactiveFormConsumer(
                        builder: (context, formGroup, child) {
                          return MyButton(
                            text: "حفظ التعديلات".i18n,
                            textColor: Theme.of(context).colorScheme.primary,
                            width: 350,
                            iconColor: Theme.of(context).colorScheme.primary,
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.secondary.withAlpha(150),
                            onpressed: () async {
                              final phoneValue =
                                  form.control("phone").value as PhoneNumber?;
                              final phoneString =
                                  phoneValue?.international ?? app.phone;

                              final updatedApp = app.copyWith(
                                name: form.control("name").value,
                                place: form.control("place").value,
                                mediator: form.control("mediator").value,
                                city: form.control("city").value,
                                notes: form.control("notes").value,
                                phone: phoneString,
                                date: form.control("date").value,
                                number: form.control("number").value,
                                paid: form.control("paid").value,
                                rest: form.control("rest").value,
                                isRural:
                                    form.control("isRural").value as bool? ??
                                    false,
                                ruralLocation:
                                    form
                                        .control("ruralLocation")
                                        .value
                                        ?.toString() ??
                                    '',
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
                                transportFees:
                                    double.tryParse(
                                      form
                                          .control("transportFees")
                                          .value
                                          .toString(),
                                    ) ??
                                    0.0,
                                memoriesCornerPrice:
                                    double.tryParse(
                                      form
                                          .control("memoriesCornerPrice")
                                          .value
                                          .toString(),
                                    ) ??
                                    0.0,
                                safesCornerPrice:
                                    double.tryParse(
                                      form
                                          .control("safesCornerPrice")
                                          .value
                                          .toString(),
                                    ) ??
                                    0.0,
                                coversServicePrice:
                                    double.tryParse(
                                      form
                                          .control("coversServicePrice")
                                          .value
                                          .toString(),
                                    ) ??
                                    0.0,
                              );

                              await notifier.update(updatedApp);

                              // ----------------------- التنبيهات المحلية ---------------------
                              await NotificationService().updatePartyReminder(
                                partyId: updatedApp.id.toString(),
                                title: updatedApp.name,
                                body:
                                    "موعدك في ${updatedApp.place} مع ${updatedApp.name}",
                                date: updatedApp.date,
                              );

                              // ----------------------- سجل الإشعارات داخل التطبيق ---------------------
                              final notificationsNotifier = ref.read(
                                notificationsProvider.notifier,
                              );
                              final currentNotifications = ref.read(
                                notificationsProvider,
                              );
                              final bodyText =
                                  "موعدك في ${updatedApp.place} مع ${updatedApp.name} تاريخ ${updatedApp.date}";

                              // البحث عن الإشعار المرتبط بهذا الحجز تحديداً عبر id الحجز
                              final existingNotificationIndex =
                                  currentNotifications.indexWhere(
                                    (n) => n.id == updatedApp.id.toString(),
                                  );

                              if (existingNotificationIndex != -1) {
                                // تحديث الإشعار المنسوب لهذا الحجز بعينه
                                await notificationsNotifier
                                    .updateNotificationById(
                                      id: updatedApp.id.toString(),
                                      newTitle: "لديك موعد",
                                      newBody: bodyText,
                                    );
                              } else {
                                // إضافة إشعار جديد مخصص لهذا الحجز برقم الـ id الخاص به
                                await notificationsNotifier.addNotification(
                                  AppNotification(
                                    id: updatedApp.id.toString(),
                                    title: "لديك موعد",
                                    body: bodyText,
                                    date: DateTime.now(),
                                  ),
                                );
                              }

                              context.go("/reservations");
                              // if (!context.mounted) return;
                            },
                            icon: Icons.app_registration_rounded,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }
}
