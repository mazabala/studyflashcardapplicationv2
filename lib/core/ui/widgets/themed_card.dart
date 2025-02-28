import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';

/// A themed card widget that follows the app theme
class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool useShadow;

  const ThemedCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
    this.elevation = 2,
    this.borderRadius = 8,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.useShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDarkMode
            ? AppColors.darkCardBackgroundColor
            : AppColors.cardBackgroundColor);

    final border =
        borderColor != null ? Border.all(color: borderColor!, width: 1) : null;

    final boxShadow = useShadow
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation),
            ),
          ]
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          boxShadow: boxShadow,
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// A themed card with a title and optional icon
class ThemedTitleCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool useShadow;
  final Widget? trailing;

  const ThemedTitleCard({
    Key? key,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
    this.elevation = 2,
    this.borderRadius = 8,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.useShadow = true,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final titleColor = isDarkMode ? Colors.white : AppColors.primaryColor;

    final actualIconColor = iconColor ??
        (isDarkMode ? AppColors.secondaryColor : AppColors.primaryColor);

    return ThemedCard(
      padding: EdgeInsets.zero,
      margin: margin,
      elevation: elevation,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      onTap: onTap,
      useShadow: useShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: actualIconColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
          // Content
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// A themed card specifically for flashcards
class FlashcardThemedCard extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final bool isFlipped;
  final double height;

  const FlashcardThemedCard({
    Key? key,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 18,
    this.isFlipped = false,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDarkMode
            ? (isFlipped ? AppColors.secondaryColor : AppColors.primaryColor)
            : (isFlipped ? AppColors.secondaryColor : AppColors.primaryColor));

    final txtColor = textColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              text,
              style: TextStyle(
                color: txtColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
