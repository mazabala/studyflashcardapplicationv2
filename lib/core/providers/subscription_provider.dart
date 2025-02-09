// lib/core/providers/subscription_provider.dart

import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/providers/supabase_provider.dart';

import 'package:flashcardstudyapplication/core/providers/user_provider.dart';


import 'package:flashcardstudyapplication/core/services/subscription/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_subscription_service.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isExpired;
  final String errorMessage;
  final bool isInitialized;

  SubscriptionState({
    this.isLoading = false,
    this.isExpired = false,
    this.errorMessage = '',
    this.isInitialized = false,
  });


  SubscriptionState copyWith({
    bool? isLoading,
    bool? isExpired,
    String? errorMessage,
    List<String>? availablePackages,
    bool? isInitialized,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isExpired: isExpired ?? this.isExpired,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final ISubscriptionService _subscriptionService;

  SubscriptionNotifier(this._subscriptionService) : super(SubscriptionState());


  Future<void> initialize() async {
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

Future<void> purchaseSubscription(String userId, String subType) async {
  await _subscriptionService.purchaseSubscription(userId, subType);
}

Future<void> upgradeSubscription(String userId, String subType) async {
  await _subscriptionService.upgradeSubscription(userId, subType);
}

Future<void> cancelSubscription(String userId) async {  
  await _subscriptionService.cancelSubscription(userId);
}

Future<void> renewSubscription(String userId) async {
  await _subscriptionService.renewSubscription(userId);
}




}
