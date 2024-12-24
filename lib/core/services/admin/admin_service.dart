import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_admin_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_api_service.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';

class AdminService implements IAdminService {
  final SupabaseClient _supabaseClient;
  final IApiService _apiService;

  AdminService(this._supabaseClient, this._apiService);

  @override
  Future<bool> isSystemAdmin() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }

      final userRole = await _supabaseClient
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .maybeSingle();

      return userRole?['role'] == 'superAdmin';
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to check admin status',
        specificType: ErrorType.authorization
      );
    }
  }

  @override
  Future<void> systemCreateDecks(List<SystemDeckConfig> configs) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      for (var config in configs) {
        await _supabaseClient.from('decks').insert({
          'title': config.title,
          'category': config.category,
          'difficulty_level': config.difficultyLevel,
          'is_system': true,
          'created_by': _supabaseClient.auth.currentUser?.id,
        });
      }
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to create system decks',
        specificType: ErrorType.deckManagement
      );
    }
  }

  @override
  Future<void> addDeckCategory(String category) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      await _supabaseClient.from('deck_categories').insert({
        'name': category,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to add deck category',
        specificType: ErrorType.deckManagement
      );
    }
  }

  @override
  Future<List<String>> getDeckCategories() async {
    try {
      final result = await _supabaseClient
          .from('deck_categories')
          .select('name');

      return (result.data as List).map((e) => e['name'] as String).toList();
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to get deck categories',
        specificType: ErrorType.deckManagement
      );
    }
  }

  @override
  Future<void> updateUserSubscription(String userId, String tier) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      await _supabaseClient.from('user_subscriptions').upsert({
        'user_id': userId,
        'subscriptionID': tier,
        'start_date': DateTime.now().toIso8601String(),
        'end_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to update user subscription',
        specificType: ErrorType.subscription
      );
    }
  }

  @override
  Future<void> cancelUserSubscription(String userId) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      await _supabaseClient
          .from('user_subscriptions')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to cancel user subscription',
        specificType: ErrorType.subscription
      );
    }
  }

  @override
  Future<List<String>> getFlaggedContent() async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      final result = await _supabaseClient
          .from('flagged_content')
          .select()
          .eq('reviewed', false);
          

      return (result.data as List).map((e) => e['content_id'] as String).toList();
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to get flagged content',
        specificType: ErrorType.contentModeration
      );
    }
  }

  @override
  Future<void> reviewFlaggedContent(String contentId, bool approved) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      await _supabaseClient.from('flagged_content').update({
        'reviewed': true,
        'approved': approved,
        'reviewed_at': DateTime.now().toIso8601String(),
        'reviewed_by': _supabaseClient.auth.currentUser?.id,
      }).eq('content_id', contentId);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to review flagged content',
        specificType: ErrorType.contentModeration
      );
    }
  }

  @override
  Future<void> updateUserRole(String userId, String role) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      await _supabaseClient.from('user_roles').upsert({
        'user_id': userId,
        'role': role,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to update user role',
        specificType: ErrorType.userManagement
      );
    }
  }

  @override
  Future<List<String>> getUsersByRole(String role) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      final result = await _supabaseClient
          .from('user_roles')
          .select('user_id')
          .eq('role', role);
          

      return (result.data as List).map((e) => e['user_id'] as String).toList();
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to get users by role',
        specificType: ErrorType.userManagement
      );
    }
  }

  @override
  Future<void> deleteUserAccount(String userId) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      // First archive the data
      await archiveUserData(userId);
      
      // Then delete from auth
      await _supabaseClient.auth.admin.deleteUser(userId);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to delete user account',
        specificType: ErrorType.userManagement
      );
    }
  }

  @override
  Future<void> deleteUserData(String userId) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      // Delete user's data from various tables
      await Future.wait([
        _supabaseClient.from('user').delete().eq('user_id', userId), //TODO: Check if this is correct
        _supabaseClient.from('user_decks').delete().eq('user_id', userId),
        _supabaseClient.from('user_subscriptions').delete().eq('user_id', userId),
        _supabaseClient.from('user_roles').delete().eq('user_id', userId),
      ]);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to delete user data',
        specificType: ErrorType.userManagement
      );
    }
  }

  @override
  Future<void> archiveUserData(String userId) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      // Get user's data
      final userData = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      // Archive it
      await _supabaseClient.from('archived_users').insert({
        ...userData,
        'archived_at': DateTime.now().toIso8601String(),
        'archived_by': _supabaseClient.auth.currentUser?.id,
      });
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to archive user data',
        specificType: ErrorType.userManagement
      );
    }
  }

  @override
  Future<void> inviteUser(String email, {String? role, String? message}) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      await _supabaseClient.from('user_invites').insert({
        'email': email,
        'role': role,
        'message': message,
        'invited_by': _supabaseClient.auth.currentUser?.id,
        'invited_at': DateTime.now().toIso8601String(),
        'status': 'pending'
      });

      // You might want to add email sending logic here using your API service
      await _apiService.sendInviteEmail(email, message); //TODO: Implement this - change to match the current documentation
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to invite user',
        specificType: ErrorType.userManagement
      );
    }
  }

  
}
