// lib/core/services/interfaces/i_user_service.dart

abstract class IUserService {
  Future<Map<String, dynamic>?> getCurrentUserInfo();
  Future<String?> getCurrentUserEmail();
  Future<void> updateUserProfile(String name, String email, String userId);
  Future<void> upgradeSubscription(String planType);
  Future<void> downgradeSubscription(String planType);

  
}
