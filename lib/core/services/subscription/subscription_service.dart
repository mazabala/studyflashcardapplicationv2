import 'dart:developer';

import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_subscription_service.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';
import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:flashcardstudyapplication/core/classes/subscriptions.dart';

class SubscriptionService implements ISubscriptionService {
  final SupabaseClient _supabaseClient;
  final UserState _userService;
  
  bool _isInitialized = false;
  List<Subscription> _subscriptions = [];
  List<Subscription> get subscriptions => _subscriptions;

  SubscriptionService(
    this._supabaseClient,
    this._userService,
  );

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        _isInitialized = true;
        return;
      }

      final userId = _userService.userId;
      if (userId == null) throw Exception('User not found');

      // Fetch all subscriptions during initialization
      final response = await _supabaseClient
        .from('subscriptiontype')
        .select('*')
        .eq('is_active', true);
      
    
      _subscriptions = response.map((item) => Subscription.fromJson(item)).toList();
      print('subscriptions - ${_subscriptions.length}');
      _isInitialized = true;
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to initialize subscription service',
          specificType: ErrorType.subscription);
    }
  }

  
  @override
  Future<void> purchaseSubscription(String userId, String subType) async {
    // Update subscription in database
    try {
      late String duration;

      if (subType != 'demo') {
        duration = 'monthly';
      } else {
        duration = 'weekly';
      }

      final subscription =
          _subscriptions.firstWhere((sub) => sub.subscriptionName == subType);
          


await _supabaseClient
  .from('user_subscriptions')
  .update({
    'subscriptionTypeID': subscription.subscriptionId,
    'end_date': _calculateEndDate(duration).toIso8601String() // Use toISOString() for standard format
  })
  .eq('user_id', userId);

 

    

    }  catch (e) {
      print('userid - $userId - ERROR IS: $e');
     throw ErrorHandler.handle(e);
      

    }
  }
  

  @override
  Future<void> upgradeSubscription(String userId, String subType) async {
        late String duration;

    if (subType != 'demo') {
      duration = 'monthly';
    } else {
      duration = 'weekly';
    }

    final subscription =
        _subscriptions.firstWhere((sub) => sub.subscriptionName == subType);
    
    // Update subscription in database
    final response = await _supabaseClient.from('user_subscriptions')
      .update({
      'subscriptionTypeID': subscription.subscriptionId,
      'end_date': _calculateEndDate(duration).toIso8601String(),
    })
    .eq('user_id', userId);

    if (response.error != null) {
      throw ErrorHandler.handleDatabaseError(response.error!,
          specificType: ErrorType.subscription);
    }
  }

  @override
  Future<void> renewSubscription(String userId) async {
    try {
      final currentTier = await _getCurrentSubscriptionTier(userId);
    late String duration;

    final subscription =
        _subscriptions.firstWhere((sub) => sub.subscriptionName == currentTier);

      if (subscription.subscriptionName != 'demo') {
        duration = 'monthly';
      } else {
        duration = 'weekly';
      }

      final response = await _supabaseClient.from('user_subscriptions').update({
        'end_date': _calculateEndDate(duration).toIso8601String(),
        'status': 'active',
        'renewed_at': DateTime.now().toIso8601String()
      }).eq('user_id', userId);

      if (response.error != null) {
        throw ErrorHandler.handleDatabaseError(response.error!,
            specificType: ErrorType.subscription);
      }
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to renew subscription',
          specificType: ErrorType.subscription);
    }
  }

  @override
  Future<void> cancelSubscription(String userId) async {
    try {
      // Update local database
      final response = await _supabaseClient.from('user_subscriptions')
      .update({'end_date': DateTime.now().toIso8601String(),'is_active': false})
      .eq('user_id', userId);

      if (response.error != null) {
        throw ErrorHandler.handleDatabaseError(response.error!,
            specificType: ErrorType.subscription);
      }
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to cancel subscription',
          specificType: ErrorType.subscription);
    }
  }

  @override
  Future<bool> checkIfExpired() async {
    try {


      return _userService.isExpired ?? true;
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to check subscription status',
          specificType: ErrorType.subscription);
    }
  }

  // Helper method to get current subscription tier
  Future<String> _getCurrentSubscriptionTier(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_subscriptions')
          .select('subscriptionTypeID')
          .eq('user_id', userId)
          .single();

      if (response == null) {
        throw Exception('No subscription found - $response');
      }

      return response['subscriptionTypeID'] as String;
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to get subscription tier',
          specificType: ErrorType.subscription);
    }
  }

  // Helper method to calculate subscription end date
  DateTime _calculateEndDate(String subscriptionTier) {
    final now = DateTime.now();
    switch (subscriptionTier.toLowerCase()) {
      case 'monthly':
        return now.add(const Duration(days: 30));
      case 'yearly':
        return now.add(const Duration(days: 365));
      case 'trial':
        return now.add(const Duration(days: 7));
      default:
        return now.add(const Duration(days: 30));
    }
  }



 


  @override
  Future<List<String>> getAvailablePackages() async {
    try {

        final response = await _supabaseClient
          .from('subscriptiontype')
          .select('*')
          .eq('is_active', true);
        
        return response.map((item) => item['name'] as String).toList();

      
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to get available packages',
          specificType: ErrorType.subscription);
    }
  }




  @override
  Future<String> getSubscriptionStatus(String userId) async {
    try {
      final userId = _userService.userId;
      if (userId == null) throw Exception('User not found');

      final response = await _supabaseClient
          .from('user_subscriptions')
          .select('end_date')
          .eq('user_id', userId)
          .single();


 
      if (DateTime.parse(response['end_date']).isBefore(DateTime.now())) {
        return 'Active';
      } else {
        return 'Expired';
      }
    } catch (e) {
      log('error getting subscription status: $e');
      throw ErrorHandler.handle(e,
          message: 'Failed to get subscription status',
          specificType: ErrorType.subscription);
    }
  }

  // Get all available subscriptions
  Future<List<Subscription>> getAllSubscriptions() async {
    return _subscriptions;
  }

  // Get a specific subscription by ID
  Future<Subscription?> getSubscriptionById(String subscriptionId) {
    try {
      return Future.value(_subscriptions.firstWhere(
        (sub) => sub.subscriptionId == subscriptionId,
      ));
    } catch (e) {
      return Future.value(null);
    }
  }

}