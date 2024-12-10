import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  CustomButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton (
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(text),
    );
  }
}
