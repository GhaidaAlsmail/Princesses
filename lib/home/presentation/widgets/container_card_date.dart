// // ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

// import 'package:alamirat/core/presentation/widgets/my_text_field.dart';
// import 'package:alamirat/home/presentation/widgets/transportation_fare_function.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:reactive_forms/reactive_forms.dart';

// class ContainerCardDate extends StatefulWidget {
//   const ContainerCardDate({super.key});

//   @override
//   _ContainerCardDateState createState() => _ContainerCardDateState();
// }

// class _ContainerCardDateState extends State<ContainerCardDate> {
//   @override
//   Widget build(BuildContext context) {
//     final form = ReactiveForm.of(context) as FormGroup;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white.withAlpha(80),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ReactiveDropdownField<String>(
//             formControlName: 'city',
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 15,
//                 vertical: 15,
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               hintText: 'اختر المدينة',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25),
//                 borderSide: BorderSide(
//                   color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25),
//                 borderSide: BorderSide(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),
//               suffixIcon: Icon(
//                 Icons.arrow_drop_down,
//                 color: Theme.of(context).colorScheme.primary.withAlpha(100),
//               ),
//             ),
//             items: const [
//               DropdownMenuItem(
//                 value: 'idleb',
//                 child: Text(' إدلب', style: TextStyle(fontFamily: "Amiri")),
//               ),
//               DropdownMenuItem(
//                 value: 'aleppo',
//                 child: Text('حلب', style: TextStyle(fontFamily: "Amiri")),
//               ),
//               DropdownMenuItem(
//                 value: 'Homs',
//                 child: Text('حمص', style: TextStyle(fontFamily: "Amiri")),
//               ),
//               DropdownMenuItem(
//                 value: 'Damascus',
//                 child: Text('دمشق', style: TextStyle(fontFamily: "Amiri")),
//               ),
//             ],
//             onChanged: (_) => calculateAppointmentPricing(form),
//           ),
//           const Gap(15),

//           ReactiveSwitchListTile(
//             formControlName: 'isRural',
//             title: const Text(
//               'هل الموقع ريف؟',
//               style: TextStyle(fontFamily: "Amiri", fontSize: 20),
//             ),
//             activeColor: Theme.of(context).colorScheme.primary,
//             onChanged: (control) {
//               // إذا تم إلغاء تحديد الريف، نقوم بتصفير الموقع وخيار حجز السيارة تلقائياً
//               if (!(control.value as bool)) {
//                 form.control('ruralLocation').updateValue('');
//                 form.control('hasCar').updateValue(false);
//               }
//               calculateAppointmentPricing(form);
//             },
//           ),

