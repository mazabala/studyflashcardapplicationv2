// lib/core/services/interfaces/i_user_service.dart

import '../models/user_preferences.dart';
import '../models/user_progress.dart';

abstract class IUserService {
  Future<Map<String, dynamic>?> getCurrentUserInfo();
  Future<String?> getCurrentUserEmail();
  Future<void> updateUserProfile(String name, String email, String userId);
  Future<void> upgradeSubscription(String planType);
  Future<void> downgradeSubscription(String planType);
  Future<void> deleteUser(String userid);

  // New methods for user preferences
  Future<UserPreferences> getUserPreferences(String userId);
  Future<void> updateUserPreferences(String userId, UserPreferences preferences);
  
  // New methods for progress tracking
  Future<UserProgress> getUserProgress(String userId);
  Future<void> updateUserProgress(String userId, UserProgress progress);
  Future<Map<String, dynamic>> getStudyAnalytics(String userId);
  
  // New methods for achievements and streaks
  Future<void> updateStreak(String userId);
  Future<void> checkAndAwardAchievements(String userId);
  Future<List<Map<String, dynamic>>> getLeaderboardPosition(String userId);
}
