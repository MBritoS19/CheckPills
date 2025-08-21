import 'package:checkpills/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: AppColors.primaryOrange,
        background: AppColors.lightGray,
      ),
      scaffoldBackgroundColor: AppColors.lightGray,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primaryBlue,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}
