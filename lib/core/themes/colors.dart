// lib/core/themes/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors from the provided palette
  static const Color primaryColor = Color(0xFF012456); // Navy Blue (#012456)
  static const Color secondaryColor =
      Color(0xFF03B1FF); // Bright Blue (#03B1FF)
  static const Color tertiaryColor = Color(0xFF939598); // Gray (#939598)

  // Background Colors
  static const Color backgroundColor =
      Color(0xFFF5F5F5); // Light background for light mode
  static const Color darkBackgroundColor =
      Color(0xFF121212); // Dark background for dark mode

  // Card Colors
  static const Color cardBackgroundColor =
      Colors.white; // Card background for light mode
  static const Color darkCardBackgroundColor =
      Color(0xFF1E1E1E); // Card background for dark mode

  // Text Colors
  static const Color textPrimaryColor =
      Color(0xFF012456); // Primary text color (Navy)
  static const Color textSecondaryColor =
      Color(0xFF4A4A4A); // Secondary text color
  static const Color textLightColor =
      Colors.white; // Light text color for dark backgrounds

  // Accent Colors
  static const Color accentColor = Color(0xFF03B1FF); // Bright Blue as accent

  // Error Color
  static const Color errorColor = Color(0xFFD32F2F); // Crimson Red for errors
}
