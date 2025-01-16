// lib/core/providers/subscription_provider.dart

import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/revenuecat_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';


import 'package:flashcardstudyapplication/core/services/subscription/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_subscription_service.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isExpired;
  final String errorMessage;
  final List<Package>? availablePackages;
  final bool isInitialized;

  SubscriptionState({
    this.isLoading = false,
    this.isExpired = false,
    this.errorMessage = '',
    this.availablePackages = const [],
    this.isInitialized = false,
  });


  SubscriptionState copyWith({
    bool? isLoading,
    bool? isExpired,
    String? errorMessage,
    List<Package>? availablePackages,
    bool? isInitialized,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isExpired: isExpired ?? this.isExpired,
      errorMessage: errorMessage ?? this.errorMessage,
      availablePackages: availablePackages ?? this.availablePackages,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final ISubscriptionService _subscriptionService;

  SubscriptionNotifier(this._subscriptionService) : super(SubscriptionState());

  Future<void> initialize() async {
    if (state.isInitialized) return;
    await _initializeSubscription();
  }

  Future<void> _initializeSubscription() async {
    state = state.copyWith(isLoading: true);
    try {
      await (_subscriptionService as SubscriptionService).initialize();
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        isInitialized: false,
      );
    }
  }

  Future<void> fetchSubscriptionStatus(String userId) async {
    try {
      final subscriptionStatus = await _subscriptionService.getSubscriptionStatus(userId);
      state = state.copyWith(
        isExpired: subscriptionStatus == 'expired' , 
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadPackages() async {
    state = state.copyWith(isLoading: true);
    try {
      final packages = await _subscriptionService.getAvailablePackages();
      state = state.copyWith(
        availablePackages: packages,
        isLoading: false
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false
      );
    }
  }
}

final subscriptionServiceProvider = Provider<AsyncValue<SubscriptionService>>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  final userService = ref.read(userServiceProvider);
  final revenueCatServiceAsync = ref.watch(revenueCatClientProvider);
  
  return revenueCatServiceAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
    data: (revenueCatService) => AsyncValue.data(
      SubscriptionService(
        supabaseClient,
        userService,
        revenueCatService,
      )
    ),
  );
});

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final subscriptionServiceAsync = ref.watch(subscriptionServiceProvider);
  
  return subscriptionServiceAsync.when(
    data: (service) => SubscriptionNotifier(service),
    loading: () => SubscriptionNotifier(
      throw UnimplementedError('Subscription service not ready'),
    ),
    error: (err, stack) => throw Exception('Failed to initialize subscription service: $err'),
  );
});
