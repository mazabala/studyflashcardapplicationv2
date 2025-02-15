import 'package:flashcardstudyapplication/core/models/user_preferences.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/ui/user_profile_screen.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/preference_controls.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/preference_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreferencesCard extends ConsumerWidget {
  const PreferencesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userStateProvider.select((state) => state.userId));
    final userPreferences = ref.read(userServiceProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<UserPreferences>(
          future: userPreferences.getUserPreferences(userId ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text(
                'Error loading preferences: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              );
            }

            final preferences = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                PreferenceRow(
                  label: 'Theme Mode',
                  control: ThemeModeDropdown(
                    preferences: preferences,
                    userId: userId ?? '',
                  ),
                ),
                const SizedBox(height: 16),
                PreferenceRow(
                  label: 'Daily Goal (cards)',
                  control: NumberInput(
                    initialValue: preferences.dailyGoalCards,
                    onChanged: (value) {
                      if (value != null) {
                        userPreferences.updateUserPreferences(
                          userId!,
                          preferences.copyWith(dailyGoalCards: value),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                PreferenceRow(
                  label: 'Session Duration (min)',
                  control: NumberInput(
                    initialValue: preferences.studySessionDuration,
                    onChanged: (value) {
                      if (value != null) {
                        userPreferences.updateUserPreferences(
                          userId!,
                          preferences.copyWith(studySessionDuration: value),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                PreferenceRow(
                  label: 'Sound Effects',
                  control: PreferenceSwitch(
                    value: preferences.soundEnabled,
                    onChanged: (value) {
                      userPreferences.updateUserPreferences(
                        userId!,
                        preferences.copyWith(soundEnabled: value),
                      );
                    },
                  ),
                ),
                PreferenceRow(
                  label: 'Haptic Feedback',
                  control: PreferenceSwitch(
                    value: preferences.hapticFeedback,
                    onChanged: (value) {
                      userPreferences.updateUserPreferences(
                        userId!,
                        preferences.copyWith(hapticFeedback: value),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
