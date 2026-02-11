import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); // private constructor

  static const _seedColor = Colors.black;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.black,
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionColor: Colors.black26,
        selectionHandleColor: Colors.black,
      ),

      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.black),
        hintStyle: TextStyle(color: Colors.grey),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.zero,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.zero,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.zero,
        ),
      ),

      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  }
}
