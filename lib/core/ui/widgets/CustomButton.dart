import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? postIcon;
  final bool iconOnly;
  final String? tooltip;

  const CustomButton({
    super.key,
    this.text,
    required this.isLoading,
    required this.onPressed,
    this.icon,
    this.postIcon,
    this.iconOnly = false,
    this.tooltip,
  }) : assert(
          iconOnly ? icon != null : text != null,
          'Either text must be provided or icon must be provided when iconOnly is true',
        );

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return IconButton(
        icon: Icon(icon),
        onPressed: isLoading ? null : onPressed,
        tooltip: tooltip,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 2),
                ],
                Text(text!),
                if (postIcon != null) ...[
                  const SizedBox(width: 2),
                  Icon(postIcon),
                ],
              ],
            ),
    );
  }
}
