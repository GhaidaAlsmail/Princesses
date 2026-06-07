import 'package:phone_numbers_parser/phone_numbers_parser.dart';

String formatPhoneNumber(String rawPhone) {
  if (rawPhone.isEmpty) return "لا يوجد";

  // 🌟 تنظيف النص من الفراغات أو الرموز الزائدة
  String cleanPhone = rawPhone.replaceAll(RegExp(r'[\s\-]'), '');

  // 🌟 إذا كان الرقم يبدأ بـ +963963 أو 00963963 (تكرار النداء السوري كمثال)
  if (cleanPhone.startsWith('+963963')) {
    cleanPhone = '+${cleanPhone.substring(4)}'; // حذف الـ 963 الأولى الزائدة
  } else if (cleanPhone.startsWith('00963963')) {
    cleanPhone = '+${cleanPhone.substring(5)}';
  }

  try {
    final parsed = PhoneNumber.parse(cleanPhone);
    return parsed.international;
  } catch (_) {
    // الكود الاحتياطي القديم لديكِ لحالات nsn:
    if (cleanPhone.contains("nsn:")) {
      final regExp = RegExp(r'nsn:\s*(\d+)');
      final match = regExp.firstMatch(cleanPhone);
      if (match != null && match.group(1) != null) {
        return "+963 ${match.group(1)}";
      }
    }
    return cleanPhone;
  }
}
