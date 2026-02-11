import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); // private constructor

  static const _seedColor = Colors.black;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),

      scaffoldBackgroundColor: Colors.white,

      // app bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // title & icons
        elevation: 0,
      ),

      // cards
      cardColor: Colors.white,

      // loading indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.black,
      ),

      // text selection
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionColor: Colors.black26,
        selectionHandleColor: Colors.black,
      ),

      // input decoration
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

      // popup menu
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
        textStyle: TextStyle(color: Colors.black), // menu text
        elevation: 2,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}
