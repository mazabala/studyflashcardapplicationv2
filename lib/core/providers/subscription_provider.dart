// lib/core/providers/subscription_provider.dart

import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/subscription/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_subscription_service.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isExpired;
  final String errorMessage;

  SubscriptionState({
    this.isLoading = false,
    this.isExpired = false,
    this.errorMessage = '',
  });

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isExpired,
    String? errorMessage,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isExpired: isExpired ?? this.isExpired,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final ISubscriptionService _subscriptionService;

  SubscriptionNotifier(this._subscriptionService) : super(SubscriptionState());

  Future<void> fetchSubscriptionStatus(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
     
      final isExpired = await _subscriptionService.checkIfExpired();
      
      state = state.copyWith(isLoading: false, isExpired: isExpired);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateSubscription(String userId, String tier) async {
    try {
      await _subscriptionService.updateSubscription(userId, tier);
      await fetchSubscriptionStatus(userId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> renewSubscription(String userId) async {
    try {
      await _subscriptionService.renewSubscription(userId);
      await fetchSubscriptionStatus(userId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> cancelSubscription(String userId) async {
    try {
      await _subscriptionService.cancelSubscription(userId);
      await fetchSubscriptionStatus(userId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
// Define the provider for SubscriptionService
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  final userService = ref.read(userServiceProvider);
  return SubscriptionService(supabaseClient, userService);
});

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final subscriptionService = ref.read(subscriptionServiceProvider);
  return SubscriptionNotifier(subscriptionService);
});
