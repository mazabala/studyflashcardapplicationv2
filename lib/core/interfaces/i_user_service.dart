// lib/core/services/interfaces/i_user_service.dart

abstract class IUserService {
  Future<String?> getCurrentUserEmail();
  Future<void> updateUserProfile(String name, String email);
  Future<void> upgradeSubscription(String planType);
  Future<void> downgradeSubscription(String planType);
  Future<String> getUserSubscriptionPlan();
  Future<DateTime?> getSubscriptionExpiry();
}
