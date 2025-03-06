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
   
    this.textInputAction,
    this.onFieldSubmitted,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,

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

    );
  }
}