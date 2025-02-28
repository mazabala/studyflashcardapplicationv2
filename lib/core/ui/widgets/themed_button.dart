import 'package:flutter/material.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';

/// A themed button widget that follows the app theme
class ThemedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final ButtonType type;

  const ThemedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.borderRadius = 8,
    this.padding,
    this.width,
    this.height,
    this.type = ButtonType.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine colors based on button type and theme
    Color bgColor;
    Color txtColor;

    switch (type) {
      case ButtonType.primary:
        bgColor = backgroundColor ?? theme.colorScheme.primary;
        txtColor = textColor ?? Colors.white;
        break;
      case ButtonType.secondary:
        bgColor = backgroundColor ?? theme.colorScheme.secondary;
        txtColor = textColor ?? Colors.white;
        break;
      case ButtonType.outline:
        bgColor = backgroundColor ?? Colors.transparent;
        txtColor = textColor ??
            (isDarkMode ? Colors.white : theme.colorScheme.primary);
        break;
      case ButtonType.text:
        bgColor = Colors.transparent;
        txtColor = textColor ??
            (isDarkMode ? Colors.white : theme.colorScheme.primary);
        break;
    }

    // Determine padding based on button size
    final buttonPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        );

    // Build the button content
    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading) ...[
          Icon(icon, color: txtColor),
          const SizedBox(width: 8),
        ],
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(txtColor),
            ),
          )
        else
          Text(
            text,
            style: TextStyle(
              color: txtColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );

    // Wrap in a container for full width if needed
    if (isFullWidth) {
      buttonContent = SizedBox(
        width: double.infinity,
        child: Center(child: buttonContent),
      );
    }

    // Apply specific styling based on button type
    Widget button;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: txtColor,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: 2,
          ),
          child: buttonContent,
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: txtColor,
            padding: buttonPadding,
            side: BorderSide(color: txtColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: txtColor,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        );
        break;
    }

    // Apply custom width and height if provided
    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }
}

/// Button types for ThemedButton
enum ButtonType {
  primary,
  secondary,
  outline,
  text,
}

/// A floating action button that follows the app theme
class ThemedFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool mini;

  const ThemedFloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.mini = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDarkMode ? AppColors.secondaryColor : theme.colorScheme.primary);

    final icColor = iconColor ?? Colors.white;

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: bgColor,
      mini: mini,
      child: Icon(
        icon,
        color: icColor,
      ),
    );
  }
}

/// A themed icon button that follows the app theme
class ThemedIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final double size;
  final EdgeInsetsGeometry padding;

  const ThemedIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
    this.size = 24,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final iconColor =
        color ?? (isDarkMode ? Colors.white : theme.colorScheme.primary);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: iconColor,
        size: size,
      ),
      tooltip: tooltip,
      padding: padding,
      splashRadius: size + 8,
    );
  }
}
