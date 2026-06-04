// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSplashScreen.withScreenRouteFunction(
//       splashIconSize: 250,
//       splash: Image.asset(
//         "assets/images/logo.png",
//         // height: 1500,
//         // width: 1500,
//         fit: BoxFit.contain,
//       ),

//       splashTransition: SplashTransition.slideTransition,
//       animationDuration: Duration(seconds: 5),
//       screenRouteFunction: () async {
//         await Future.delayed(Duration(seconds: 3)).then((value) {
//           // ignore: use_build_context_synchronously
//           context.pushReplacement('/');
//         });

//         return "/";
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 1. إعداد أنميشن التلاشي (Fade) ليظهر الشعار بنعومة خلال ثانيتين
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // 2. الانتقال إلى الشاشة الرئيسية بعد 4 ثوانٍ الكلية
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pushReplacement('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // لون خلفية الشاشة
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          // هنا التحكم الكامل والحقيقي بحجم الشعار العرضي دون أي قيود مربعة
          child: SizedBox(
            width:
                screenWidth *
                0.85, // 👈 سيأخذ 85% من عرض الشاشة بالكامل ليظهر ضخماً
            child: Image.asset(
              "assets/images/logo.png",
              fit: BoxFit.contain, // يضمن وضوح الشعار وعدم تشوهه
            ),
          ),
        ),
      ),
    );
  }
}
