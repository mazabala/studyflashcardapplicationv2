import 'dart:developer';

import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_user_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_api_service.dart';
import 'package:flashcardstudyapplication/core/models/user_preferences.dart';
import 'package:flashcardstudyapplication/core/models/user_progress.dart';
import 'package:uuid/uuid.dart';

class UserService implements IUserService {
  final SupabaseClient _supabaseClient;
  final IApiService _apiService;

  UserService(this._supabaseClient, this._apiService);

@override
Future<Map<String, dynamic>?> getCurrentUserInfo() async {

  
  try {
  final user =  _supabaseClient.auth.currentUser;
  

  if (user != null) {
    // Get the user info from our users table
    final userInfo = await _fetchUser(user.id);
    
 
    if (userInfo != null) {
      // Create a new map that combines auth user data and our custom user data
      return {
        'id': user.id,
        'email': user.email,
        'created_at': userInfo['created_at'],
        'firstname': userInfo['firstname'],
        'lastname': userInfo['lastname'],
        'subscription_name': userInfo['subscriptiontype_name'],
        'subscription_status': userInfo['subscription_status'],
        'subscription_expiry_date': userInfo['subscription_expiry_date'],
        'subscription_planID': userInfo['subscriptionid'],
        'user_is_active': userInfo['user_is_active'],
        'role': userInfo['role']
      };
    }
  }} on Exception catch (e) {
  print('service user error: $e');
}
  
  return null; // Return null if no user is logged in or if user data isn't found
}

@override
Future<Map<String, dynamic>?> _fetchUser(String userid) async {
  final user = await _supabaseClient
      .from('users_view')
      .select('*')
      .eq('id', userid)
      .maybeSingle();
  return user;
}

@override
Future<void> deleteUser(String userid) async {

  try {

    if (userid == null || userid == '') {
      throw Exception('User ID is required');
    }

    final userSubscription = await _supabaseClient
      .from('user_subscriptions')
      .delete()
      .eq('user_id', userid);


await _supabaseClient.rpc('deleteUser');
  //  await _supabaseClient
  //     .auth.admin.deleteUser(userid);


} catch (e) {
  throw ErrorHandler.handle(e, 
        message: 'Failed to delete user: $e',
        specificType: ErrorType.userProfile
      );
}
}


  @override
  Future<String?> getCurrentUserEmail() async {
    final user = _supabaseClient.auth.currentUser;
    return user?.email;
  }

  @override
  Future<void> updateUserProfile(String firstname, String ?lastname, String userId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw ErrorHandler.handleUserNotFound();
    }

    try {
      final result = await _supabaseClient.from('users').update({
        'first_name': firstname,
        'last_name': lastname,
      })
      .eq('id', userId)
      .select();

      if (result == null) {
        print('result: $result');
        throw ErrorHandler.handleProfileUpdateError(
          null,
          'Failed to update profile. Error: $result'
        );
      }
    } on PostgrestException catch (e) {
      throw ErrorHandler.handleDatabaseError(e, specificType: ErrorType.userProfile);
    } on AuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to update profile',
        specificType: ErrorType.userProfile
      );
    }
  }

  @override
  Future<void> upgradeSubscription(String planType) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw ErrorHandler.handleUserNotFound();
    }

    try {
      final result = await _supabaseClient.from('user_subscriptions').upsert({
        'user_id': user.id,
        'sub': planType,
        'status': 'active',
        'expiry_date': _getExpiryDateForPlan(planType),
      });

      if (result == null) {
        throw ErrorHandler.handleSubscriptionError(
          null,
          'Failed to upgrade subscription'
        );
      }
    } on PostgrestException catch (e) {
      throw ErrorHandler.handleDatabaseError(e, specificType: ErrorType.subscription);
    } on AuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to upgrade subscription',
        specificType: ErrorType.subscription
      );
    }
  }

