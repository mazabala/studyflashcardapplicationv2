import 'package:flutter/material.dart';

class CustomDialogWidget extends StatelessWidget {
  final List<Widget> dialogContent; // The list of dynamic content (Widgets)
  final String title; // Title of the dialog
  final String? confirmText; // Text for confirm button
  final VoidCallback? onConfirm; // Function to call on confirm
  final String? cancelText; // Text for cancel button
  final VoidCallback? onCancel; // Function to call on cancel

  CustomDialogWidget({
    required this.dialogContent,
    required this.title,
    this.confirmText,
    this.onConfirm,
    this.cancelText,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: dialogContent,
        ),
      ),
      actions: <Widget>[
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(cancelText!),
          ),
        if (confirmText != null)
          TextButton(
            onPressed: onConfirm ?? () => Navigator.of(context).pop(),
            child: Text(confirmText!),
          ),
      ],
    );
  }
}
