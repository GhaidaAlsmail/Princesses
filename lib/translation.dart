// // ignore_for_file: strict_top_level_inference

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:i18n_extension/i18n_extension.dart';

class MyI18n {
  static Translations translations = Translations.byLocale("en");

  static Future<void> loadTranslations() async {
    final arJson = await rootBundle.loadString("assets/translation/ar.json");
    // final enJson = await rootBundle.loadString("assets/translation/en.json");

    final Map<String, dynamic> arMap = jsonDecode(arJson);
    // final Map<String, dynamic> enMap = jsonDecode(enJson);

    // تحويل إلى Map<String, String>
    final arStrings = arMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    // final enStrings = enMap.map(
    //   (key, value) => MapEntry(key, value.toString()),
    // );

    // دمج الترجمة الإنجليزية
    // translations += {"en": enStrings};

    // دمج الترجمة العربية
    translations += {"ar": arStrings};
  }
}