//           // تظهر خيارات الريف والسيارة فقط إذا كان الموقع ريفاً
//           ReactiveValueListenableBuilder<bool>(
//             formControlName: 'isRural',
//             builder: (context, control, child) {
//               if (control.value == true) {
//                 return Column(
//                   children: [
//                     const Gap(10),
//                     ReactiveDropdownField<String>(
//                       formControlName: 'ruralLocation',
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         hintText: 'اختر منطقة الريف لحساب النقل المستحق',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       items: ruralTransportPrices.keys.map((loc) {
//                         return DropdownMenuItem(
//                           value: loc,
//                           child: Text(
//                             loc,
//                             style: const TextStyle(
//                               fontFamily: "Amiri",
//                               fontSize: 16,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (_) => calculateAppointmentPricing(form),
//                     ),
//                     const Gap(10),

//                     // زر التبديل (Switch) الجديد الخاص بحجز السيارة
//                     ReactiveSwitchListTile(
//                       formControlName: 'hasCar',
//                       title: const Text(
//                         'هل تريد حجز سيارة؟',
//                         style: TextStyle(fontFamily: "Amiri", fontSize: 20),
//                       ),
//                       activeColor: Theme.of(context).colorScheme.primary,
//                       onChanged: (_) => calculateAppointmentPricing(form),
//                     ),
//                     const Gap(5),
//                   ],
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//           const Gap(15),

//           // MyTextField(
//           //   hintText: "اسم الوسيط",
//           //   formControlName: "mediator",
//           //   nextAction: TextInputAction.next,
//           //   fillColor: Colors.white,
//           //   color: Theme.of(context).colorScheme.primary,
//           //   suffixIcon: Icons.help_outline_outlined,
//           // ),
//           MyTextField(
//             hintText: "اسم الصالة",
//             formControlName: "place",
//             nextAction: TextInputAction.next,
//             fillColor: Colors.white,
//             suffixIcon: Icons.place_outlined,
//             color: Theme.of(context).colorScheme.scrim,
//             validationMessages: {
//               ValidationMessage.required: (_) => 'الرجاء إدخال اسم الصالة',
//             },
//           ),
//           const Gap(20),

//           ReactiveSwitchListTile(
//             formControlName: 'hasMediator',
//             title: const Text(
//               'هل يوجد وسيط؟',
//               style: TextStyle(fontFamily: "Amiri", fontSize: 14),
//             ),
//             activeColor: Theme.of(context).colorScheme.primary,
//             onChanged: (control) {
//               // إذا تم إغلاق خيار الوسيط، نقوم بتفريغ النص تلقائياً
//               if (!(control.value as bool)) {
//                 form.control('mediator').updateValue('');
//               }
//               calculateAppointmentPricing(form);
//             },
//           ),

//           // يظهر حقل إدخال اسم الوسيط فقط إذا كان السويتش مفعلاً
//           ReactiveValueListenableBuilder<bool>(
//             formControlName: 'hasMediator',
//             builder: (context, control, child) {
//               if (control.value == true) {
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
//                   child: MyTextField(
//                     hintText: "اسم الوسيط",
//                     formControlName: "mediator",
//                     nextAction: TextInputAction.next,
//                     fillColor: Colors.white,
//                     color: Theme.of(context).colorScheme.primary,
//                     suffixIcon: Icons.help_outline_outlined,
//                   ),
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//           const Gap(20),

//           ReactiveTextField<DateTime>(
//             formControlName: 'date',
//             readOnly: true,
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 15,
//                 vertical: 15,
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               hintText: 'اختر التاريخ',
//               hintStyle: TextStyle(
//                 color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
//                 fontFamily: "Amiri",
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25),
//                 borderSide: BorderSide(
//                   color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25),
//                 borderSide: BorderSide(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),
//               errorStyle: const TextStyle(fontFamily: "Amiri"),
//               suffixIcon: Icon(
//                 Icons.calendar_today,
//                 color: Theme.of(context).colorScheme.primary.withAlpha(100),
//               ),
//             ),
//             valueAccessor: DateTimeValueAccessor(),
//             onTap: (control) async {
//               final DateTime now = DateTime.now();
//               final DateTime safeFirstDate = DateTime(
//                 now.year,
//                 now.month,
//                 now.day,
//               );
//               DateTime initialDate = control.value ?? safeFirstDate;

//               if (initialDate.isBefore(safeFirstDate)) {
//                 initialDate = safeFirstDate;
//               }

//               final DateTime? selectedDate = await showDatePicker(
//                 context: context,
//                 initialDate: initialDate,
//                 firstDate: safeFirstDate,
//                 lastDate: DateTime(now.year + 5),
//               );

//               if (selectedDate == null) return;

//               TimeOfDay initialTime = TimeOfDay.fromDateTime(
//                 control.value ?? now,
//               );
//               final TimeOfDay? selectedTime = await showTimePicker(
//                 context: context,
//                 initialTime: initialTime,
//               );

//               final DateTime finalDateTime = DateTime(
//                 selectedDate.year,
//                 selectedDate.month,
//                 selectedDate.day,
//                 selectedTime?.hour ?? initialTime.hour,
//                 selectedTime?.minute ?? initialTime.minute,
//               );

//               if (finalDateTime.isBefore(now)) {
//                 control.updateValue(now);
//               } else {
//                 control.updateValue(finalDateTime);
//               }
//             },
//             validationMessages: {
//               ValidationMessage.required: (_) => 'الرجاء اختيار تاريخ الحجز',
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:princesses/core/presentation/widgets/my_text_field.dart';
import 'package:princesses/home/presentation/widgets/transportation_fare_function.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reactive_forms/reactive_forms.dart';

// 1. تعريف القرى والمناطق التابعة لكل مدينة (مأخوذة من أسعارك الرسمية)
const Map<String, List<String>> ruralLocationsByCity = {
  'idleb': [
    'الدانا / كفرتخاريم',
    'سرمدا / أرمناز',
    'أريحا / سرمين',
    'جسر الشغور / دركوش',
    'الجانودية',
  ],
  'aleppo': ['ريف حلب الغربي', 'إعزاز', 'الباب', 'عفرين'],
  'Homs': ['الرستن', 'تلبيسة', 'الحولة'],
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
                value: 'Homs',
                child: Text('حمص', style: TextStyle(fontFamily: "Amiri")),
              ),
              DropdownMenuItem(
                value: 'Damascus',
                child: Text('دمشق', style: TextStyle(fontFamily: "Amiri")),
              ),
            ],
            onChanged: (_) {
              // ذكاء برمجي: إذا غير المستخدم المدينة، نصفر حقل الريف المختار منعاً للتضارب
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

          // 2. ربط مشترك: يراقب حالة السويتش وحالة المدينة المختارة معاً
          ReactiveValueListenableBuilder<bool>(
            formControlName: 'isRural',
            builder: (context, ruralControl, child) {
              if (ruralControl.value == true) {
                return ReactiveValueListenableBuilder<String>(
                  formControlName: 'city',
                  builder: (context, cityControl, child) {
                    final selectedCity = cityControl.value ?? 'idleb';
                    // جلب قائمة المناطق التابعة للمدينة الحالية، وإذا لم توجد نضع قائمة فارغة
                    final availableRuralLocations =
                        ruralLocationsByCity[selectedCity] ?? [];

                    return Column(
                      children: [
                        const Gap(10),
                        ReactiveDropdownField<String>(
                          formControlName: 'ruralLocation',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'اختر منطقة الريف لحساب النقل المستحق',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          // بناء العناصر ديناميكياً بناءً على المحافظة المختارة فوق
                          items: availableRuralLocations.map((loc) {
                            return DropdownMenuItem(
                              value: loc,
                              child: Text(
                                loc,
                                style: const TextStyle(
                                  fontFamily: "Amiri",
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (_) => calculateAppointmentPricing(form),
                        ),
                        const Gap(10),

                        ReactiveSwitchListTile(
                          formControlName: 'hasCar',
                          title: const Text(
                            'هل تريد حجز سيارة؟',
                            style: TextStyle(fontFamily: "Amiri", fontSize: 20),
                          ),
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (_) => calculateAppointmentPricing(form),
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
