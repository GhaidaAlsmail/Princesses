// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSplashScreen.withScreenRouteFunction(
//       splashIconSize: 500,
//       splash: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [Image.asset("assets/images/logo.png")],
//         ),
//       ),
//       splashTransition: SplashTransition.scaleTransition,
//       animationDuration: Duration(seconds: 2),
//       screenRouteFunction: () async {
//         await Future.delayed(Duration(seconds: 1)).then((value) {
//           // ignore: use_build_context_synchronously
//           context.pushReplacement('/');
//         });
//         return "/";
//       },
//     );
//   }
// }
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenRouteFunction(
      splashIconSize: 700,
      splash: Image.asset(
        "assets/images/logo.png",
        // height: 1500,
        // width: 1500,
        fit: BoxFit.contain,
      ),

      splashTransition: SplashTransition.slideTransition,
      animationDuration: Duration(seconds: 5),
      screenRouteFunction: () async {
        await Future.delayed(Duration(seconds: 3)).then((value) {
          // ignore: use_build_context_synchronously
          context.pushReplacement('/');
        });

        return "/";
      },
    );
  }
}
