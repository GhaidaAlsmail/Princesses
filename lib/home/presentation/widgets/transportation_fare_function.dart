import 'package:reactive_forms/reactive_forms.dart';

// 1. جداول الأسعار الصريحة المستقلة
const Map<String, Map<int, double>> basicPrices = {
  'city': {
    100: 31.0,
    150: 36.0,
    200: 41.0,
    250: 46.0,
    300: 51.0,
    400: 61.0,
    450: 66.0,
    500: 71.0,
  },
  'rural': {100: 36.0, 150: 41.0, 200: 46.0, 250: 51.0},
};

const Map<String, Map<int, double>> memoriesPrices = {
  'city': {
    100: 36.0,
    150: 41.0,
    200: 46.0,
    250: 51.0,
    300: 51.0,
    400: 61.0,
    450: 66.0,
    500: 71.0,
  },
  'rural': {100: 41.0, 150: 46.0, 200: 51.0, 250: 56.0},
};

const Map<String, Map<int, double>> safesPrices = {
  'city': {
    100: 36.0,
    150: 41.0,
    200: 46.0,
    250: 51.0,
    300: 51.0,
    400: 61.0,
    450: 66.0,
    500: 71.0,
  },
  'rural': {100: 41.0, 150: 46.0, 200: 51.0, 250: 56.0},
};

// 2. مصفوفة أجور النقل الشاملة لكافة أرياف المحافظات
const Map<String, double> ruralTransportPrices = {
  'الدانا': 36.0,
  'سرمدا': 31.0,
  'أريحا': 20.0,
  'جسر الشغور': 40.0,
  'كفرتخاريم': 36.0,
  'أرمناز': 31.0,
  'سرمين': 20.0,
  'دركوش': 40.0,
  'الجانودية': 45.0,
  'ريف حلب الغربي': 35.0,
  'إعزاز': 40.0,
  'الباب': 45.0,
  'عفرين': 40.0,
  'الرستن': 30.0,
  'تلبيسة': 25.0,
  'الحولة': 35.0,
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

  // خيار أجور النقل الاختياري حسب الزر بالواجهة
  final bool hasCar = form.control('hasCar').value as bool? ?? false;

  final bool hasMemories =
      form.control('hasMemoriesCorner').value as bool? ?? false;
  final bool hasSafes = form.control('hasSafesCorner').value as bool? ?? false;
  final bool hasCovers =
      form.control('hasCoversService').value as bool? ?? false;

  final String locationKey = isRural ? 'rural' : 'city';

  // 2. تحديد الفئة المستهدفة للضيوف بدقة
  int targetGuests = 100;
  if (guests <= 100) {
    targetGuests = 100;
  } else if (guests <= 150) {
    targetGuests = 150;
  } else if (guests <= 200) {
    targetGuests = 200;
  } else if (guests <= 250) {
    targetGuests = 250;
  } else if (guests <= 300) {
    targetGuests = 300;
  } else if (guests <= 400) {
    targetGuests = 400;
  } else if (guests <= 450) {
    targetGuests = 450;
  } else {
    targetGuests = 500;
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

  // 7. حساب أجور النقل بشكل اختياري تماماً بناءً على زر السيارة (hasCar)
  if (isRural && hasCar) {
    if (ruralTransportPrices.containsKey(ruralLoc)) {
      transportFees = ruralTransportPrices[ruralLoc]!;
    } else if (ruralLoc == 'غير ذلك') {
      final customFeesValue = form.control('customTransportFees').value;
      transportFees =
          double.tryParse(customFeesValue?.toString() ?? '0') ?? 0.0;
    }
    totalPrice += transportFees; // إضافة أجور النقل إلى الإجمالي الكلي
  }

  // 8. حساب المبلغ المتبقي بناءً على الإجمالي الشامل
  final paidValue = form.control('paid').value;
  final double paid = double.tryParse(paidValue?.toString() ?? '0') ?? 0.0;

  double restValue = totalPrice - paid;
  if (restValue < 0) restValue = 0.0;

  // 9. إسناد القيم بناءً على الأنواع الدقيقة لكل حقل في الـ FormGroup لمنع الـ TypeError

  // حقل المتبقي (rest) معرّف كـ String
  form
      .control('rest')
      .updateValue(restValue.toStringAsFixed(0), emitEvent: true);

  // حقول الأسعار والأجور معرّفة كـ double
  form.control('transportFees').updateValue(transportFees, emitEvent: false);
  form
      .control('memoriesCornerPrice')
      .updateValue(currentMemoriesPrice, emitEvent: false);
  form
      .control('safesCornerPrice')
      .updateValue(currentSafesPrice, emitEvent: false);
  form
      .control('coversServicePrice')
      .updateValue(currentCoversPrice, emitEvent: false);

  return transportFees;
}
