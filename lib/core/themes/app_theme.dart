import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    // Use colorScheme for primary, secondary, and error
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.accentColor,
      error: AppColors.errorColor,
    ),
    
    scaffoldBackgroundColor: AppColors.backgroundColor,
    cardColor: AppColors.cardBackgroundColor,

    // Updated text theme for Flutter 2.0+
    textTheme: TextTheme(
      bodyLarge: AppTypography.bodyText1, // Body text for light theme
      bodyMedium: AppTypography.bodyText2, // Secondary body text for light theme
      displayLarge: AppTypography.headline1, // Headline 1 for light theme
      displayMedium: AppTypography.headline2, // Headline 2 for light theme
      labelLarge: AppTypography.button, // Button text for light theme
    ),

    // Button Theme
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(color: AppColors.textSecondaryColor),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    // Use colorScheme for primary, secondary, and error
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.accentColor,
      error: AppColors.errorColor,
    ),

    scaffoldBackgroundColor: Color(0xFF303030),
    cardColor: Color(0xFF424242),

    // Updated text theme for Flutter 2.0+
    textTheme: TextTheme(
      bodyLarge: AppTypography.bodyText1Dark, // Body text for dark theme
      bodyMedium: AppTypography.bodyText2Dark, // Secondary body text for dark theme
      displayLarge: AppTypography.headline1Dark, // Headline 1 for dark theme
      displayMedium: AppTypography.headline2Dark, // Headline 2 for dark theme
      labelLarge: AppTypography.buttonDark, // Button text for dark theme
    ),

    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF616161),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(color: Colors.white70),
    ),
  );
}
