import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = ref.watch(userStateProvider.select((state) => state.firstName));
    final lastName = ref.watch(userStateProvider.select((state) => state.lastName));
    final subscriptionPlan = ref.watch(userStateProvider.select((state) => state.subscriptionPlan));
    final isExpired = ref.watch(userStateProvider.select((state) => state.isExpired));
    final expiryDate = ref.watch(userStateProvider.select((state) => state.subscriptionExpiryDate));

    return Card(
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
                      'Name:\n$firstName $lastName',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Plan:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      subscriptionPlan ?? 'No active subscription',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          isExpired ?? true ? 'Expired' : 'Active',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isExpired ?? true ? Icons.error_outline : Icons.check_circle,
                          color: isExpired ?? true ? AppColors.errorColor : Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expiration Date: $expiryDate',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
