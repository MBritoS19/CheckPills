import 'package:flutter/material.dart';

class AppConstants {
  static const String appTitle = 'CheckPills';
}

class AppColors {
  static const Color primaryBlue = Color(0xFF23AFDC);
  static const Color primaryOrange = Color(0xFFDC5023);
  static const Color lightGray = Color(0xFFD9D9D9);
  static const Color white = Color(0xFFFFFFFF);

  // Status colors
  static const Color missedDose = Color(0xFFDC5023);
  static const Color refillReminder = Color(0xFFFFCC66);
  static const Color takenDose = Color(0xFF23AFDC);
}

class AppRoutes {
  static const String home = '/';
  static const String addMedication = '/add_medication';
  static const String configuration = '/configuration';
}
