import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Font family to use throughout the app
  static const String primaryFontFamily = 'OpenSans';

  // Helper method to create TextStyle with the primary font
  static TextStyle _createTextStyle({
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: primaryFontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  // ---- Light Theme Typography ----

  // Body Text
  static TextStyle bodySmall = _createTextStyle(
    color: AppColors.textSecondaryColor,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText1 = _createTextStyle(
    color: AppColors.textPrimaryColor,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText2 = _createTextStyle(
    color: AppColors.textSecondaryColor,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Headings
  static TextStyle headline1 = _createTextStyle(
    color: AppColors.primaryColor,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headline2 = _createTextStyle(
    color: AppColors.primaryColor,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // headlineSmall (for use in small headings like flashcards)
  static TextStyle headlineSmall = _createTextStyle(
    color: AppColors.primaryColor,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Buttons
  static TextStyle button = _createTextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ---- Dark Theme Typography ----

  // Body Text
  static TextStyle bodysmallDark = _createTextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText1Dark = _createTextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText2Dark = _createTextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Headings
  static TextStyle headline1Dark = _createTextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headline2Dark = _createTextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // headlineSmall (for use in small headings like flashcards)
  static TextStyle headlineSmallDark = _createTextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Buttons
  static TextStyle buttonDark = _createTextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Additional styles for consistent UI

  // Card Title
  static TextStyle cardTitle = _createTextStyle(
    color: AppColors.primaryColor,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle cardTitleDark = _createTextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Subtitle
  static TextStyle subtitle = _createTextStyle(
    color: AppColors.textSecondaryColor,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle subtitleDark = _createTextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // Caption
  static TextStyle caption = _createTextStyle(
    color: AppColors.textSecondaryColor,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static TextStyle captionDark = _createTextStyle(
    color: Colors.white70,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}
