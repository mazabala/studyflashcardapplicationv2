import 'package:flashcardstudyapplication/core/providers/CatSub_Manager.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/subscription/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/services/authentication/authentication_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_auth_service.dart';
import 'package:flashcardstudyapplication/core/providers/subscription_provider.dart'; // Import your subscription provider

// AuthState class to hold the authentication state
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// StateNotifier to manage authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthService _authService;
  final SubscriptionNotifier _subscriptionNotifier;
  final Ref ref;

  AuthNotifier(this._authService, this._subscriptionNotifier, this.ref) : super(const AuthState()) {
    // Listen to auth state changes from Supabase
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _handleAuthStateChange(data.event, data.session);
    });
  }

  void _handleAuthStateChange(AuthChangeEvent event, Session? session) {
    switch (event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
        if (session?.user != null) {
          state = state.copyWith(
            user: session!.user,
            isAuthenticated: true,
            isLoading: false,
          );
        }
        break;
      case AuthChangeEvent.signedOut:
      case AuthChangeEvent.userDeleted:
        state = const AuthState();
        break;
      default:
        break;
    }
  }

  Future<void> googleSignin() async {
    await _authService.signInWithGoogle();
    final user = await _authService.getCurrentUser();
    state = state.copyWith(
      user: user,
      isAuthenticated: true,
      isLoading: false,
    );

          if(state.isAuthenticated == true){
        await ref.read(catSubManagerProvider.notifier).initialize(user!.id);
      }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _authService.signIn(email, password);
      final user = await _authService.getCurrentUser();
      
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      if(state.isAuthenticated == true){
        await ref.read(catSubManagerProvider.notifier).initialize(user!.id);
      }
        
      // Initialize user details after successful sign in
      if (user != null) {
        await _subscriptionNotifier.fetchSubscriptionStatus(user.id);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // Sign the user up
      await _authService.signUp(email, password);
      final user = await _authService.getCurrentUser();
      
      // Update the authentication state
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      // Fetch the subscription status for the user
      // if (user != null) {
      //   await _subscriptionNotifier.fetchSubscriptionStatus(user.id);
      // }

    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      rethrow; // Allow UI to handle the error if needed
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _authService.signOut();
      state = const AuthState(); // Reset to initial state
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
    state = state.copyWith(isLoading: true);
    try {
        print('init started');
        state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
    print('=====Auth Provider Initialization completed==== ');
      
       print ('State: ${state.isLoading}');
  }
}

// Provider for Supabase client
final supabaseProviderClient = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider for AuthService
final authServiceProvider = Provider<IAuthService>((ref) {
  final supabaseClient = ref.watch(supabaseProviderClient);
  return AuthService(supabaseClient);
});

// The main auth provider that will be used by the UI
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final subscriptionNotifier = ref.watch(subscriptionProvider.notifier);  // Access the subscription provider
  return AuthNotifier(authService, subscriptionNotifier, ref);
});
