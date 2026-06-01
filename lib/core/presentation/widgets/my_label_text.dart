import 'package:flutter/material.dart';

Widget buildLabel(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontFamily: "Amiri",
        color: Theme.of(context).primaryColor,
      ),
    ),
  );
}
