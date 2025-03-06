import 'dart:async';
import 'dart:developer';

import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/services/api/api_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_auth_service.dart';
// Import your subscription provider

// AuthenthicationState class to hold the authentication state
class AuthenthicationState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AuthenthicationState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthenthicationState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthenthicationState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// StateNotifier to manage authentication state
class AuthNotifier extends StateNotifier<AuthenthicationState> {
  final IAuthService _authService;
  final Ref _ref;
  StreamSubscription? _authSubscription;

  AuthNotifier(this._authService, this._ref)
      : super(const AuthenthicationState()) {
    // Listen to auth state changes from Supabase
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _handleAuthenthicationStateChange(data.event, data.session);
    });
  }

  Future<void> setupApiManager() async {
    final apiManager = ApiManager.instance;
    await apiManager.initialize();
  }

  void _handleAuthenthicationStateChange(
      AuthChangeEvent event, Session? session) async {
    print('Auth state change event: $event');

    // Handle signOut and userDeleted first
    if (event == AuthChangeEvent.signedOut ||
        event == AuthChangeEvent.userDeleted) {
      _ref.read(analyticsProvider.notifier).trackEvent('user_signed_out');
      _ref.read(analyticsProvider.notifier).reset();
      state = const AuthenthicationState();
      return;
    }

    // Skip processing for initial session if there's no user
    if (event == AuthChangeEvent.initialSession && session?.user == null) {
      print('Initial session with no user, skipping');
      state = const AuthenthicationState();
      return;
    }

    // Only process these events if we have a valid session and user
    if ((event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.tokenRefreshed) &&
        session?.user != null) {
      try {
        // Update state after API Manager initialization
        state = state.copyWith(
          user: session!.user,
          isAuthenticated: true,
          isLoading: false,
        );

        _ref.read(analyticsProvider.notifier).identifyUser(
          session!.user.id,
          userProperties: {
            'email': session.user.email,
            'last_sign_in': DateTime.now().toIso8601String(),
          },
        );

        // Only proceed with other initializations if state is properly set
        if (state.isAuthenticated && state.user != null) {
          print('Proceeding with user initialization');
          await _ref.read(userStateProvider.notifier).initializeUser();
          await _ref
              .read(subscriptionStateProvider.notifier)
              .fetchSubscriptionStatus(state.user!.id);

          if (state.user != null) {
            // Double check user is still valid
            print('initializing the api manager');
            await setupApiManager();
            print('initializing the cat sub manager');
            print('API Manager initialized in auth provider');
          }
        }
      } catch (e) {
        print('Error during auth state change: $e');
        state = state.copyWith(
          user: null,
          isAuthenticated: false,
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    } else {
      state = const AuthenthicationState();
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _authService.signInWithApple();

    final user = await _authService.getCurrentUser();
    state = state.copyWith(
      user: user,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  Future<void> googleSignin() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _authService.signInWithGoogle();
    final user = await _authService.getCurrentUser();
    _ref.read(analyticsProvider.notifier).trackLogin(method: 'google');
    _ref.read(analyticsProvider.notifier).identifyUser(
      user?.id ?? '',
      userProperties: {'email': user?.email},
    );
    state = state.copyWith(
      user: user,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authService.signIn(email, password);
      final user = await _authService.getCurrentUser();
      log('user: $user');
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      if (state.isAuthenticated && user != null) {
        // Initialize API Manager first
        // await _ref.read(userStateProvider.notifier).initializeUser();

        // Initialize user details after successful sign in
        await _ref
            .read(subscriptionStateProvider.notifier)
            .fetchSubscriptionStatus(user.id);
      }
    } catch (e) {
      print('in the catch auth');
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signUp(
      String email, String password, String firstName, String lastName) async {
    try {
      state = state.copyWith(isLoading: true);

      // Sign the user up
      final AuthResponse response =
          await _authService.signUp(email, password, firstName, lastName);

      if (response.user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: response.user,
          isLoading: false,
        );

        _ref.read(analyticsProvider.notifier).trackEvent(
          'user_signed_up',
          properties: {
            'method': 'email',
            'has_first_name': firstName.isNotEmpty,
            'has_last_name': lastName.isNotEmpty,
          },
        );
      } else {
        throw Exception('User signup failed - no user returned');
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authService.signOut();
      _ref.read(analyticsProvider.notifier).trackLogout();
      _ref.read(analyticsProvider.notifier).reset();
      state = const AuthenthicationState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> refreshSession() async {
    try {
      await _authService.refreshToken();
      final user = await _authService.getCurrentUser();
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isAuthenticated: false,
      );
      rethrow;
    }
  }

  // Check current authentication status
  Future<void> checkAuthStatus() async {
    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    await _authService.forgotPassword(email);
  }

  Future<void> InviteUser(String email, String message) async {
    await _authService.inviteUser(email);
  }

  Future<void> initializeAuth() async {
    print('Starting auth initialization');
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUser();
      print('Current user from initialization: ${user?.id}');

      if (user != null) {
        // Initialize API Manager first if user exists
        await setupApiManager();
      }

      // Update state
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );

      // Only proceed with other initializations if authenticated
      if (state.isAuthenticated && state.user != null) {
        await _ref.read(userStateProvider.notifier).initializeUser();
        await _ref
            .read(subscriptionStateProvider.notifier)
            .fetchSubscriptionStatus(state.user!.id);
      }
    } catch (e) {
      print('Error during auth initialization: $e');
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    }
    print(
        'Auth initialization completed. State: authenticated=${state.isAuthenticated}, user=${state.user?.id}');
  }
}
