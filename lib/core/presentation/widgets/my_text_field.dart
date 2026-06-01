// // ignore_for_file: library_private_types_in_public_api

// import 'package:flutter/material.dart';
// import 'package:reactive_forms/reactive_forms.dart';

// class MyTextField extends StatefulWidget {
//   const MyTextField({
//     super.key,
//     required this.formControlName,
//     required this.hintText,
//     this.icon,
//     this.color,
//     this.fillColor,
//     required TextInputAction nextAction,
//     this.opscureText,
//     this.suffixIcon,
//     this.validationMessages,
//     required void Function(Control) onChanged,
//   });

//   final String formControlName;
//   final String hintText;
//   final IconData? icon;
//   final IconData? suffixIcon;
//   final Color? color;
//   final Color? fillColor;
//   final bool? opscureText;
//   final Map<String, String Function(dynamic)>? validationMessages; //

//   @override
//   _MyTextFieldState createState() => _MyTextFieldState();
// }

// class _MyTextFieldState extends State<MyTextField> {
//   bool _isFocused = false;
//   bool obscureText = false; // حالة إخفاء النص
//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       onFocusChange: (hasFocus) {
//         setState(() {
//           _isFocused = hasFocus;
//         });
//       },
//       child: ReactiveTextField<String>(
//         formControlName: widget.formControlName,
//         obscureText: obscureText,
//         validationMessages: widget.validationMessages,
//         decoration: InputDecoration(
//           labelText: _isFocused ? widget.hintText : null,
//           labelStyle: const TextStyle(color: Colors.grey),
//           hintText: !_isFocused ? widget.hintText : null,
//           hintStyle: const TextStyle(color: Colors.grey),
//           filled: true,
//           fillColor: widget.fillColor ?? Theme.of(context).colorScheme.primary,
//           suffixIcon: widget.suffixIcon != null
//               ? IconButton(
//                   color: Theme.of(context).colorScheme.primary.withAlpha(70),
//                   icon: widget.suffixIcon == Icons.visibility
//                       ? Icon(
//                           obscureText ? Icons.visibility : Icons.visibility_off,
//                         )
//                       : Icon(widget.suffixIcon),

//                   onPressed: () {
//                     setState(() {
//                       obscureText = !obscureText; // تغيير الحالة عند الضغط
//                     });
//                   },
//                 )
//               : null,
//           prefixIcon: widget.icon != null
//               ? Icon(widget.icon, color: Theme.of(context).colorScheme.surface)
//               : null,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(25),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(25),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(25),
//             borderSide: BorderSide.none,
//           ),
//         ),
//         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//           color: Theme.of(context).colorScheme.onSurface,
//         ),
//       ),
//     );
//   }
// }
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({
    super.key,
    required this.formControlName,
    required this.hintText,
    this.icon,
    this.color,
    this.fillColor,
    this.nextAction, // جعلناه اختيارياً أيضاً لضمان مرونة المكون
    this.opscureText,
    this.suffixIcon,
    this.validationMessages,
    this.onChanged, // أصبح حقلاً اختيارياً هنا
  });

  final String formControlName;
  final String hintText;
  final IconData? icon;
  final IconData? suffixIcon;
  final Color? color;
  final Color? fillColor;
  final bool? opscureText;
  final TextInputAction? nextAction;
  final Map<String, String Function(dynamic)>? validationMessages;

  // تعريف الـ onChanged ليتعامل مع الـ FormControl الخاص بـ ReactiveForms بشكل سليم
  final void Function(FormControl<String>)? onChanged;

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isFocused = false;
  bool obscureText = false; // حالة إخفاء النص

  @override
  void initState() {
    super.initState();
    // تهيئة حالة الإخفاء بناءً على القيمة الممررة للمكون إن وجدت
    obscureText = widget.opscureText ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: ReactiveTextField<String>(
        formControlName: widget.formControlName,
        obscureText: obscureText,
        validationMessages: widget.validationMessages,
        textInputAction: widget.nextAction,

        // ربط الـ onChanged الخاص بالـ ReactiveTextField مباشرة
        onChanged: widget.onChanged,

        decoration: InputDecoration(
          labelText: _isFocused ? widget.hintText : null,
          labelStyle: const TextStyle(color: Colors.grey, fontFamily: "Amiri"),
          hintText: !_isFocused ? widget.hintText : null,
          hintStyle: const TextStyle(color: Colors.grey, fontFamily: "Amiri"),
          filled: true,
          fillColor: widget.fillColor ?? Theme.of(context).colorScheme.primary,
          suffixIcon: widget.suffixIcon != null
              ? IconButton(
                  color: Theme.of(context).colorScheme.primary.withAlpha(70),
                  icon: widget.suffixIcon == Icons.visibility
                      ? Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        )
                      : Icon(widget.suffixIcon),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText; // تغيير الحالة عند الضغط
                    });
                  },
                )
              : null,
          prefixIcon: widget.icon != null
              ? Icon(widget.icon, color: Theme.of(context).colorScheme.surface)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontFamily: "Amiri",
        ),
      ),
    );
  }
}
