// lib/core/providers/subscription_provider.dart

import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/revenuecat_provider.dart';
import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flashcardstudyapplication/core/services/subscription/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_subscription_service.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isExpired;
  final String errorMessage;
  final List<Package>? availablePackages;

  SubscriptionState({
    this.isLoading = false,
    this.isExpired = false,
    this.errorMessage = '',
    this.availablePackages = const [],
  });


  SubscriptionState copyWith({
    bool? isLoading,
    bool? isExpired,
    String? errorMessage,
    List<Package>? availablePackages,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isExpired: isExpired ?? this.isExpired,
      errorMessage: errorMessage ?? this.errorMessage,
      availablePackages: availablePackages ?? this.availablePackages,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final ISubscriptionService _subscriptionService;

  SubscriptionNotifier(this._subscriptionService) : super(SubscriptionState());

  Future<void> loadPackages() async {
    state = state.copyWith(isLoading: true);
    try {
      
      state = state.copyWith(
        availablePackages: null,
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



final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  final userService = ref.read(userServiceProvider);
  final revenueCatService = ref.read(revenueCatClientProvider);
  
  return SubscriptionService(
    supabaseClient,
    userService,
    revenueCatService,
  );
});

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return SubscriptionNotifier(subscriptionService);
});