DateTime _getExpiryDateForPlan(String planType) {
    final now = DateTime.now();
    switch (planType.toLowerCase()) {
      case 'basic':
        return now.add(const Duration(days: 30));
      case 'advanced':
        return now.add(const Duration(days: 30));
      default:
        return now.add(const Duration(days: 3));
    }
  }

  @override
  Future<void> downgradeSubscription(String planType) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw ErrorHandler.handleUserNotFound();
    }

    try {
      final result = await _supabaseClient.from('subscriptions').upsert({
        'user_id': user.id,
        'plan_type': planType,
        'status': 'active',
        'expiry_date': _getExpiryDateForPlan(planType),
      });

      if (result == null) {
        throw ErrorHandler.handleSubscriptionError(
          null,
          'Failed to downgrade subscription'
        );
      }
    } on PostgrestException catch (e) {
      throw ErrorHandler.handleDatabaseError(e, specificType: ErrorType.subscription);
    } on AuthException catch (e) {
      throw ErrorHandler.handleAuthError(e);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to downgrade subscription',
        specificType: ErrorType.subscription
      );
    }
  }

  @override
  Future<UserPreferences> getUserPreferences(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        // Create default preferences if none exist
        final defaultPreferences = {
          'user_id': userId,
          'theme_mode': 'system',
          'daily_goal_cards': 10,
          'study_session_duration': 30,
          'sound_enabled': true,
          'haptic_feedback': true,
          'created_at': DateTime.now().toIso8601String(),
          'last_updated': DateTime.now().toIso8601String(),
        };

        final newResponse = await _supabaseClient
            .from('user_preferences')
            .insert(defaultPreferences)
            .select()
            .single();

        return UserPreferences.fromJson(newResponse);
      }

      return UserPreferences.fromJson(response);
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to get user preferences',
          specificType: ErrorType.userProfile);
    }
  }

  @override
  Future<void> updateUserPreferences(String userId, UserPreferences preferences) async {
    try {
      await _supabaseClient
          .from('user_preferences')
          .upsert(preferences.toJson())
          .eq('user_id', userId);
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to update user preferences',
          specificType: ErrorType.userProfile);
    }
  }

  @override
  Future<UserProgress> getUserProgress(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Create default progress entry if none exists
        final defaultProgress = {
          
          'user_id': userId,
          'daily_cards_covered': {},
          'study_time': {},
          'confidence_levels': {},
          'current_streak': 0,
          'longest_streak': 0,
          'last_study_date': DateTime.now().toIso8601String(),
          'achievements': {},
          'performance_metrics': {},
        };

        final newResponse = await _supabaseClient
            .from('user_progress')
            .insert(defaultProgress)
            .select()
            .single();

        return UserProgress.fromJson(newResponse);
      }

      return UserProgress.fromJson(response);
    } catch (e) {
      log(e.toString());
      throw ErrorHandler.handle(e,
          message: 'Failed to get user progress',
          specificType: ErrorType.userProfile);
    }
  }

  @override
  Future<void> updateUserProgress(String userId, UserProgress progress) async {
    try {
      await _supabaseClient
          .from('user_progress')
          .upsert(progress.toJson())
          .eq('user_id', userId);
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to update user progress',
          specificType: ErrorType.userProfile);
    }
  }

  @override
  Future<Map<String, dynamic>> getStudyAnalytics(String userId) async {
    try {
      final response = await _supabaseClient.rpc(
        'calculate_user_analytics',
        params: {
          'p_user_id': userId,
          'p_days_ago': 30,
        },
      );

      if (response == null) {
        return {
          'total_study_time': 0,
          'average_daily_cards': 0,
          'current_streak': 0,
          'longest_streak': 0,
          'average_confidence': 0.0,
          'recent_sessions': [],
          'achievements_earned': 0,
          'performance_trends': {},
        };
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      log(e.toString());
      throw ErrorHandler.handle(e,
        message: 'Failed to get study analytics',
        specificType: ErrorType.userProfile
      );
    }
  }

  @override
  Future<void> updateStreak(String userId) async {
    try {
      final progress = await getUserProgress(userId);
      final lastStudyDate = progress.lastStudyDate;
      final today = DateTime.now();

      if (lastStudyDate.day != today.day) {
        final isConsecutive = lastStudyDate.difference(today).inDays.abs() == 1;
        final newCurrentStreak = isConsecutive ? progress.currentStreak + 1 : 1;
        final newLongestStreak = newCurrentStreak > progress.longestStreak
            ? newCurrentStreak
            : progress.longestStreak;

        final updatedProgress = progress.copyWith(
          currentStreak: newCurrentStreak,
          longestStreak: newLongestStreak,
          lastStudyDate: today,
        );

        await updateUserProgress(userId, updatedProgress);
      }
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to update streak',
          specificType: ErrorType.userProfile);
    }
  }

  @override
  Future<void> checkAndAwardAchievements(String userId) async {
    try {
      final progress = await getUserProgress(userId);
      final analytics = await getStudyAnalytics(userId);
      
      final achievements = progress.achievements;
      
      // Check for new achievements
      if (progress.currentStreak >= 7 && !achievements.containsKey('week_streak')) {
        achievements['week_streak'] = {
          'title': '7-Day Streak',
          'description': 'Studied for 7 consecutive days',
          'awarded_at': DateTime.now().toIso8601String(),
        };
      }

      if (analytics['total_study_time'] >= 600 && !achievements.containsKey('study_master')) {
        achievements['study_master'] = {
          'title': 'Study Master',
          'description': 'Completed 10 hours of study time',
          'awarded_at': DateTime.now().toIso8601String(),
        };
      }

      // Update progress with new achievements
      final updatedProgress = progress.copyWith(achievements: achievements);
      await updateUserProgress(userId, updatedProgress);
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to check achievements',
          specificType: ErrorType.userProfile);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboardPosition(String userId) async {
    try {
      final response = await _supabaseClient.rpc('get_user_leaderboard', 
        params: {'user_id_param': userId}
      );
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to get leaderboard position',
          specificType: ErrorType.userProfile);
    }
  }
}