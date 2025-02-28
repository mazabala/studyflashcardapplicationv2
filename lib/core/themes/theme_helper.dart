import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';

/// A helper class for accessing theme properties consistently across the app
class ThemeHelper {
  /// Get the primary color based on the current theme
  static Color getPrimaryColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.primary;
  }

  /// Get the secondary color based on the current theme
  static Color getSecondaryColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.secondary;
  }

  /// Get the tertiary color based on the current theme
  static Color getTertiaryColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.tertiary;
  }

  /// Get the background color based on the current theme
  static Color getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return isDarkMode
        ? AppColors.darkBackgroundColor
        : AppColors.backgroundColor;
  }

  /// Get the card background color based on the current theme
  static Color getCardBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return isDarkMode
        ? AppColors.darkCardBackgroundColor
        : AppColors.cardBackgroundColor;
  }

  /// Get the text color based on the current theme
  static Color getTextColor(BuildContext context, {bool isSecondary = false}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (isSecondary) {
      return isDarkMode ? Colors.white70 : AppColors.textSecondaryColor;
    } else {
      return isDarkMode ? Colors.white : AppColors.textPrimaryColor;
    }
  }

  /// Get the error color
  static Color getErrorColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.error;
  }

  /// Check if the current theme is dark mode
  static bool isDarkMode(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark;
  }

  /// Get a color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get a gradient based on the primary color
  static LinearGradient getPrimaryGradient(BuildContext context) {
    final theme = Theme.of(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.primary.withOpacity(0.8),
      ],
    );
  }

  /// Get a gradient based on the secondary color
  static LinearGradient getSecondaryGradient(BuildContext context) {
    final theme = Theme.of(context);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.secondary,
        theme.colorScheme.secondary.withOpacity(0.8),
      ],
    );
  }

  /// Get a box shadow based on the current theme
  static List<BoxShadow> getBoxShadow(BuildContext context,
      {double elevation = 2}) {
    final isDarkMode = ThemeHelper.isDarkMode(context);
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }

  /// Get a border radius
  static BorderRadius getBorderRadius({double radius = 8}) {
    return BorderRadius.circular(radius);
  }

  /// Get a card decoration
  static BoxDecoration getCardDecoration(
    BuildContext context, {
    double borderRadius = 8,
    double elevation = 2,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDarkMode
            ? AppColors.darkCardBackgroundColor
            : AppColors.cardBackgroundColor);

    final border =
        borderColor != null ? Border.all(color: borderColor, width: 1) : null;

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: getBoxShadow(context, elevation: elevation),
    );
  }

  /// Get a button style based on the current theme
  static ButtonStyle getButtonStyle(
    BuildContext context, {
    Color? backgroundColor,
    Color? foregroundColor,
    double borderRadius = 8,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final bgColor = backgroundColor ?? theme.colorScheme.primary;
    final fgColor = foregroundColor ?? Colors.white;

    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Get an outlined button style based on the current theme
  static ButtonStyle getOutlinedButtonStyle(
    BuildContext context, {
    Color? foregroundColor,
    Color? borderColor,
    double borderRadius = 8,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final fgColor = foregroundColor ??
        (isDarkMode ? Colors.white : theme.colorScheme.primary);

    final bdColor = borderColor ?? fgColor;

    return OutlinedButton.styleFrom(
      foregroundColor: fgColor,
      side: BorderSide(color: bdColor),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Get a text button style based on the current theme
  static ButtonStyle getTextButtonStyle(
    BuildContext context, {
    Color? foregroundColor,
    double borderRadius = 8,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final fgColor = foregroundColor ??
        (isDarkMode ? Colors.white : theme.colorScheme.primary);

    return TextButton.styleFrom(
      foregroundColor: fgColor,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Get a text style based on the current theme
  static TextStyle getTextStyle(
    BuildContext context, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    bool isSecondary = false,
  }) {
    final textColor = color ?? getTextColor(context, isSecondary: isSecondary);

    return TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Get a heading text style based on the current theme
  static TextStyle getHeadingStyle(
    BuildContext context, {
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    final textColor = color ?? getTextColor(context);

    return TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
