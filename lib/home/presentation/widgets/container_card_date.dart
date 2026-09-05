// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:princesses/core/presentation/widgets/my_text_field.dart';
import 'package:princesses/home/presentation/widgets/transportation_fare_function.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reactive_forms/reactive_forms.dart';

// 1. تعريف القرى والمناطق التابعة لكل مدينة
const Map<String, List<String>> ruralLocationsByCity = {
  'idleb': [
    'الدانا',
    'كفرتخاريم',
    'أرمناز',
    'سرمدا',
    'سرمين',
    'أريحا',
    'دركوش',
    'جسر الشغور',
    'الجانودية',
  ],
  // 'idleb': [
  //   'الدانا / كفرتخاريم',
  //   'سرمدا / أرمناز',
  //   'أريحا / سرمين',
  //   'جسر الشغور / دركوش',
  //   'الجانودية',
  // ],
  'aleppo': ['ريف حلب الغربي', 'إعزاز', 'الباب', 'عفرين'],
  'homs': ['الرستن', 'تلبيسة', 'الحولة'],
  'Damascus': ['الغوطة الشرقية', 'دوما', 'الكسوة'],
};

class ContainerCardDate extends StatefulWidget {
  const ContainerCardDate({super.key});

  @override
  _ContainerCardDateState createState() => _ContainerCardDateState();
}

