import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/main.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';

/// A widget that allows toggling between light and dark mode
class ThemeToggle extends ConsumerWidget {
  final bool showLabel;
  final bool isSmall;
  final Color? iconColor;
  final Color? backgroundColor;

  const ThemeToggle({
    Key? key,
    this.showLabel = false,
    this.isSmall = false,
    this.iconColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    final bgColor = backgroundColor ??
        (isDarkMode
            ? Colors.white.withOpacity(0.1)
            : AppColors.primaryColor.withOpacity(0.1));

    final icColor =
        iconColor ?? (isDarkMode ? Colors.white : AppColors.primaryColor);

    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).toggleThemeMode();
      },
      borderRadius: BorderRadius.circular(isSmall ? 20 : 30),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 12,
          vertical: isSmall ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isSmall ? 20 : 30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: icColor,
              size: isSmall ? 16 : 24,
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                isDarkMode ? 'Dark Mode' : 'Light Mode',
                style: TextStyle(
                  color: icColor,
                  fontSize: isSmall ? 12 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A theme toggle button that can be used in the app bar
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
      ),
      onPressed: () {
        ref.read(themeModeProvider.notifier).toggleThemeMode();
      },
      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}

/// A theme toggle switch that can be used in settings
class ThemeToggleSwitch extends ConsumerWidget {
  const ThemeToggleSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return SwitchListTile(
      title: const Text('Dark Mode'),
      subtitle: Text(isDarkMode ? 'On' : 'Off'),
      value: isDarkMode,
      onChanged: (value) {
        ref.read(themeModeProvider.notifier).setThemeMode(
              value ? ThemeMode.dark : ThemeMode.light,
            );
      },
      secondary: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: isDarkMode ? AppColors.secondaryColor : AppColors.primaryColor,
      ),
    );
  }
}
