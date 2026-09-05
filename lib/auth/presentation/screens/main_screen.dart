// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously, avoid_print, prefer_conditional_assignment, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:princesses/auth/application/app_user_service.dart';
import 'package:princesses/auth/application/auth_notifier_provider.dart';
import 'package:princesses/auth/application/log_in_form_provider.dart';
import 'package:princesses/auth/domain/app_user.dart';
import 'package:princesses/auth/presentation/widgets/reset_passwords.dart';
import 'package:princesses/core/presentation/widgets/button.dart';
import 'package:princesses/core/presentation/widgets/my_text_field.dart';
import 'package:princesses/home/domain/url_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:i18n_extension/default.i18n.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Color appBarColor;
  const MainScreen({super.key, required this.appBarColor});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    var form = ref.read(logInFormProvider);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: -130,
              child: Image.asset(
                "assets/images/logo.png",
                height: 500,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: ReactiveForm(
                formGroup: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          "assets/images/heart.png",
                          width: MediaQuery.of(context).size.width * 0.9,
                          fit: BoxFit.contain,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 70,
                            horizontal: 95.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyTextField(
                                validationMessages: {
                                  ValidationMessage.required: (_) =>
                                      'الرجاء إدخال البريد الإلكتروني',
                                  ValidationMessage.email: (_) =>
                                      'الرجاء إدخال بريد إلكتروني صحيح',
                                },
                                formControlName: "email",
                                hintText: "example@gmail.com",
                                icon: Icons.email,
                                nextAction: TextInputAction.next,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.8),
                              ),
                              const Gap(20),
                              MyTextField(
                                validationMessages: {
                                  ValidationMessage.required: (_) =>
                                      'الرجاء إدخال كلمة المرور',
                                  ValidationMessage.minLength: (_) =>
                                      'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
                                },
                                formControlName: "password",
                                hintText: "********",
                                icon: Icons.lock,
                                suffixIcon: Icons.visibility,
                                nextAction: TextInputAction.done,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.8),
                              ),
                              const Gap(10),
                              Align(
                                alignment: AlignmentDirectional.center,
                                child: ReactiveValueListenableBuilder(
                                  formControlName: "email",
                                  builder: (context, control, child) {
                                    return TextButton(
                                      onPressed: () =>
                                          resetPassword(form, context),

                                      child: Text(
                                        "هل نسيت كلمة المرور؟".i18n,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Amiri",
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Gap(60),
                    // زر تسجيل الدخول
                    ReactiveFormConsumer(
                      builder: (context, formGroup, child) {
                        return MyButton(
                          fillColor: Theme.of(context).colorScheme.primary,
                          text: "تسجيل دخول".i18n,
                          textColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          icon: Icons.login,
                          iconColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          onpressed: formGroup.invalid
                              ? () {
                                  formGroup.markAllAsTouched();
                                }
                              : () {
                                  var email = formGroup.control("email").value;
                                  var password = formGroup
                                      .control("password")
                                      .value;
                                  debugPrint(
                                    "Email: $email, Password: $password",
                                  );
                                  ref
                                      .read(authNotifierProvider.notifier)
                                      .signInWithEmailAndPassword(
                                        email,
                                        password,
                                      );

                                  context.go("/home");
                                  //formGroup.reset();
                                },
                        );
                      },
                    ),

                    const Gap(40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Gap(10),

                        Tooltip(
                          message: "تواصل معنا على الوتس",
                          child: InkWell(
                            onTap: openWhatsApp,
                            child: Image.asset(
                              "assets/images/whats.png",
                              height: 45,
                              width: 45,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Tooltip(
                          message: "إنشاء حساب جديد",
                          child: InkWell(
                            onTap: () => context.push("/signup"),
                            child: Image.asset(
                              "assets/images/sign up.png",
                              height: 28,
                              width: 28,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Tooltip(
                          message: "facebook",
                          child: InkWell(
                            onTap: openFacebook,
                            child: Image.asset(
                              "assets/images/face.png",
                              height: 45,
                              width: 45,
                            ),
                          ),
                        ),
                        const Gap(10),

                        Tooltip(
                          message: "تسجيل الدخول عبر Gmail",
                          child: InkWell(
                            onTap: () async {
                              if (!mounted) return;

                              try {
                                // إنشاء GoogleSignIn مع اختيار الحساب
                                final googleSignIn = GoogleSignIn(
                                  scopes: ['email', 'profile'],
                                  signInOption: SignInOption.standard,
                                );

                                // إلغاء أي تسجيل دخول سابق لضمان اختيار الحساب
                                await googleSignIn.signOut();

                                // اختيار الحساب
                                final googleUser = await googleSignIn.signIn();
                                if (googleUser == null) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "تم إلغاء تسجيل الدخول بواسطة المستخدم",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final googleAuth =
                                    await googleUser.authentication;

                                final credential =
                                    GoogleAuthProvider.credential(
                                      idToken: googleAuth.idToken,
                                      accessToken: googleAuth.accessToken,
                                    );

                                final userCredential = await FirebaseAuth
                                    .instance
                                    .signInWithCredential(credential);

                                final user = userCredential.user;
                                if (user == null) return;

                                if (!mounted) return;
                                final appUserService = ref.read(
                                  appUserServiceProvider,
                                );

                                var existing = await appUserService
                                    .getAccountByEmail(user.email!);
                                if (existing == null) {
                                  existing = await appUserService.createAccount(
                                    AppUser(
                                      id: user.uid,
                                      email: user.email!,
                                      name: user.displayName ?? "",
                                      city: 'homs',
                                    ),
                                  );
                                }

                                // خزّن userId
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString("userId", existing.id!);

                                // حدّث AuthNotifier
                                ref.read(authNotifierProvider.notifier).state =
                                    existing;

                                // تنقل مباشرة إلى صفحة الحجوزات
                                if (mounted) context.go("/reservations");
                              } catch (e) {
                                if (!mounted) return;
                                print("Error during Google Sign-In: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("حدث خطأ أثناء تسجيل الدخول"),
                                  ),
                                );
                              }
                            },
                            child: Image.asset(
                              "assets/images/gmaill.png",
                              height: 38,
                              width: 38,
                            ),
                          ),
                        ),
                        const Gap(10),

                        Tooltip(
                          message: "instagram",
                          child: InkWell(
                            onTap: openInstagram,
                            child: Image.asset(
                              "assets/images/insta.png",
                              height: 45,
                              width: 45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(12),
                    Text("Develpoved by Gh.AlS version: 1.2.0+5"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
