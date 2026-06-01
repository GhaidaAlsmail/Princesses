// ignore_for_file: avoid_print, depend_on_referenced_packages, deprecated_member_use

import 'dart:convert';
import 'package:princesses/firebase_options.dart';
import 'package:princesses/home/domain/notifications.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'router.dart';
import 'translation.dart';

// 1. تعريف Provider لإدارة تحميل الثيمة من ملف JSON
final themeProvider = FutureProvider<ThemeData>((ref) async {
  final themeStr = await rootBundle.loadString(
    "assets/themes/light_theme.json",
  );
  final themeJson = jsonDecode(themeStr);
  return buildThemeFromJson(themeJson);
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print("Firebase initialized successfully");
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print("لم يتم منح إذن الإشعارات");
    }
  } catch (e) {
    BotToast.closeAllLoading();
  }

  await NotificationService().init();
  usePathUrlStrategy();

  // تحميل الترجمات
  await MyI18n.loadTranslations();
  Locale local = const Locale("ar", "AR");

  runApp(
    I18n(
      initialLocale: local,
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. مراقبة حالة الثيمة
    final themeAsyncValue = ref.watch(themeProvider);

    return themeAsyncValue.when(
      data: (themeData) => MaterialApp.router(
        title: 'Al-Amiraat',
        theme: themeData,
        builder: BotToastInit(),
        routerConfig: ref.watch(router),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: const [Locale("ar", "AR")],
        debugShowCheckedModeBanner: false,
      ),
      // واجهة تظهر أثناء تحميل ملف الثيمة
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      // واجهة تظهر في حال حدوث خطأ في تحميل ملف الثيمة
      error: (err, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text("خطأ في تحميل الثيمة: $err"))),
      ),
    );
  }
}

ThemeData buildThemeFromJson(Map<String, dynamic> json) {
  // استخراج الـ colorScheme من ملف الـ JSON
  final colorSchemeJson = json['colorScheme'] as Map<String, dynamic>;

  return ThemeData(
    useMaterial3: true, // تأكدي من تفعيلها ليتناسق الزهر مع النظام الجديد
    // بناء الـ ColorScheme بالكامل من الملف
    colorScheme: ColorScheme(
      brightness: json['brightness'] == 'dark'
          ? Brightness.dark
          : Brightness.light,
      primary: _parseColor(colorSchemeJson['primary']),
      onPrimary: _parseColor(colorSchemeJson['onPrimary']),
      primaryContainer: _parseColor(colorSchemeJson['primaryContainer']),
      onPrimaryContainer: _parseColor(colorSchemeJson['onPrimaryContainer']),
      secondary: _parseColor(colorSchemeJson['secondary']),
      onSecondary: _parseColor(colorSchemeJson['onSecondary']),
      error: _parseColor(colorSchemeJson['error']),
      onError: _parseColor(colorSchemeJson['onError']),
      surface: _parseColor(colorSchemeJson['surface']),
      onSurface: _parseColor(colorSchemeJson['onSurface']),
      // أضيفي بقية الألوان إذا احتجتِ، أو سيعوضها فلاتر تلقائياً
    ),

    scaffoldBackgroundColor: _parseColor(colorSchemeJson['surface']),

    appBarTheme: AppBarTheme(
      // هنا نجعل الـ AppBar يأخذ لون الـ surface أو أي لون زهري فاتح تختارينه
      backgroundColor: _parseColor(colorSchemeJson['surface']),
      foregroundColor: _parseColor(colorSchemeJson['onSurface']),
      elevation: 0,
    ),

    textTheme: TextTheme(
      bodyMedium: TextStyle(
        color: _parseColor(colorSchemeJson['onSurface']),
        fontSize: (json['fontSize'] ?? 14).toDouble(),
      ),
    ),
  );
}

// دالة تحويل كود اللون (Hex) إلى كائن Color
Color _parseColor(String? colorString) {
  if (colorString == null || colorString.isEmpty) return Colors.pink;

  try {
    colorString = colorString.replaceAll('#', '');
    if (colorString.length == 6) {
      colorString = 'FF$colorString';
    }
    return Color(int.parse(colorString, radix: 16));
  } catch (e) {
    return const Color.fromARGB(255, 249, 205, 219);
  }
}

//===============================================================================//
