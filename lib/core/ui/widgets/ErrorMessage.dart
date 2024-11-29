import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
