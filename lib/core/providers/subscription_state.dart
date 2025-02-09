import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interfaces/i_subscription_service.dart';

class SubscriptionState {
  final bool isSubscribed;
  final String? subscriptionTier;
  final bool isLoading;
  final String? errorMessage;

  const SubscriptionState({
    this.isSubscribed = false,
    this.subscriptionTier,
    this.isLoading = false,
    this.errorMessage,
  });

  SubscriptionState copyWith({
    bool? isSubscribed,
    String? subscriptionTier,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SubscriptionState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final ISubscriptionService _subscriptionService;

  SubscriptionNotifier(this._subscriptionService) : super(const SubscriptionState());

  Future<void> purchaseSubscription(String userId, String subType) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _subscriptionService.purchaseSubscription(userId, subType);
      await _refreshSubscriptionStatus(userId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> cancelSubscription(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _subscriptionService.cancelSubscription(userId);
      await _refreshSubscriptionStatus(userId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> _refreshSubscriptionStatus(String userId) async {
    try {
      final status = await _subscriptionService.getSubscriptionStatus(userId);
      state = state.copyWith(
        isSubscribed: status != 'none',
        subscriptionTier: status,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }
} 