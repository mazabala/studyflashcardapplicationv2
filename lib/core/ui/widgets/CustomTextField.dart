import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final InputDecoration? decoration;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.suffixIcon,
    this.decoration,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration?.copyWith(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
      ) ?? InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      validator: validator,
      enabled: enabled,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      keyboardType: keyboardType,
      // Maintain focus when validation errors occur
      onTap: () {
        if (focusNode != null && !focusNode!.hasFocus) {
          FocusScope.of(context).requestFocus(focusNode);
        }
      },
    );
  }
}