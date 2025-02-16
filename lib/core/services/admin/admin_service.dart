import 'package:flashcardstudyapplication/core/interfaces/i_auth_service.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/authentication/authentication_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_admin_service.dart';

import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';

class AdminService implements IAdminService {
  final SupabaseClient _supabaseClient;
  final IAuthService _authService;


  AdminService(this._supabaseClient, this._authService);

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

      return (result as List).map((e) => e['name'] as String).toList();
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
          

      return (result as List).map((e) => e['content_id'] as String).toList();
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
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      final result = await _supabaseClient
          .from('users_view')
          .select('*');

      
      return List<Map<String, dynamic>>.from(result);
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
  Future<void> inviteUser(String email ) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }



      // You might want to add email sending logic here using your API service
      await _authService.inviteUser(email); 
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to invite user',
        specificType: ErrorType.userManagement
      );
    }
  }

  
}
