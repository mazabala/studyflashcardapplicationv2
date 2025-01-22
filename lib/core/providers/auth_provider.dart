import 'dart:async';

import 'package:flashcardstudyapplication/core/providers/CatSub_Manager.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/api/api_manager.dart';
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

  final Ref ref;
  StreamSubscription? _authSubscription;

  AuthNotifier(this._authService,  this.ref) : super(const AuthState()) {
    // Listen to auth state changes from Supabase
_setupAuthListener();
  }

   void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _handleAuthStateChange(data.event, data.session);
    });
  }

  Future<void> setupApiManager() async {
    final apiManager = ApiManager.instance;
    await apiManager.initialize();  
  }

  void _handleAuthStateChange(AuthChangeEvent event, Session? session) async {
    print('Auth state change event: $event');


    // Handle signOut and userDeleted first
    if (event == AuthChangeEvent.signedOut || event == AuthChangeEvent.userDeleted) {
      print('User signed out or deleted');
      state = const AuthState();
      return;
    }

    // Skip processing for initial session if there's no user
    if (event == AuthChangeEvent.initialSession && session?.user == null) {
      print('Initial session with no user, skipping');
      state = const AuthState();
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
        
        // Only proceed with other initializations if state is properly set
        if (state.isAuthenticated && state.user != null) {
          print('Proceeding with user initialization');
          await ref.read(userProvider.notifier).initializeUser();

          if (state.user != null) {  // Double check user is still valid
          print('initializing the api manager');
          await setupApiManager();
          print('initializing the cat sub manager');
          //await ref.read(catSubManagerProvider.notifier).initialize(state.user!.id);
            
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
     
      state = const AuthState();
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

    if(state.isAuthenticated && user != null){
      // Initialize API Manager first
     // setupApiManager();
     // print('API Manager initialized in google signin');
      
      //await ref.read(userProvider.notifier).initializeUser();
      //await ref.read(catSubManagerProvider.notifier).initialize(user.id);
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

      if(state.isAuthenticated && user != null){
        // Initialize API Manager first
        
        
        
       // await ref.read(userProvider.notifier).initializeUser();
       // await ref.read(catSubManagerProvider.notifier).initialize(user.id);
        
        // Initialize user details after successful sign in
        await ref.read(subscriptionProvider.notifier).fetchSubscriptionStatus(user.id);
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
     final AuthResponse response = await _authService.signUp(email, password);

     if (response.user != null) {
      // Update the authentication state only if we have a valid user
      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } else {
      throw Exception('User signup failed - no user returned');
    }
    
     
     await _authService.signIn(email, password);
      
      // Update the authentication state
      state = state.copyWith(
        user: response.user,
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
      throw Exception(e);
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
    print('Starting auth initialization');
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUser();
      print('Current user from initialization: ${user?.id}');
      
      if (user != null) {
        // Initialize API Manager first if user exists
       
        
      }


      // Update state
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );

      // Only proceed with other initializations if authenticated
      if (state.isAuthenticated && state.user != null) {
        await ref.read(userProvider.notifier).initializeUser();
        await ref.read(subscriptionProvider.notifier).fetchSubscriptionStatus(state.user!.id);
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
    print('Auth initialization completed. State: authenticated=${state.isAuthenticated}, user=${state.user?.id}');
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
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService, ref);
});

