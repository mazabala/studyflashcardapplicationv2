import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';

/// A themed text input field that follows the app theme
class ThemedTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final bool isDense;
  final bool filled;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double borderRadius;
  final String? initialValue;

  const ThemedTextField({
    Key? key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.isDense = false,
    this.filled = true,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius = 8,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine colors based on theme
    final defaultFillColor =
        isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white;

    final defaultBorderColor =
        isDarkMode ? Colors.white.withOpacity(0.3) : AppColors.tertiaryColor;

    final defaultFocusedBorderColor =
        isDarkMode ? AppColors.secondaryColor : AppColors.secondaryColor;

    final labelStyle = TextStyle(
      color: isDarkMode ? Colors.white70 : AppColors.textSecondaryColor,
      fontSize: 16,
    );

    final hintStyle = TextStyle(
      color: isDarkMode
          ? Colors.white.withOpacity(0.5)
          : AppColors.textSecondaryColor.withOpacity(0.5),
      fontSize: 16,
    );

    final textStyle = TextStyle(
      color: isDarkMode ? Colors.white : AppColors.textPrimaryColor,
      fontSize: 16,
    );

    final padding = contentPadding ??
        EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isDense ? 12 : 16,
        );

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: autovalidateMode,
      style: textStyle,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        labelStyle: labelStyle,
        hintStyle: hintStyle,
        prefix: prefix,
        suffix: suffix,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: padding,
        prefixIconConstraints: prefixIconConstraints,
        suffixIconConstraints: suffixIconConstraints,
        isDense: isDense,
        filled: filled,
        fillColor: fillColor ?? defaultFillColor,
        errorStyle: TextStyle(
          color: theme.colorScheme.error,
          fontSize: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? defaultBorderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? defaultBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: focusedBorderColor ?? defaultFocusedBorderColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// A themed search input field that follows the app theme
class ThemedSearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSubmitted;
  final bool autofocus;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;

  const ThemedSearchField({
    Key? key,
    this.hint,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onClear,
    this.onSubmitted,
    this.autofocus = false,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine colors based on theme
    final defaultFillColor =
        isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white;

    final defaultBorderColor =
        isDarkMode ? Colors.white.withOpacity(0.3) : AppColors.tertiaryColor;

    final hintStyle = TextStyle(
      color: isDarkMode
          ? Colors.white.withOpacity(0.5)
          : AppColors.textSecondaryColor.withOpacity(0.5),
      fontSize: 16,
    );

    final textStyle = TextStyle(
      color: isDarkMode ? Colors.white : AppColors.textPrimaryColor,
      fontSize: 16,
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      style: textStyle,
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted?.call(),
      decoration: InputDecoration(
        hintText: hint ?? 'Search...',
        hintStyle: hintStyle,
        filled: true,
        fillColor: fillColor ?? defaultFillColor,
        prefixIcon: Icon(
          Icons.search,
          color: isDarkMode ? Colors.white70 : AppColors.textSecondaryColor,
        ),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: isDarkMode
                      ? Colors.white70
                      : AppColors.textSecondaryColor,
                ),
                onPressed: () {
                  controller!.clear();
                  onClear?.call();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? defaultBorderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? defaultBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color:
                isDarkMode ? AppColors.secondaryColor : AppColors.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
