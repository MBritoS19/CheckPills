import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF23AFDC);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
