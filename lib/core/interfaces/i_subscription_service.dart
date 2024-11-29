// lib/core/interfaces/i_subscription_service.dart

abstract class ISubscriptionService {
  

  Future<void> updateSubscription(String userId, String subscriptionTier);

  Future<void> renewSubscription(String userId);

  Future<void> cancelSubscription(String userId);

  Future<bool> checkIfExpired();
}
