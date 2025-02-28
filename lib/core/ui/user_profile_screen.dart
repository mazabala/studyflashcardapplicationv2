import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flashcardstudyapplication/core/models/user_preferences.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/progress_dashboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final userPreferences = ref.read(userServiceProvider);

    final userNotifier = ref.read(userStateProvider.notifier);

    return CustomScaffold(
      currentRoute: '/userProfile',
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxWidth:
                      constraints.maxWidth > 600 ? 800 : constraints.maxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              child: Icon(Icons.person, size: 12),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your Profile',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const Divider(),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name:\n${userState.firstName} ${userState.lastName}',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Current Plan:',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      userState.subscriptionPlan ??
                                          'No active subscription',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Status:',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          userState.isExpired ?? true
                                              ? 'Expired'
                                              : 'Active',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          userState.isExpired ?? true
                                              ? Icons.error_outline
                                              : Icons.check_circle,
                                          color: userState.isExpired ?? true
                                              ? AppColors.errorColor
                                              : Colors.green,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Expiration Date: ${userState.subscriptionExpiryDate}',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const ProgressDashboardWidget(),

                    const SizedBox(height: 16),
                    // User Preferences Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FutureBuilder<UserPreferences>(
                          future: userPreferences
                              .getUserPreferences(userState.userId ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Text(
                                'Error loading preferences: ${snapshot.error}',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              );
                            }

                            final preferences = snapshot.data!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Study Preferences',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 16),

                                // Theme Mode
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text('Theme Mode',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                      ),
                                      DropdownButton<ThemeMode>(
                                        value: preferences.themeMode,
                                        items: ThemeMode.values.map((mode) {
                                          return DropdownMenuItem(
                                            value: mode,
                                            child: Text(
                                              mode.toString().split('.').last,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (ThemeMode? newMode) {
                                          if (newMode != null) {
                                            userPreferences
                                                .updateUserPreferences(
                                              userState.userId!,
                                              preferences.copyWith(
                                                  themeMode: newMode),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Daily Goal
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text('Daily Goal (cards)',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                      ),
                                      SizedBox(
                                        width: 70,
                                        child: TextFormField(
                                          initialValue: preferences
                                              .dailyGoalCards
                                              .toString(),
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 8),
                                          ),
                                          onChanged: (value) {
                                            final newValue =
                                                int.tryParse(value);
                                            if (newValue != null) {
                                              userPreferences
                                                  .updateUserPreferences(
                                                userState.userId!,
                                                preferences.copyWith(
                                                    dailyGoalCards: newValue),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Session Duration
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text('Session Duration (min)',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                      ),
                                      SizedBox(
                                        width: 70,
                                        child: TextFormField(
                                          initialValue: preferences
                                              .studySessionDuration
                                              .toString(),
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 8),
                                          ),
                                          onChanged: (value) {
                                            final newValue =
                                                int.tryParse(value);
                                            if (newValue != null) {
                                              userPreferences
                                                  .updateUserPreferences(
                                                userState.userId!,
                                                preferences.copyWith(
                                                    studySessionDuration:
                                                        newValue),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Sound and Haptic Feedback
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text('Sound Effects',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                      ),
                                      Switch(
                                        value: preferences.soundEnabled,
                                        onChanged: (value) {
                                          userPreferences.updateUserPreferences(
                                            userState.userId!,
                                            preferences.copyWith(
                                                soundEnabled: value),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text('Haptic Feedback',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                      ),
                                      Switch(
                                        value: preferences.hapticFeedback,
                                        onChanged: (value) {
                                          userPreferences.updateUserPreferences(
                                            userState.userId!,
                                            preferences.copyWith(
                                                hapticFeedback: value),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons
                    CustomButton(
                      text: 'Manage Subscription',
                      onPressed: () {
                        Navigator.pushNamed(context, '/prices');
                      },
                      isLoading: false,
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: 'Edit Profile',
                      onPressed: () {
                        editProfileDialog(context, ref);
                      },
                      isLoading: false,
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: 'Delete Account',
                      onPressed: () {
                        deleteAccountDialog(context, ref);
                      },
                      isLoading: false,
                      icon: Icons.delete,
                    ),
                    if (userState.errorMessage != null) ...[
                      Text(
                        userState.errorMessage!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.errorColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> deleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final userNotifier = ref.read(userStateProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning),
        iconColor: AppColors.errorColor,
        title: const Text('Delete Account'),
        content: const Text(
            'This action is inmmidiate and irreversible and will remove all your data from the system. \n\nAre you sure you want to delete your account? '),
        actions: [
          CustomButton(
            text: 'Delete',
            icon: (Icons.warning),
            onPressed: () {
              userNotifier.deleteUser();
              userNotifier.downgradeSubscription('free');
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            isLoading: false,
          ),
        ],
      ),
    );
  }

  Future<void> editProfileDialog(BuildContext context, WidgetRef ref) async {
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    final userNotifier = ref.read(userStateProvider.notifier);
    final userState = ref.watch(userStateProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Save',
              icon: Icons.save,
              onPressed: () {
                userNotifier.userService.updateUserProfile(
                    firstNameController.text,
                    lastNameController.text,
                    userState.userId ?? '');

                Navigator.pop(context);
              },
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }
}