class _ContainerCardDateState extends State<ContainerCardDate> {
  @override
  Widget build(BuildContext context) {
    final form = ReactiveForm.of(context) as FormGroup;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(80),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // قائمة اختيار المدينة الرئيسية
          ReactiveDropdownField<String>(
            formControlName: 'city',
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: 'اختر المدينة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.primary.withAlpha(100),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'idleb',
                child: Text(' إدلب', style: TextStyle(fontFamily: "Amiri")),
              ),
              DropdownMenuItem(
                value: 'aleppo',
                child: Text('حلب', style: TextStyle(fontFamily: "Amiri")),
              ),
              DropdownMenuItem(
                value: 'homs',
                child: Text('حمص', style: TextStyle(fontFamily: "Amiri")),
              ),
              DropdownMenuItem(
                value: 'Damascus',
                child: Text('دمشق', style: TextStyle(fontFamily: "Amiri")),
              ),
            ],
            onChanged: (_) {
              form.control('ruralLocation').updateValue('');
              calculateAppointmentPricing(form);
            },
          ),
          const Gap(15),

          // سويتش تحديد ما إذا كان الموقع ريفاً أم لا
          ReactiveSwitchListTile(
            formControlName: 'isRural',
            title: const Text(
              'هل الموقع ريف؟',
              style: TextStyle(fontFamily: "Amiri", fontSize: 20),
            ),
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (control) {
              if (!(control.value as bool)) {
                form.control('ruralLocation').updateValue('');
                form.control('hasCar').updateValue(false);
              }
              calculateAppointmentPricing(form);
            },
          ),

          // مراقبة حالة السويتش وحالة المدينة المختارة معاً
          ReactiveValueListenableBuilder<bool>(
            formControlName: 'isRural',
            builder: (context, ruralControl, child) {
              if (ruralControl.value == true) {
                return ReactiveValueListenableBuilder<String>(
                  formControlName: 'city',
                  builder: (context, cityControl, child) {
                    final selectedCity = cityControl.value ?? 'idleb';
                    final availableRuralLocations =
                        ruralLocationsByCity[selectedCity] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(10),
                        // القائمة المنسدلة لاختيار منطقة الريف
                        ReactiveDropdownField<String>(
                          formControlName: 'ruralLocation',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'اختر منطقة الريف لحساب النقل المستحق',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (control) =>
                              calculateAppointmentPricing(form),
                          items: [
                            ...availableRuralLocations.map((loc) {
                              return DropdownMenuItem<String>(
                                value: loc,
                                child: Text(
                                  loc,
                                  style: const TextStyle(
                                    fontFamily: "Amiri",
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }),
                            const DropdownMenuItem<String>(
                              value: 'غير ذلك',
                              child: Text(
                                'غير ذلك (تحديد يدوي)',
                                style: TextStyle(
                                  fontFamily: "Amiri",
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),

                        // سويتش حجز السيارة
                        ReactiveSwitchListTile(
                          formControlName: 'hasCar',
                          title: const Text(
                            'هل تريد حجز سيارة؟',
                            style: TextStyle(fontFamily: "Amiri", fontSize: 20),
                          ),
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (_) => calculateAppointmentPricing(form),
                        ),

                        // 🌟 التحكم الذكي بظهور حقول الإدخال اليدوية
                        ReactiveFormConsumer(
                          builder: (context, formGroup, child) {
                            final selectedLocation = formGroup
                                .control('ruralLocation')
                                .value
                                ?.toString();
                            final isRuralChecked =
                                formGroup.control('isRural').value as bool? ??
                                false;
                            final hasCarChecked =
                                formGroup.control('hasCar').value as bool? ??
                                false;

                            // الشرط الأساسي: يجب أن يكون الريف مفعلاً واختار "غير ذلك"
                            if (isRuralChecked &&
                                selectedLocation == 'غير ذلك') {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                ),
                                child: Row(
                                  children: [
                                    // 1. حقل اسم المنطقة: يظهر مباشرة عند اختيار "غير ذلك"
                                    Expanded(
                                      flex: 2,
                                      child: MyTextField(
                                        hintText: "اسم المنطقة...",
                                        formControlName: "customRuralLocation",
                                        nextAction: TextInputAction.next,
                                        fillColor: Colors.white,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        suffixIcon:
                                            Icons.edit_location_alt_rounded,
                                      ),
                                    ),

                                    // نضع مسافة بين الحقلين فقط إذا كان حقل الأجور سيظهر
                                    if (hasCarChecked)
                                      const SizedBox(width: 10),

                                    // 2. حقل أجور النقل: لا يظهر إلا إذا تم تفعيل سويتش السيارة أيضاً
                                    if (hasCarChecked)
                                      Expanded(
                                        flex: 1,
                                        child: ReactiveTextField<String>(
                                          formControlName:
                                              'customTransportFees',
                                          keyboardType: TextInputType.number,
                                          onChanged: (control) {
                                            //  نستدعي الدالة لتحديث الحسابات مع كل حرف يكتبه المستخدم
                                            calculateAppointmentPricing(form);
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'أجور النقل',
                                            // ... باقي الستاينغ
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const Gap(5),
                      ],
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Gap(15),

          MyTextField(
            hintText: "اسم الصالة",
            formControlName: "place",
            nextAction: TextInputAction.next,
            fillColor: Colors.white,
            suffixIcon: Icons.place_outlined,
            color: Theme.of(context).colorScheme.scrim,
            validationMessages: {
              ValidationMessage.required: (_) => 'الرجاء إدخال اسم الصالة',
            },
          ),
          const Gap(20),

          ReactiveSwitchListTile(
            formControlName: 'hasMediator',
            title: const Text(
              'هل يوجد وسيط؟',
              style: TextStyle(fontFamily: "Amiri", fontSize: 14),
            ),
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (control) {
              if (!(control.value as bool)) {
                form.control('mediator').updateValue('');
              }
              calculateAppointmentPricing(form);
            },
          ),

          ReactiveValueListenableBuilder<bool>(
            formControlName: 'hasMediator',
            builder: (context, control, child) {
              if (control.value == true) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: MyTextField(
                    hintText: "اسم الوسيط",
                    formControlName: "mediator",
                    nextAction: TextInputAction.next,
                    fillColor: Colors.white,
                    color: Theme.of(context).colorScheme.primary,
                    suffixIcon: Icons.help_outline_outlined,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Gap(20),

          ReactiveTextField<DateTime>(
            formControlName: 'date',
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: 'اختر التاريخ',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                fontFamily: "Amiri",
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              errorStyle: const TextStyle(fontFamily: "Amiri"),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary.withAlpha(100),
              ),
            ),
            valueAccessor: DateTimeValueAccessor(),
            onTap: (control) async {
              final DateTime now = DateTime.now();
              final DateTime safeFirstDate = DateTime(
                now.year,
                now.month,
                now.day,
              );
              DateTime initialDate = control.value ?? safeFirstDate;

              if (initialDate.isBefore(safeFirstDate)) {
                initialDate = safeFirstDate;
              }

              final DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: safeFirstDate,
                lastDate: DateTime(now.year + 5),
              );

              if (selectedDate == null) return;

              TimeOfDay initialTime = TimeOfDay.fromDateTime(
                control.value ?? now,
              );
              final TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: initialTime,
              );

              final DateTime finalDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime?.hour ?? initialTime.hour,
                selectedTime?.minute ?? initialTime.minute,
              );

              if (finalDateTime.isBefore(now)) {
                control.updateValue(now);
              } else {
                control.updateValue(finalDateTime);
              }
            },
            validationMessages: {
              ValidationMessage.required: (_) => 'الرجاء اختيار تاريخ الحجز',
            },
          ),
        ],
      ),
    );
  }
}
