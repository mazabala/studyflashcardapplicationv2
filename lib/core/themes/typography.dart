import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // ---- Light Theme Typography ----

  // Body Text
   static TextStyle bodySmall = GoogleFonts.openSans(
    color: AppColors.textSecondaryColor, // Dark text for light backgrounds
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText1 = GoogleFonts.openSans(
    color: AppColors.textPrimaryColor, // Dark text for light backgrounds
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText2 = GoogleFonts.openSans(
    color: AppColors.textPrimaryColor, // Softer text for secondary content
    fontSize: 16,
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

  // headlineSmall (for use in small headings like flashcards)
  static TextStyle headlineSmall = GoogleFonts.openSans(
    color: AppColors.textSecondaryColor, // Dark text for small headings
    fontSize: 20, // Adjust size as needed
    fontWeight: FontWeight.w600, // Medium weight for emphasis
  );

  // Buttons
  static TextStyle button = GoogleFonts.openSans(
    color: Colors.white, // White text for buttons on dark backgrounds
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ---- Dark Theme Typography ----

  // Body Text

   static TextStyle bodysmallDark = GoogleFonts.openSans(
    color: AppColors.textSecondaryColor, // Light text for dark backgrounds
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText1Dark = GoogleFonts.openSans(
    color: AppColors.textPrimaryColor, // Light text for dark backgrounds
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyText2Dark = GoogleFonts.openSans(
    color: AppColors.textSecondaryColor, // Slightly muted white for secondary content
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Headings
  static TextStyle headline1Dark = GoogleFonts.openSans(
    color: AppColors.textPrimaryColor, // White text for strong contrast on dark backgrounds
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle headline2Dark = GoogleFonts.openSans(
    color: AppColors.textPrimaryColor, // White text for headings
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // headlineSmall (for use in small headings like flashcards)
  static TextStyle headlineSmallDark = GoogleFonts.openSans(
    color: AppColors.textPrimaryColor, // Light text for small headings on dark backgrounds
    fontSize: 20, // Adjust size as needed
    fontWeight: FontWeight.w600, // Medium weight for emphasis
  );

  // Buttons
  static TextStyle buttonDark = GoogleFonts.openSans(
    color: Colors.white, // White text for buttons on dark backgrounds
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}


