import 'package:flashcardstudyapplication/core/models/collection.dart';
import 'package:flashcardstudyapplication/core/models/user_collection.dart';
import 'package:flashcardstudyapplication/core/providers/admin_provider.dart';
import 'package:flashcardstudyapplication/core/providers/analytics_provider.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/deck_provider.dart';
import 'package:flashcardstudyapplication/core/providers/flashcard_provider.dart';
import 'package:flashcardstudyapplication/core/providers/revenuecat_provider.dart';
import 'package:flashcardstudyapplication/core/providers/subscription_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_preferences_provider.dart';
import 'package:flashcardstudyapplication/core/models/user_preferences.dart';
import 'package:flashcardstudyapplication/core/services/analytics/posthog_service.dart';
import 'package:flashcardstudyapplication/core/services/collection/collection_service.dart';
import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Interfaces
import '../interfaces/i_auth_service.dart';
import '../interfaces/i_subscription_service.dart';
import '../interfaces/i_database_service.dart';
import '../interfaces/i_user_service.dart';
import '../interfaces/i_deck_service.dart';
import '../interfaces/i_admin_service.dart';
import '../interfaces/i_supabase_service.dart';
import '../interfaces/i_api_service.dart';
import '../interfaces/i_api_manager.dart';
import '../interfaces/i_billing_service.dart';
import '../interfaces/i_posthog_service.dart';
import '../interfaces/i_collection_service.dart';

// Services
import '../services/authentication/authentication_service.dart';
import '../services/subscription/subscription_service.dart';
import '../services/api/api_client.dart';
import '../services/api/api_manager.dart';
import '../services/deck/deck_service.dart';
import '../services/admin/admin_service.dart';
import '../services/supabase/supabase_service.dart';
import '../services/billing/billing_service.dart';
import '../services/progress/progress_service.dart';
import '../services/anki/anki_service.dart';
import '../services/spaced_repetition/spaced_repetition_service.dart';

// Initialization Provider
final initializationProvider = StateProvider<bool>((ref) => false);

// Infrastructure Providers - These are singleton-like providers that should be kept alive
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  ref.keepAlive(); // Keep the client alive throughout the app lifecycle
  return Supabase.instance.client;
});

final supabaseServiceProvider = Provider<ISupabaseService>((ref) {
  ref.keepAlive(); // Keep the service alive
  return SupabaseService();
});

// API Layer Providers - These should be kept alive as they're fundamental services
final apiClientProvider = Provider<IApiService>((ref) {
  ref.keepAlive();
  return ApiClient();
});

final apiManagerProvider = Provider<IApiManager>((ref) {
  ref.keepAlive();
  return ApiManager.instance;
});

// Service Layer Providers - Optimize dependencies and keep core services alive
final authServiceProvider = Provider<IAuthService>((ref) {
  ref.keepAlive();
  return AuthService(
      ref.read(supabaseClientProvider)); // Use read instead of watch
});

final subscriptionServiceProvider = Provider<ISubscriptionService>((ref) {
  // Only rebuild when user state changes
  final userState =
      ref.watch(userStateProvider.select((state) => state.userId));
  return SubscriptionService(
    ref.read(supabaseClientProvider),
    ref.watch(userStateProvider),
  );
});

final userServiceProvider = Provider<IUserService>((ref) {
  ref.keepAlive();
  return UserService(
    ref.read(supabaseClientProvider),
    ref.read(apiClientProvider),
  );
});

// Collection Service Provider
final collectionServiceProvider = Provider<ICollectionService>((ref) {
  ref.keepAlive();
  return CollectionService(ref.read(supabaseClientProvider));
});

final deckServiceProvider = Provider<IDeckService>((ref) {
  ref.keepAlive();
  return DeckService(
    ref.read(supabaseClientProvider),
    ref.read(apiClientProvider),
    ref.read(collectionServiceProvider),
  );
});

final adminServiceProvider = Provider<IAdminService>((ref) {
  // Only rebuild when auth state changes
  final isAdmin = ref.watch(userStateProvider.select((state) => state.isAdmin));
  return AdminService(
    ref.read(supabaseClientProvider),
    ref.read(authServiceProvider),
    ref.watch(userStateProvider),
  );
});

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, void>((ref) {
  ref.keepAlive(); // Analytics should stay alive
  final posthogService = ref.read(posthogServiceProvider);
  return AnalyticsNotifier(posthogService, ref);
});

final posthogServiceProvider = Provider<IPostHogService>((ref) {
  ref.keepAlive();
  final supabase = ref.read(supabaseClientProvider);
  return PostHogService(supabase);
});

// State Management Layer - Optimize with selective watching
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthenthicationState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider), ref);
});

final subscriptionStateProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref.read(subscriptionServiceProvider));
});

// Public collections provider
final publicCollectionsProvider =
    FutureProvider.family<List<Collection>, int>((ref, page) async {
  final service = ref.read(collectionServiceProvider);
  return service.getCollectionPool(page: page, pageSize: 20);
});

final userStateProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(
    ref.read(userServiceProvider),
    ref.read(collectionServiceProvider),
    ref,
  );
});

final deckStateProvider = StateNotifierProvider<DeckNotifier, DeckState>((ref) {
  return DeckNotifier(
    ref.read(deckServiceProvider),
    ref.read(userServiceProvider),
    ref,
  );
});

final progressServiceProvider = Provider<ProgressService>((ref) {
  ref.keepAlive();
  return ProgressService(ref.read(supabaseClientProvider));
});

final flashcardStateProvider =
    StateNotifierProvider<FlashcardNotifier, FlashcardState>((ref) {
  // Only get the services once since they don't need to be watched
  final deckService = ref.read(deckServiceProvider);
  final progressService = ref.read(progressServiceProvider);
  final userService = ref.read(userServiceProvider);
  final spacedRepetitionService = ref.read(spacedRepetitionServiceProvider);

  return FlashcardNotifier(
    deckService,
    progressService,
    userService,
    spacedRepetitionService,
    ref,
  );
});

final adminStateProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.read(adminServiceProvider));
});

// Safe Providers with optimized dependency tracking
final safeSubscriptionProvider = Provider<SubscriptionState>((ref) {
  final isAuthenticated =
      ref.watch(authStateProvider.select((state) => state.isAuthenticated));
  if (!isAuthenticated) {
    return SubscriptionState();
  }
  return ref.watch(subscriptionStateProvider);
});

// RevenueCat Integration with optimized initialization
final revenueCatClientProvider =
    StateNotifierProvider<RevenueCatNotifier, RevenueCatService>((ref) {
  ref.keepAlive(); // Keep RevenueCat client alive
  return RevenueCatNotifier(ref);
});

// Service providers with optimized initialization
final ankiServiceProvider = Provider<AnkiService>((ref) {
  ref.keepAlive();
  return AnkiService();
});

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier(ref.read(userServiceProvider));
});

final spacedRepetitionServiceProvider =
    Provider<SpacedRepetitionService>((ref) {
  // Only rebuild when spaced repetition setting changes
  final isEnabled = ref.watch(userPreferencesProvider
      .select((prefs) => prefs.isSpacedRepetitionEnabled));
  final service = SpacedRepetitionService();
  service.toggleSpacedRepetition(isEnabled);
  return service;
});

///TODO IS THIS EFFICIENT?
///TODO, IS THIS CALLING TOO MANY TIMES?