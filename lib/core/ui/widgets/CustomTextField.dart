import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;

  CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      validator: validator,
      enabled: enabled,
    );
  }
}
