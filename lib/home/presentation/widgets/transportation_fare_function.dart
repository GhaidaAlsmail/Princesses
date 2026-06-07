// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

// 1. جداول الأسعار الصريحة المستقلة (تطبق على كافة المدن وأريافها حالياً)
const Map<String, Map<int, double>> basicPrices = {
  'city': {100: 31.0, 150: 36.0, 200: 41.0, 250: 46.0},
  'rural': {100: 36.0, 150: 41.0, 200: 46.0, 250: 51.0},
};

const Map<String, Map<int, double>> memoriesPrices = {
  'city': {100: 36.0, 150: 41.0, 200: 46.0, 250: 51.0},
  'rural': {100: 41.0, 150: 46.0, 200: 51.0, 250: 56.0},
};

const Map<String, Map<int, double>> safesPrices = {
  'city': {100: 36.0, 150: 41.0, 200: 46.0, 250: 51.0},
  'rural': {100: 41.0, 150: 46.0, 200: 51.0, 250: 56.0},
};

// 2. مصفوفة أجور النقل الشاملة لكافة أرياف المحافظات (أسعار مبدئية قابلة للتعديل)
const Map<String, double> ruralTransportPrices = {
  // ريف إدلب
  'الدانا / كفرتخاريم': 36.0,
  'سرمدا / أرمناز': 31.0,
  'أريحا / سرمين': 20.0,
  'جسر الشغور / دركوش': 40.0,
  'الجانودية': 45.0,

  // ريف حلب
  'ريف حلب الغربي': 35.0,
  'إعزاز': 40.0,
  'الباب': 45.0,
  'عفرين': 40.0,

  // ريف حمص
  'الرستن': 30.0,
  'تلبيسة': 25.0,
  'الحولة': 35.0,

  // ريف دمشق
  'الغوطة الشرقية': 30.0,
  'دوما': 35.0,
  'الكسوة': 40.0,
};

double calculateAppointmentPricing(FormGroup form) {
  // 1. جلب عدد الضيوف بأمان
  final numValue = form.control('number').value;
  final int guests = int.tryParse(numValue?.toString() ?? '0') ?? 0;

  final bool isRural = form.control('isRural').value as bool? ?? false;
  final String ruralLoc = form.control('ruralLocation').value?.toString() ?? '';

  final bool hasCar = form.control('hasCar').value as bool? ?? false;
  final bool hasMemories =
      form.control('hasMemoriesCorner').value as bool? ?? false;
  final bool hasSafes = form.control('hasSafesCorner').value as bool? ?? false;
  final bool hasCovers =
      form.control('hasCoversService').value as bool? ?? false;

  final String locationKey = isRural ? 'rural' : 'city';

  // 2. تحديد الفئة المستهدفة للضيوف
  int targetGuests = 100;
  if (guests <= 100) {
    targetGuests = 100;
  } else if (guests <= 150) {
    targetGuests = 150;
  } else if (guests <= 200) {
    targetGuests = 200;
  } else {
    targetGuests = 250;
  }

  double totalPrice = 0.0;
  double transportFees = 0.0;

  double currentCoversPrice = 0.0;
  double currentMemoriesPrice = 0.0;
  double currentSafesPrice = 0.0;

  // 4. حساب سعر خدمة الكفرات الأساسي
  if (hasCovers) {
    currentCoversPrice = basicPrices[locationKey]?[targetGuests] ?? 0.0;
    totalPrice += currentCoversPrice;
  }

  // 5. جمع ركن الذكريات تراكمياً
  if (hasMemories) {
    currentMemoriesPrice = memoriesPrices[locationKey]?[targetGuests] ?? 0.0;
    totalPrice += currentMemoriesPrice;
  }

  // 6. جمع ركن الأمانات تراكمياً
  if (hasSafes) {
    currentSafesPrice = safesPrices[locationKey]?[targetGuests] ?? 0.0;
    totalPrice += currentSafesPrice;
  }

  // 7. جمع أجور النقل (السيارة) بأمان مع فحص الـ null
  if (isRural && hasCar) {
    if (ruralTransportPrices.containsKey(ruralLoc)) {
      transportFees = ruralTransportPrices[ruralLoc]!;
    } else if (ruralLoc == 'غير ذلك') {
      final customFeesValue = form.control('customTransportFees').value;
      // 🌟 فحص آمن: إذا كان فارغاً لا نأخذ القيمة القديمة ولا نتحول لـ "null"
      transportFees =
          double.tryParse(customFeesValue?.toString() ?? '0') ?? 0.0;
    }
    totalPrice += transportFees;
  }

  // 8. حساب المبلغ المتبقي بأمان مع فحص الـ null لحقل المدفوع
  final paidValue = form.control('paid').value;
  final double paid = double.tryParse(paidValue?.toString() ?? '0') ?? 0.0;

  double restValue = totalPrice - paid;

  // 9. تحديث الحقول مباشرة في الـ Form (تحديث باستخدام updateValue لضمان إعادة البناء السليمة)
  form
      .control('rest')
      .updateValue(
        restValue < 0 ? '0' : restValue.toStringAsFixed(0),
        emitEvent: true, // 🌟 يجبر الواجهة على التحديث فوراً
      );

  form.control('transportFees').updateValue(transportFees, emitEvent: true);
  // التعديل هنا: استخدام updateValue بدلاً من الـ value المباشر
  form
      .control('memoriesCornerPrice')
      .updateValue(currentMemoriesPrice, emitEvent: true);
  form
      .control('safesCornerPrice')
      .updateValue(currentSafesPrice, emitEvent: true);
  form
      .control('coversServicePrice')
      .updateValue(currentCoversPrice, emitEvent: true);
  debugPrint(
    "📝 فحص الحسابات -> ركن الأمانات مفعّل؟: $hasSafes | السعر المستخرج: $currentSafesPrice | القيمة المسجلة في الفورم: ${form.control('safesCornerPrice').value}",
  );
  return transportFees;
}
