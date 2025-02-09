import 'package:flashcardstudyapplication/core/interfaces/i_admin_service.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/providers/supabase_provider.dart';
import 'package:flashcardstudyapplication/core/services/authentication/authentication_service.dart';
import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/services/admin/admin_service.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';

class AdminState {
  final bool isLoading;
  final String error;
  final bool isAdmin;
  final List<String> pendingInvites;
  final List<String> flaggedContent;
  final List<Map<String, dynamic>> users;

  const AdminState({
    this.isLoading = false,
    this.error = '',
    this.isAdmin = false,
    this.pendingInvites = const [],
    this.flaggedContent = const [],
    this.users = const [],
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    bool? isAdmin,
    List<String>? pendingInvites,
    List<String>? flaggedContent, 
    List<Map<String, dynamic>>? users,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAdmin: isAdmin ?? this.isAdmin,
      pendingInvites: pendingInvites ?? this.pendingInvites,
      flaggedContent: flaggedContent ?? this.flaggedContent,
      users: users ?? this.users,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final IAdminService _adminService;

  AdminNotifier(this._adminService) : super(const AdminState()) {
    _initializeAdminState();
  }

  Future<void> _initializeAdminState() async {
    await checkAdminStatus();
    if (state.isAdmin) {
      await Future.wait([

        loadFlaggedContent(),
      ]);
    }
  }

  Future<void> checkAdminStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      final isAdmin = await _adminService.isSystemAdmin();
      state = state.copyWith(isAdmin: isAdmin);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }


  Future<void> loadFlaggedContent() async {
    try {
      state = state.copyWith(isLoading: true);
      final content = await _adminService.getFlaggedContent();
      state = state.copyWith(flaggedContent: content);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> inviteUser(String email) async {
    try {
      state = state.copyWith(isLoading: true);
      await _adminService.inviteUser(email);

    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  
  Future<void> loadUsers() async {
    try {
      state = state.copyWith(isLoading: true);
      final users = await _adminService.getUsers();

      state = state.copyWith(users: users);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> reviewFlaggedContent(String contentId, bool approved) async {
    try {
      state = state.copyWith(isLoading: true);
      await _adminService.reviewFlaggedContent(contentId, approved);
      await loadFlaggedContent();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      state = state.copyWith(isLoading: true);
      await _adminService.updateUserRole(userId, role);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true);
      await _adminService.deleteUserAccount(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateUserSubscription(String userId, String tier) async {
    try {
      state = state.copyWith(isLoading: true);
      await _adminService.updateUserSubscription(userId, tier);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> systemCreateDecks(List<SystemDeckConfig> configs) async {
    try {
      state = state.copyWith(isLoading: true);
      await _adminService.systemCreateDecks(configs);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
