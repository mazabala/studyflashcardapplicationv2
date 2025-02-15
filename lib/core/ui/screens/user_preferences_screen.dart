import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/models/user_preferences.dart';

class UserPreferencesScreen extends ConsumerWidget {
  const UserPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final userService = ref.read(userServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Study Preferences', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: FutureBuilder<UserPreferences>(
        future: userService.getUserPreferences(userState.userId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading preferences: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          final preferences = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Settings
                _buildSection(
                  context,
                  title: 'Appearance',
                  children: [
                    _buildThemeSelector(context, preferences, ref),
                  ],
                ),

                const SizedBox(height: 24),

                // Study Settings
                _buildSection(
                  context,
                  title: 'Study Settings',
                  children: [
                    _buildDailyGoalSetting(context, preferences, ref),
                    const SizedBox(height: 16),
                    _buildSessionDurationSetting(context, preferences, ref),
                    const SizedBox(height: 16),
                    _buildReminderSetting(context, preferences, ref),
                  ],
                ),

                const SizedBox(height: 24),

                // Feedback Settings
                _buildSection(
                  context,
                  title: 'Feedback',
                  children: [
                    _buildSwitchSetting(
                      context,
                      title: 'Sound Effects',
                      value: preferences.soundEnabled,
                      onChanged: (value) => _updatePreference(
                        ref,
                        preferences.copyWith(soundEnabled: value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchSetting(
                      context,
                      title: 'Haptic Feedback',
                      value: preferences.hapticFeedback,
                      onChanged: (value) => _updatePreference(
                        ref,
                        preferences.copyWith(hapticFeedback: value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    UserPreferences preferences,
    WidgetRef ref,
  ) {
    return DropdownButtonFormField<ThemeMode>(
      value: preferences.themeMode,
      decoration: const InputDecoration(
        labelText: 'Theme Mode',
        border: OutlineInputBorder(),
      ),
      items: ThemeMode.values.map((mode) {
        return DropdownMenuItem(
          value: mode,
          child: Text(mode.toString().split('.').last),
        );
      }).toList(),
      onChanged: (ThemeMode? newMode) {
        if (newMode != null) {
          _updatePreference(
            ref,
            preferences.copyWith(themeMode: newMode),
          );
        }
      },
    );
  }

  Widget _buildDailyGoalSetting(
    BuildContext context,
    UserPreferences preferences,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text('Daily Goal (cards)', style: Theme.of(context).textTheme.bodyLarge),
        ),
        SizedBox(
          width: 100,
          child: TextFormField(
            initialValue: preferences.dailyGoalCards.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final newValue = int.tryParse(value);
              if (newValue != null) {
                _updatePreference(
                  ref,
                  preferences.copyWith(dailyGoalCards: newValue),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSessionDurationSetting(
    BuildContext context,
    UserPreferences preferences,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text('Session Duration (minutes)', style: Theme.of(context).textTheme.bodyLarge),
        ),
        SizedBox(
          width: 100,
          child: TextFormField(
            initialValue: preferences.studySessionDuration.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final newValue = int.tryParse(value);
              if (newValue != null) {
                _updatePreference(
                  ref,
                  preferences.copyWith(studySessionDuration: newValue),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSetting(
    BuildContext context,
    UserPreferences preferences,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text('Daily Reminder', style: Theme.of(context).textTheme.bodyLarge),
        ),
        TextButton(
          onPressed: () async {
            final TimeOfDay? newTime = await showTimePicker(
              context: context,
              initialTime: preferences.studyReminder,
            );
            if (newTime != null) {
              _updatePreference(
                ref,
                preferences.copyWith(studyReminder: newTime),
              );
            }
          },
          child: Text(
            '${preferences.studyReminder.hour.toString().padLeft(2, '0')}:${preferences.studyReminder.minute.toString().padLeft(2, '0')}',
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _updatePreference(WidgetRef ref, UserPreferences newPreferences) {
    final userState = ref.read(userStateProvider);
    if (userState.userId != null) {
      ref.read(userServiceProvider).updateUserPreferences(
        userState.userId!,
        newPreferences,
      );
    }
  }
} 