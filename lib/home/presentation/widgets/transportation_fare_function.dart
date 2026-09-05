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

// 2. مصفوفة أجور النقل الشاملة
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

/// 💡 دالة حساب السعر الديناميكي مع إضافة 5 دولار لكل 50 ضيف إضافي
double getDynamicPrice(
  Map<String, Map<int, double>> priceTable,
  String locationKey,
  int guests,
) {
  final locationPrices = priceTable[locationKey] ?? {};
  if (locationPrices.isEmpty) return 0.0;

  // الحد الأدنى الأساسي (100 ضيف)
  const int baseGuests = 100;
  final double basePrice = locationPrices[baseGuests] ?? 0.0;

  if (guests <= baseGuests) {
    return basePrice;
  }

  // إذا كان عدد الضيوف موجوداً بالضبط في القائمة
  if (locationPrices.containsKey(guests)) {
    return locationPrices[guests]!;
  }

  // البحث عن أقرب نقطة مرجعية متوفرة في الجدول تكون أقل من أو تساوي عدد الضيوف الحالي
  int refGuests = baseGuests;
  double refPrice = basePrice;

  final sortedKeys = locationPrices.keys.toList()..sort();
  for (int key in sortedKeys) {
    if (guests >= key) {
      refGuests = key;
      refPrice = locationPrices[key]!;
    } else {
      break;
    }
  }

  // حساب كم 50 ضيف زيادة عن آخر سعر مرجعي مسجل
  final int extraGuests = guests - refGuests;
  final int stepsOf50 = (extraGuests / 50).ceil(); // تقريب للأعلى لكل 50 ضيف

  // إضافة 5 دولار زيادة عن كل 50 ضيف
  final double calculatedPrice = refPrice + (5.0 * stepsOf50);

  return double.parse(calculatedPrice.toStringAsFixed(2));
}

double calculateAppointmentPricing(FormGroup form) {
  // 1. جلب عدد الضيوف بأمان
  final numValue = form.control('number').value;
  final int guests = int.tryParse(numValue?.toString() ?? '0') ?? 0;

  final bool isRural = form.control('isRural').value as bool? ?? false;
  final String ruralLoc = form.control('ruralLocation').value?.toString() ?? '';

  // خيار أجور النقل الاختياري
  final bool hasCar = form.control('hasCar').value as bool? ?? false;

  final bool hasMemories =
      form.control('hasMemoriesCorner').value as bool? ?? false;
  final bool hasSafes = form.control('hasSafesCorner').value as bool? ?? false;
  final bool hasCovers =
      form.control('hasCoversService').value as bool? ?? false;

  final String locationKey = isRural ? 'rural' : 'city';

  double totalPrice = 0.0;
  double transportFees = 0.0;

  double currentCoversPrice = 0.0;
  double currentMemoriesPrice = 0.0;
  double currentSafesPrice = 0.0;

  // 2. حساب السعر الديناميكي لخدمة الكفرات
  if (hasCovers) {
    currentCoversPrice = getDynamicPrice(basicPrices, locationKey, guests);
    totalPrice += currentCoversPrice;
  }

  // 3. حساب السعر الديناميكي لركن الذكريات
  if (hasMemories) {
    currentMemoriesPrice = getDynamicPrice(memoriesPrices, locationKey, guests);
    totalPrice += currentMemoriesPrice;
  }

  // 4. حساب السعر الديناميكي لركن الأمانات
  if (hasSafes) {
    currentSafesPrice = getDynamicPrice(safesPrices, locationKey, guests);
    totalPrice += currentSafesPrice;
  }

  // 5. حساب أجور النقل
  if (isRural && hasCar) {
    if (ruralTransportPrices.containsKey(ruralLoc)) {
      transportFees = ruralTransportPrices[ruralLoc]!;
    } else if (ruralLoc == 'غير ذلك') {
      final customFeesValue = form.control('customTransportFees').value;
      transportFees =
          double.tryParse(customFeesValue?.toString() ?? '0') ?? 0.0;
    }
    totalPrice += transportFees;
  }

  // 6. حساب المبلغ المتبقي
  final paidValue = form.control('paid').value;
  final double paid = double.tryParse(paidValue?.toString() ?? '0') ?? 0.0;

  double restValue = totalPrice - paid;
  if (restValue < 0) restValue = 0.0;

  // 7. إسناد القيم للـ Reactive Form
  form
      .control('rest')
      .updateValue(restValue.toStringAsFixed(0), emitEvent: true);

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
