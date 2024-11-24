import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // ---- Light Theme Typography ----

  // Body Text
  static TextStyle bodyText1 = GoogleFonts.openSans(
    color: AppColors.textPrimaryColor, // Dark text for light backgrounds
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText2 = GoogleFonts.openSans(
    color: AppColors.textSecondaryColor, // Softer text for secondary content
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );

  // Headings
  static TextStyle headline1 = GoogleFonts.openSans(
    color: AppColors.textPrimaryColor, // Dark text for headings
    fontSize: 70,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headline2 = GoogleFonts.openSans(
    color: AppColors.textPrimaryColor, // Dark text for headings
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Buttons
  static TextStyle button = GoogleFonts.openSans(
    color: Colors.white, // White text for buttons on dark backgrounds
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ---- Dark Theme Typography ----

  // Body Text
  static TextStyle bodyText1Dark = GoogleFonts.openSans(
    color: Colors.white, // Light text for dark backgrounds
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText2Dark = GoogleFonts.openSans(
    color: Colors.white70, // Slightly muted white for secondary content
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Headings
  static TextStyle headline1Dark = GoogleFonts.openSans(
    color: Colors.white, // White text for strong contrast on dark backgrounds
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headline2Dark = GoogleFonts.openSans(
    color: Colors.white, // White text for headings
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Buttons
  static TextStyle buttonDark = GoogleFonts.openSans(
    color: Colors.white, // White text for buttons on dark backgrounds
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
