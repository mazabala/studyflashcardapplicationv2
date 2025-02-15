import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/models/user_progress.dart';

class ProgressDashboardScreen extends ConsumerWidget {
  const ProgressDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final userService = ref.read(userServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Dashboard', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userService.getStudyAnalytics(userState.userId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading progress: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          final analytics = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStreakCard(context, analytics),
                const SizedBox(height: 16),
                _buildStudyStatsCard(context, analytics),
                const SizedBox(height: 16),
                _buildAchievementsCard(context, analytics),
                const SizedBox(height: 16),
                _buildLeaderboardCard(context, ref),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, Map<String, dynamic> analytics) {
    return Card(
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
                  analytics['current_streak'].toString(),
                  Icons.local_fire_department,
                ),
                _buildStreakInfo(
                  context,
                  'Longest',
                  analytics['longest_streak'].toString(),
                  Icons.emoji_events,
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildStudyStatsCard(BuildContext context, Map<String, dynamic> analytics) {
    return Card(
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
              '${((analytics['total_study_time'] as int) / 60).toStringAsFixed(1)} hours',
              Icons.timer,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Average Daily Cards',
              analytics['average_daily_cards'].toStringAsFixed(1),
              Icons.style,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Average Confidence',
              '${(analytics['average_confidence'] * 100).toStringAsFixed(1)}%',
              Icons.psychology,
            ),
          ],
        ),
      ),
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

  Widget _buildAchievementsCard(BuildContext context, Map<String, dynamic> analytics) {
    final achievements = analytics['achievements'] as Map<String, dynamic>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${achievements.length} earned',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements.values.elementAt(index);
                return ListTile(
                  leading: const Icon(Icons.star),
                  title: Text(achievement['title']),
                  subtitle: Text(achievement['description']),
                  trailing: Text(
                    DateTime.parse(achievement['awarded_at'])
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leaderboard',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: ref.read(userServiceProvider).getLeaderboardPosition(
                userState.userId ?? '',
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final leaderboard = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = leaderboard[index];
                    final isCurrentUser = entry['user_id'] == userState.userId;
                    
                    return ListTile(
                      tileColor: isCurrentUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      leading: Text(
                        '#${entry['rank']}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      title: Text(entry['username']),
                      trailing: Text(
                        '${entry['current_streak']} 🔥',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 