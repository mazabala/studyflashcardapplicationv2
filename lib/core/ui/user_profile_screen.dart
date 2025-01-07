import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);

    return CustomScaffold(
      currentRoute: '/userProfile',
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 600 : constraints.maxWidth,
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
                              radius: 50,
                              child: Icon(Icons.person, size: 50),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Subscription Status',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subscription Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Plan',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userState.subscriptionPlan ?? 'No active subscription',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Status',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  userState.isExpired ?? true
                                      ? Icons.error_outline
                                      : Icons.check_circle,
                                  color: userState.isExpired ?? true
                                      ? AppColors.errorColor
                                      : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  userState.isExpired ?? true
                                      ? 'Expired'
                                      : 'Active',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
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
}
