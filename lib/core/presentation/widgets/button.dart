import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.onpressed,
    required this.text,
    required this.icon,
    this.fillColor,
    this.textColor,
    this.iconColor,
    this.width,
    this.height,
  });

  final Function()? onpressed;
  final String text;
  final IconData icon;
  final Color? fillColor;
  final Color? textColor;
  final Color? iconColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width * 0.5,
      height: height ?? 50,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor:
              fillColor ?? Theme.of(context).colorScheme.surface.withAlpha(140),
        ),

        onPressed: onpressed,
        icon: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.scrim,
        ),
        label: Text(
          text,
          style: TextStyle(
            color: textColor ?? Theme.of(context).colorScheme.scrim,
            fontFamily: "Amiri",
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
