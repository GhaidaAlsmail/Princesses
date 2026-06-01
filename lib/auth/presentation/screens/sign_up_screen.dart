// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:princesses/auth/application/auth_notifier_provider.dart';
import 'package:princesses/auth/application/sign_up_form_provider.dart';
import 'package:princesses/auth/domain/app_user.dart';
import 'package:princesses/core/presentation/widgets/button.dart';
import 'package:princesses/core/presentation/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    var form = ref.read(signUpFormProvider);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.4),
              Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.4),

              Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ReactiveForm(
            formGroup: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(150),
                Image.asset('assets/images/no_photo.png', fit: BoxFit.cover),

                Text(
                  "الاسم",
                  style: TextStyle(
                    fontFamily: "Amiri",
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 25,
                  ),
                ),
                Gap(5),
                MyTextField(
                  hintText: "الاسم",
                  formControlName: "userName",
                  nextAction: TextInputAction.next,
                  fillColor: Colors.white,
                  color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                ),
                const Gap(20),
                Text(
                  "الايميل",
                  style: TextStyle(
                    fontFamily: "Amiri",
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 25,
                  ),
                ),
                Gap(5),
                MyTextField(
                  hintText: "example@gmail.com",
                  formControlName: "email",
                  nextAction: TextInputAction.next,
                  fillColor: Colors.white,
                  color: Theme.of(context).colorScheme.scrim,
                ),
                const Gap(20),
                Text(
                  "كلمة المرور",
                  style: TextStyle(
                    fontFamily: "Amiri",
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 25,
                  ),
                ),
                Gap(5),
                MyTextField(
                  formControlName: "password",
                  hintText: '********',
                  nextAction: TextInputAction.done,
                  fillColor: Colors.white,
                  suffixIcon: Icons.visibility,
                ),
                //============================
                const Gap(20), // مسافة قبل القائمة المنسدلة
                Text(
                  "المدينة", // عنوان حقل القائمة المنسدلة
                  style: TextStyle(
                    fontFamily: "Amiri",
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 25,
                  ),
                ),
                Gap(5),
                ReactiveDropdownField<String>(
                  formControlName: 'country',
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'اختر المدينة',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withAlpha(100),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withAlpha(100),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    errorStyle: const TextStyle(fontFamily: "Amiri"),

                    suffixIcon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(100),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'idleb',
                      child: Text(
                        ' إدلب',
                        style: TextStyle(fontFamily: "Amiri"),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'aleppo',
                      child: Text('حلب', style: TextStyle(fontFamily: "Amiri")),
                    ),
                    DropdownMenuItem(
                      value: 'Homs',
                      child: Text('حمص', style: TextStyle(fontFamily: "Amiri")),
                    ),
                    DropdownMenuItem(
                      value: 'Damascus',
                      child: Text(
                        'دمشق',
                        style: TextStyle(fontFamily: "Amiri"),
                      ),
                    ),
                  ],
                ),
                Gap(10),
                Text(
                  "ملاحظات",
                  style: TextStyle(
                    fontFamily: "Amiri",
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 25,
                  ),
                ),
                Gap(20),
                MyTextField(
                  hintText: "ملاحظات",
                  formControlName: "notes",
                  nextAction: TextInputAction.next,
                  fillColor: Colors.white,
                  color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                ),
                // const Gap(20),
                Gap(40),
                Center(
                  child: ReactiveFormConsumer(
                    builder: (context, formGroup, child) {
                      return MyButton(
                        text: "تسجيل",
                        textColor: Theme.of(context).colorScheme.primary,

                        width: 350,
                        iconColor: Theme.of(context).colorScheme.primary,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withAlpha(150),
                        onpressed: formGroup.invalid
                            ? null
                            : () {
                                var userName = form.control("userName").value;
                                var email = form.control("email").value;
                                var password = form.control("password").value;
                                var city = form.control("country").value;

                                ref
                                    .read(authNotifierProvider.notifier)
                                    .createUserWithEmailAndPassword(
                                      email,
                                      password,
                                      AppUser(
                                        name: userName,
                                        email: email,
                                        city: city,
                                        isAdmin: false,
                                      ),
                                    )
                                    .then((value) {
                                      if (value != null) {
                                        formGroup.reset();
                                        context.pop();
                                      }
                                    });
                              },
                        icon: Icons.login,
                      );
                    },
                  ),
                ),
                Gap(70),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_circle_down_outlined,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(150),
                      size: 40,
                    ),
                    onPressed: () {
                      context.go("/");
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
