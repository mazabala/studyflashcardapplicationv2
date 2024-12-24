import 'package:flashcardstudyapplication/core/services/deck/deck_service.dart';

abstract class IAdminService {
  /// Checks if the current user has admin privileges
  Future<bool> isSystemAdmin();

  /// Creates system-wide decks with specified configurations
  Future<void> systemCreateDecks(List<SystemDeckConfig> configs);

  /// Manages deck categories in the system
  Future<void> addDeckCategory(String category);
  Future<List<String>> getDeckCategories();

  /// Manages subscription-related operations
  Future<void> updateUserSubscription(String userId, String tier);
  Future<void> cancelUserSubscription(String userId);

  /// Manages flagged content
  Future<List<String>> getFlaggedContent();
  Future<void> reviewFlaggedContent(String contentId, bool approved);

  /// User management operations
  Future<void> updateUserRole(String userId, String role);
  Future<List<String>> getUsersByRole(String role);

  /// User deletion and data management
  Future<void> deleteUserAccount(String userId);
  Future<void> deleteUserData(String userId);


  /// User invitation management
  Future<void> inviteUser(String email);
  
  
}
