import 'dart:developer';

import 'package:flashcardstudyapplication/core/interfaces/i_auth_service.dart';

import 'package:flashcardstudyapplication/core/providers/user_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_admin_service.dart';

import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';
import 'package:flashcardstudyapplication/core/models/user_query_params.dart';

class AdminService implements IAdminService {
  final SupabaseClient _supabaseClient;
  final IAuthService _authService;
  final UserState _userState;

  AdminService(this._supabaseClient, this._authService, this._userState);

  @override
  Future<bool> isSystemAdmin() async {
    try {
      print('admin service: userState: ${_userState.role}');
      return _userState.role == 'admin' || _userState.role == 'superAdmin';
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to check admin status',
          specificType: ErrorType.authorization);
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
          specificType: ErrorType.deckManagement);
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
          specificType: ErrorType.deckManagement);
    }
  }

  @override
  Future<List<String>> getDeckCategories() async {
    try {
      final result =
          await _supabaseClient.from('deck_categories').select('name');

      return (result as List).map((e) => e['name'] as String).toList();
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to get deck categories',
          specificType: ErrorType.deckManagement);
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
        'end_date':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to update user subscription',
          specificType: ErrorType.subscription);
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
          specificType: ErrorType.subscription);
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
          specificType: ErrorType.contentModeration);
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
          specificType: ErrorType.contentModeration);
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
          specificType: ErrorType.userManagement);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUsers({UserQueryParams? params}) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      dynamic query = _supabaseClient.from('users_view').select();

      // Apply search if provided
      if (params?.searchQuery != null && params!.searchQuery!.isNotEmpty) {
        query = query.or(
            'firstname.ilike.%${params.searchQuery}%,lastname.ilike.%${params.searchQuery}%,email.ilike.%${params.searchQuery}%');
      }

      // Apply sorting
      if (params?.sortBy != null) {
        query =
            query.order(params!.sortBy!, ascending: params.ascending ?? true);
      } else {
        query = query.order('created_at', ascending: false);
      }

      // Apply pagination with defaults
      final effectivePage = params?.page ?? 0;
      final effectivePageSize = params?.pageSize ?? 20;
      final start = effectivePage * effectivePageSize;
      final end = start + effectivePageSize - 1;
      query = query.range(start, end);

      final result = await query;
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to get users',
          specificType: ErrorType.userManagement);
    }
  }

  @override
  Future<int> getUsersCount({String? searchQuery}) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      var query = _supabaseClient.from('users_view').select('id');

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'firstname.ilike.%${searchQuery}%,lastname.ilike.%${searchQuery}%,email.ilike.%${searchQuery}%');
      }

      final response = await query;
      return (response as List).length;
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to get users count',
          specificType: ErrorType.userManagement);
    }
  }

  @override
  Future<void> deleteUserAccount(String userId) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      // Call the server-side function to delete user data
      await _supabaseClient.rpc(
        'delete_user_data',
        params: {
          'p_user_id': userId,
        },
      );

      // After successful data deletion, delete the auth user
      await _supabaseClient.auth.admin.deleteUser(userId);
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to delete user data',
          specificType: ErrorType.userManagement);
    }
  }

  @override
  Future<void> inviteUser(String email) async {
    try {
      if (!await isSystemAdmin()) {
        throw ErrorHandler.handleUnauthorized();
      }

      // You might want to add email sending logic here using your API service
      await _authService.inviteUser(email);
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to invite user',
          specificType: ErrorType.userManagement);
    }
  }
}
