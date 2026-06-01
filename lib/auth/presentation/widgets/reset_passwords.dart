// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

Future<void> resetPassword(FormGroup form, BuildContext context) async {
  final email = form.control("email").value?.toString().trim();

  if (email == null || email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("يرجى إدخال البريد الإلكتروني أولاً"),
        backgroundColor: Color.fromARGB(255, 242, 121, 113),
      ),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
        backgroundColor: Color.fromARGB(255, 255, 173, 200),
      ),
    );
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.message ?? "حدث خطأ أثناء إرسال البريد الإلكتروني",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("حدث خطأ غير متوقع"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
