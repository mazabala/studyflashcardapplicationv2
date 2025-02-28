import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // ---- Light Theme Typography ----

  // Body Text
  static TextStyle bodySmall = GoogleFonts.openSans(
    color: AppColors.textSecondaryColor,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText1 = GoogleFonts.openSans(
    color: AppColors.textPrimaryColor,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText2 = GoogleFonts.openSans(
    color: AppColors.textSecondaryColor,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Headings
  static TextStyle headline1 = GoogleFonts.openSans(
    color: AppColors.primaryColor,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headline2 = GoogleFonts.openSans(
    color: AppColors.primaryColor,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // headlineSmall (for use in small headings like flashcards)
  static TextStyle headlineSmall = GoogleFonts.openSans(
    color: AppColors.primaryColor,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Buttons
  static TextStyle button = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ---- Dark Theme Typography ----

  // Body Text
  static TextStyle bodysmallDark = GoogleFonts.openSans(
    color: Colors.white70,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText1Dark = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText2Dark = GoogleFonts.openSans(
    color: Colors.white70,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Headings
  static TextStyle headline1Dark = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headline2Dark = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // headlineSmall (for use in small headings like flashcards)
  static TextStyle headlineSmallDark = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Buttons
  static TextStyle buttonDark = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Additional styles for consistent UI

  // Card Title
  static TextStyle cardTitle = GoogleFonts.openSans(
    color: AppColors.primaryColor,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle cardTitleDark = GoogleFonts.openSans(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Subtitle
  static TextStyle subtitle = GoogleFonts.openSans(
    color: AppColors.textSecondaryColor,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle subtitleDark = GoogleFonts.openSans(
    color: Colors.white70,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // Caption
  static TextStyle caption = GoogleFonts.openSans(
    color: AppColors.textSecondaryColor,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static TextStyle captionDark = GoogleFonts.openSans(
    color: Colors.white70,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}
