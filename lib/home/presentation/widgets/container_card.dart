// ignore_for_file: library_private_types_in_public_api

import 'package:princesses/core/presentation/widgets/my_text_field.dart';
import 'package:princesses/home/presentation/widgets/transportation_fare_function.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_phone_form_field/reactive_phone_form_field.dart';

class ContainerCard extends StatefulWidget {
  const ContainerCard({super.key});

  @override
  _ContainerCardState createState() => _ContainerCardState();
}

class _ContainerCardState extends State<ContainerCard> {
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
          const Gap(20),
          // الخدمات المطلوبة مدمجة بشكل منسق داخل الكارد الأساسي
          Text(
            "الخدمات المطلوبة:",
            style: TextStyle(
              fontFamily: "Amiri",
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const Gap(15),
          MyTextField(
            hintText: "الاسم",
            formControlName: "name",
            nextAction: TextInputAction.next,
            fillColor: Colors.white,
            color: Theme.of(context).colorScheme.primary,
            validationMessages: {
              ValidationMessage.required: (_) => 'الرجاء إدخال الاسم',
            },
          ),
          const Gap(20),
          MyTextField(
            hintText: "عدد الضيوف",
            formControlName: "number",
            nextAction: TextInputAction.next,
            fillColor: Colors.white,
            suffixIcon: Icons.boy,
            color: Theme.of(context).colorScheme.scrim,
            validationMessages: {
              ValidationMessage.required: (_) => 'الرجاء إدخال عدد الضيوف',
            },
            // إعادة الحساب فوراً عند تغيير عدد الحضور
            onChanged: (control) => calculateAppointmentPricing(form),
          ),
          const Gap(20),
          ReactivePhoneFormField<PhoneNumber>(
            formControlName: 'phone',
            valueAccessor: PhoneNumberValueAccessor(),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: 'أدخل رقم الجوال',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.scrim,
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
                Icons.phone,
                color: Theme.of(context).colorScheme.primary.withAlpha(70),
              ),
            ),
            validationMessages: {
              ValidationMessage.required: (_) => 'الرجاء إدخال رقم الجوال',
            },
          ),
          ReactiveCheckboxListTile(
            formControlName: 'hasMemoriesCorner',
            title: const Text(
              'ركن الذكريات',
              style: TextStyle(fontFamily: "Amiri", fontSize: 20),
            ),
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (_) => calculateAppointmentPricing(form),
          ),
          ReactiveCheckboxListTile(
            formControlName: 'hasSafesCorner',
            title: const Text(
              'ركن الأمانات',
              style: TextStyle(fontFamily: "Amiri", fontSize: 20),
            ),
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (_) => calculateAppointmentPricing(form),
          ),

          //  خدمة الكفرات الجديدة المضافة مع ربط دالة الحسابات والـ Theme المتناسق
          ReactiveCheckboxListTile(
            formControlName: 'hasCoversService',
            title: const Text(
              "ركن الكفرات",
              style: TextStyle(fontFamily: "Amiri", fontSize: 20),
            ),
            // secondary: Icon(
            //   Icons.airline_seat_recline_extra,
            //   color: Theme.of(context).colorScheme.primary.withAlpha(150),
            // ),
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (_) => calculateAppointmentPricing(form),
          ),
          const Gap(10),
        ],
      ),
    );
  }
}
