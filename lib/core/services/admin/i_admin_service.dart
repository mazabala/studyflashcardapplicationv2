import 'package:flashcardstudyapplication/core/models/user_query_params.dart';

abstract class IAdminService {
  Future<bool> isSystemAdmin();
  Future<List<Map<String, dynamic>>> getFlaggedContent();
  Future<void> inviteUser(String email);
  Future<List<Map<String, dynamic>>> getUsers([UserQueryParams? params]);
  Future<void> reviewFlaggedContent(String contentId, bool approved);
  Future<void> updateUserRole(String userId, String role);
  Future<void> deleteUserAccount(String userId);
  Future<void> deleteUserData(String userId);
  Future<void> updateUserSubscription(String userId, String tier);
  Future<void> systemCreateDecks(List<Map<String, dynamic>> configs);
} 