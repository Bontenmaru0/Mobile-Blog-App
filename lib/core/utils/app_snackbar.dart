import 'package:flutter/material.dart';

enum SnackType { success, error, warning, info }

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    SnackType type = SnackType.info,
  }) {
    Color borderColor;
    Color textColor;
    Color backgroundColor;

    switch (type) {
      case SnackType.success:
        borderColor = Colors.black;
        textColor = Colors.green;
        backgroundColor = Colors.white;
        break;

      case SnackType.error:
        borderColor = Colors.black;
        textColor = Color.fromARGB(255, 194, 0, 0);
        backgroundColor = Colors.white;
        break;

      case SnackType.warning:
        borderColor = Colors.black;
        textColor = Colors.orange;
        backgroundColor = Colors.white;
        break;

      case SnackType.info:
        borderColor = Colors.black;
        textColor = Colors.blue;
        backgroundColor = Colors.white;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: borderColor,
            width: 1.5,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
