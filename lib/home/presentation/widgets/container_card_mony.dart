// ignore_for_file: library_private_types_in_public_api

import 'package:princesses/core/presentation/widgets/my_text_field.dart';
import 'package:princesses/home/presentation/widgets/transportation_fare_function.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ContainerCardMoney extends StatefulWidget {
  const ContainerCardMoney({super.key});

  @override
  _ContainerCardMoneyState createState() => _ContainerCardMoneyState();
}

class _ContainerCardMoneyState extends State<ContainerCardMoney> {
  // معرفة دالة الاستماع للاحتفاظ بها وإلغائها عند إغلاق الكرت لحماية الذاكرة
  dynamic _valueChangesSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // إلغاء أي اشتراك قديم إذا وجد قبل إعادة الربط
    _valueChangesSubscription?.cancel();

    // جلب الـ FormGroup من الـ Context الحالي
    final form = ReactiveForm.of(context) as FormGroup;

    // سر التحديث اللحظي الفوري داخل الكرت:
    // استمع لأي تغيير يحدث في "المدفوع" وقم بعمل الحسبة وإعادة بناء الكرت فوراً
    _valueChangesSubscription = form.valueChanges.listen((_) {
      if (mounted) {
        setState(() {
          calculateAppointmentPricing(form);
        });
      }
    });
  }

  @override
  void dispose() {
    // تنظيف المستمع فور الخروج من الواجهة لضمان عدم تعليق الذاكرة
    _valueChangesSubscription?.cancel();
    super.dispose();
  }

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
          MyTextField(
            hintText: "المبلغ المدفوع",
            suffixIcon: Icons.money,
            formControlName: "paid",
            nextAction: TextInputAction.next,
            fillColor: Colors.white,
            color: Theme.of(context).colorScheme.primary,
            validationMessages: {
              ValidationMessage.required: (_) => 'الرجاء إدخال المبلغ المدفوع',
            },
            // استدعاء مباشر للحسبة لضمان حقن القيمة بالـ FormControl أثناء الكتابة
            onChanged: (control) {
              calculateAppointmentPricing(form);
            },
          ),
          const Gap(25),
          MyTextField(
            hintText: "المبلغ الباقي (يُحسب تلقائياً)",
            formControlName: "rest",
            nextAction: TextInputAction.next,
            fillColor: Colors.white,
            suffixIcon: Icons.money,
            color: Theme.of(context).colorScheme.scrim,
            validationMessages: {
              ValidationMessage.required: (_) =>
                  'الرجاء إدخال المبلغ الباقي إن وجد',
            },
          ),
          const Gap(25),
          MyTextField(
            hintText: " عنوان الصالة المفصل",
            formControlName: "notes",
            nextAction: TextInputAction.next,
            fillColor: Colors.white,
            suffixIcon: Icons.notes,
            color: Theme.of(context).colorScheme.scrim,
            validationMessages: {
              ValidationMessage.required: (_) => 'الرجاء إدخال عنوان مفصل هنا',
            },
          ),
        ],
      ),
    );
  }
}
