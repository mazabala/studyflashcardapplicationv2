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

// Infrastructure Providers
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseServiceProvider = Provider<ISupabaseService>((ref) {
  return SupabaseService();
});

// API Layer Providers
final apiClientProvider = Provider<IApiService>((ref) {
  return ApiClient();
});

final apiManagerProvider = Provider<IApiManager>((ref) {
  return ApiManager.instance;
});

// Service Layer Providers
final authServiceProvider = Provider<IAuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

final subscriptionServiceProvider = Provider<ISubscriptionService>((ref) {
  return SubscriptionService(
    ref.watch(supabaseClientProvider),
    ref.watch(userStateProvider),
  );
});

final userServiceProvider = Provider<IUserService>((ref) {
  return UserService(
    ref.watch(supabaseClientProvider),
    ref.watch(apiClientProvider),
  );
});

final deckServiceProvider = Provider<IDeckService>((ref) {
  return DeckService(
    ref.watch(supabaseClientProvider),
    ref.watch(apiClientProvider),
  );
});

final adminServiceProvider = Provider<IAdminService>((ref) {
  return AdminService(
    ref.watch(supabaseClientProvider),
    ref.watch(authServiceProvider),
  );
});

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, void>((ref) {
  final posthogService = ref.watch(posthogServiceProvider);
  return AnalyticsNotifier(posthogService, ref);
}); 

final posthogServiceProvider = Provider<IPostHogService>((ref) {
  final supabase = Supabase.instance.client;
  return PostHogService(supabase);
});

// State Management Layer
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthenthicationState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider), ref);
});


final subscriptionStateProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref.watch(subscriptionServiceProvider));
});

final userStateProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.watch(userServiceProvider), ref);
});


final deckStateProvider = StateNotifierProvider<DeckNotifier, DeckState>((ref) {
  return DeckNotifier(
    ref.watch(deckServiceProvider),
    ref.watch(userServiceProvider),
    ref,
  );
});

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService(ref.watch(supabaseClientProvider));
});

final flashcardStateProvider = StateNotifierProvider<FlashcardNotifier, FlashcardState>((ref) {
  final deckService = ref.watch(deckServiceProvider);
  final progressService = ref.watch(progressServiceProvider);
  final userService = ref.watch(userServiceProvider);
  final spacedRepetitionService = ref.watch(spacedRepetitionServiceProvider);
  
  return FlashcardNotifier(
    deckService,
    progressService,
    userService,
    spacedRepetitionService,
    ref,
  );
});

final adminStateProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.watch(adminServiceProvider));
});

// Safe Providers (with null safety checks)
final safeSubscriptionProvider = Provider<SubscriptionState>((ref) {
  final authState = ref.watch(authStateProvider);
  if (!authState.isAuthenticated) {
    return  SubscriptionState();
  }
  return ref.watch(subscriptionStateProvider);
});

// RevenueCat Integration
final revenueCatClientProvider = StateNotifierProvider<RevenueCatNotifier, RevenueCatService>((ref) {
  return RevenueCatNotifier(ref);
}); 

// Collection Service Provider
final collectionServiceProvider = Provider<CollectionService>((ref) {
  return CollectionService(ref.watch(supabaseClientProvider));
});

// Cached collection providers with pagination
final userCollectionsCacheProvider = StateProvider<Map<int, List<UserCollection>>>((ref) => {});
final publicCollectionsCacheProvider = StateProvider<Map<int, List<Collection>>>((ref) => {});

final userCollectionsProvider = FutureProvider.family<List<UserCollection>, int>((ref, page) async {
  final cache = ref.watch(userCollectionsCacheProvider);
  final pageSize = 20;

  if (cache.containsKey(page)) {
    return cache[page]!;
  }

  final service = ref.watch(collectionServiceProvider);
  final collections = await service.getUserCollections(page: page, pageSize: pageSize);
  
  ref.read(userCollectionsCacheProvider.notifier).update((state) => {
    ...state,
    page: collections,
  });

  return collections;
});

final publicCollectionsProvider = FutureProvider.family<List<Collection>, int>((ref, page) async {
  final cache = ref.watch(publicCollectionsCacheProvider);
  final pageSize = 20;

  if (cache.containsKey(page)) {
    return cache[page]!;
  }

  final service = ref.watch(collectionServiceProvider);
  final collections = await service.getCollectionPool(page: page, pageSize: pageSize);
  
  ref.read(publicCollectionsCacheProvider.notifier).update((state) => {
    ...state,
    page: collections,
  });

  return collections;
});

// Cache invalidation provider
final collectionCacheInvalidationProvider = Provider((ref) {
  ref.listen(userStateProvider, (previous, next) {
    if (previous?.userId != next.userId) {
      ref.invalidate(userCollectionsCacheProvider);
      ref.invalidate(publicCollectionsCacheProvider);
    }
  });
});

// Anki Service Provider
final ankiServiceProvider = Provider<AnkiService>((ref) {
  return AnkiService();
});

// User Preferences Provider
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  final userService = ref.watch(userServiceProvider);
  return UserPreferencesNotifier(userService);
});

// Spaced Repetition Service Provider
final spacedRepetitionServiceProvider = Provider<SpacedRepetitionService>((ref) {
  final userPrefs = ref.watch(userPreferencesProvider);
  final service = SpacedRepetitionService();
  service.toggleSpacedRepetition(userPrefs.isSpacedRepetitionEnabled);
  return service;
});

