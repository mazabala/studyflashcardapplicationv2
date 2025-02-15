import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';

class ProgressDashboardWidget extends ConsumerWidget {
  const ProgressDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    
    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(userServiceProvider).getStudyAnalytics(userState.userId ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Start Your Learning Journey',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete your first study session to see your progress statistics here!',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final analytics = snapshot.data!;
        
        return Column(
          children: [
            // Streak Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study Streak',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStreakInfo(
                          context,
                          'Current',
                          analytics['current_streak']?.toString() ?? '0',
                          Icons.local_fire_department,
                        ),
                        _buildStreakInfo(
                          context,
                          'Longest',
                          analytics['longest_streak']?.toString() ?? '0',
                          Icons.emoji_events,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Study Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study Statistics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      context,
                      'Total Study Time',
                      '${((analytics['total_study_time'] as int?) ?? 0 / 60).toStringAsFixed(1)} hours',
                      Icons.timer,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      context,
                      'Average Daily Cards',
                      (analytics['average_daily_cards'] ?? 0).toStringAsFixed(1),
                      Icons.style,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      context,
                      'Average Confidence',
                      '${((analytics['average_confidence'] as double?) ?? 0 * 100).toStringAsFixed(1)}%',
                      Icons.psychology,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildStreakInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
} 