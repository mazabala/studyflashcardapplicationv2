import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    // Use colorScheme for primary, secondary, and error
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      tertiary: AppColors.tertiaryColor,
      error: AppColors.errorColor,
      background: AppColors.backgroundColor,
      surface: AppColors.cardBackgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: AppColors.textPrimaryColor,
      onSurface: AppColors.textPrimaryColor,
    ),

    scaffoldBackgroundColor: AppColors.backgroundColor,
    cardColor: AppColors.cardBackgroundColor,
    dividerColor: AppColors.tertiaryColor.withOpacity(0.2),

    // Updated text theme for Flutter 2.0+
    textTheme: TextTheme(
      bodySmall: AppTypography.bodySmall,
      bodyLarge: AppTypography.bodyText1,
      bodyMedium: AppTypography.bodyText2,
      headlineSmall: AppTypography.headlineSmall,
      displayLarge: AppTypography.headline1,
      displayMedium: AppTypography.headline2,
      labelLarge: AppTypography.button,
    ),

    // Button Theme
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: const BorderSide(color: AppColors.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.tertiaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.secondaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondaryColor),
      hintStyle: const TextStyle(color: AppColors.textSecondaryColor),
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    // Use colorScheme for primary, secondary, and error
    colorScheme: const ColorScheme.dark(
      primary: AppColors.secondaryColor,
      secondary: AppColors.primaryColor,
      tertiary: AppColors.tertiaryColor,
      error: AppColors.errorColor,
      background: AppColors.darkBackgroundColor,
      surface: AppColors.darkCardBackgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),

    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    cardColor: AppColors.darkCardBackgroundColor,
    dividerColor: AppColors.tertiaryColor.withOpacity(0.2),

    // Updated text theme for Flutter 2.0+
    textTheme: TextTheme(
      bodySmall: AppTypography.bodysmallDark,
      bodyLarge: AppTypography.bodyText1Dark,
      bodyMedium: AppTypography.bodyText2Dark,
      headlineSmall: AppTypography.headlineSmallDark,
      displayLarge: AppTypography.headline1Dark,
      displayMedium: AppTypography.headline2Dark,
      labelLarge: AppTypography.buttonDark,
    ),

    // Button Theme
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.secondaryColor,
      textTheme: ButtonTextTheme.primary,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondaryColor,
        side: const BorderSide(color: AppColors.secondaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCardBackgroundColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.tertiaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.secondaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white70),
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
