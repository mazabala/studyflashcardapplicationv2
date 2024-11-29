// lib/core/services/subscription/subscription_service.dart

import 'package:flashcardstudyapplication/core/interfaces/i_subscription_service.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService implements ISubscriptionService {
  final SupabaseClient _supabaseClient;
  final UserService _userService;

  SubscriptionService(this._supabaseClient, this._userService);



  @override
  Future<void> updateSubscription(String userId, String subscriptionTier) async {
    final response = await _supabaseClient
        .from('subscriptions')
        .upsert({'user_id': userId, 'tier': subscriptionTier});

    if (response.error != null) {
      throw Exception("Failed to update subscription: ${response.error!.message}");
    }
  }

  @override
  Future<void> renewSubscription(String userId) async {
    final response = await _supabaseClient
        .from('subscriptions')
        .update({'renewal_date': DateTime.now().toIso8601String()})
        .eq('user_id', userId);

    if (response.error != null) {
      throw Exception("Failed to renew subscription: ${response.error!.message}");
    }
  }

  @override
  Future<void> cancelSubscription(String userId) async {
    final response = await _supabaseClient
        .from('subscriptions')
        .delete()
        .eq('user_id', userId);

    if (response.error != null) {
      throw Exception("Failed to cancel subscription: ${response.error!.message}");
    }
  }

  @override
  Future<bool> checkIfExpired() async {
    final expiryDate = await _userService.getSubscriptionExpiry();
    print (expiryDate);
    return expiryDate != null && await _userService.isUserExpired(expiryDate);
    
  }
}
