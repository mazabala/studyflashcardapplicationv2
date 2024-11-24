// lib/core/services/subscription/i_subscription_service.dart

abstract class ISubscriptionService {
  Future<Map<String, dynamic>> getSubscriptionStatus(String userId);
  Future<void> updateSubscription(String userId, String subscriptionTier);
  Future<void> renewSubscription(String userId);
  Future<void> cancelSubscription(String userId);
}
