import 'package:flutter/material.dart';
import 'package:cid_retranslator/theme/constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.win11Accent,
      secondary: AppColors.win11AccentLight,
      surface: AppColors.win11Background,
      error: AppColors.win11Error,
    ),
    scaffoldBackgroundColor: AppColors.win11Background,
    cardColor: AppColors.win11CardBackground,
    dividerColor: AppColors.win11Border,

    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.win11CardBackground,
      foregroundColor: AppColors.win11TextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.win11TextPrimary,
        fontFamily: 'Segoe UI',
      ),
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.win11Accent,
      unselectedLabelColor: AppColors.win11TextSecondary,
      indicatorColor: AppColors.win11Accent,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Segoe UI',
      ),
    ),

    // Text theme
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 14,
        color: AppColors.win11TextPrimary,
        fontFamily: 'Segoe UI',
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        color: AppColors.win11TextPrimary,
        fontFamily: 'Segoe UI',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.win11TextSecondary,
        fontFamily: 'Segoe UI',
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.win11TextPrimary,
        fontFamily: 'Segoe UI',
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.win11CardBackground,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.win11Border),
        borderRadius: BorderRadius.circular(4),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.win11Border),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.win11Accent, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.win11Accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),

    fontFamily: 'Segoe UI',
  );
}
