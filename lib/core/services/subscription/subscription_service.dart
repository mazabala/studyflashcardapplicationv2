import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_subscription_service.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';
import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';

class SubscriptionService implements ISubscriptionService {
  final SupabaseClient _supabaseClient;
  final UserState _userService;

  bool _isInitialized = false;

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

      _isInitialized = true;
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to initialize subscription service',
          specificType: ErrorType.subscription);
    }
  }

  @override
  Future<void> updateSubscription(String userId, String subscriptionTier) async {
    // Update subscription in database
    final response = await _supabaseClient.from('user_subscriptions')
      .update({
      'subscriptionID': subscriptionTier,
      'end_date': _calculateEndDate(subscriptionTier).toIso8601String(),
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

      final response = await _supabaseClient.from('user_subscriptions').update({
        'end_date': _calculateEndDate(currentTier).toIso8601String(),
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
      final response = await _supabaseClient.from('user_subscriptions').update(
          {'end_date': DateTime.now().toIso8601String()}).eq('user_id', userId);

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



  // Helper method to validate subscription
  Future<bool> _validateSubscription(String userId) async {
    try {
      // final hasActiveSubscription = await _revenueCatService.hasActiveSubscription();
      // if (!hasActiveSubscription) return false;

      final response = await _supabaseClient
          .from('user_subscriptions')
          .select('end_date')
          .eq('user_id', userId)
          .single();

      if (response['end_date'] < DateTime.now()) {
        return false;
      }

      return response['status'] == 'active';
    } catch (e) {
      print('Error validating subscription: $e');
      return false;
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

// @override
//   Future<bool> purchasePackage(String userId, Package package) async {
//     try {
//       if (kIsWeb) {
//         return await _handleWebPurchase(userId, package);
//       }

//       // Verify user exists
//       final userExists = await _userService.getCurrentUserId() == userId;
//       if (!userExists) {
//         throw ErrorHandler.handle(
//           Exception('Invalid user'),
//           message: 'User not found',
//           specificType: ErrorType.subscription
//         );
//       }

//       // Attempt purchase through RevenueCat
//       //final success = await _revenueCatService.purchasePackage(package);

//       if (success) {
//         // Update local database with new subscription
//         await _updateSubscriptionInDatabase(
//           userId: userId,
//           subscriptionTier: package.identifier,

//         );

//         // Verify purchase was successful
//         final isValid = await validateSubscription(userId);
//         if (!isValid) {
//           throw ErrorHandler.handle(
//             Exception('Purchase validation failed'),
//             message: 'Could not validate purchase',
//             specificType: ErrorType.subscription
//           );
//         }
//       }

//       return success;
//     } catch (e) {
//       // Handle specific RevenueCat errors
//       if (e is PurchasesErrorCode) {
//         switch (e) {
//           case PurchasesErrorCode.purchaseCancelledError:
//             return false;
//           case PurchasesErrorCode.paymentPendingError:
//             throw ErrorHandler.handle(
//               e,
//               message: 'Payment is pending',
//               specificType: ErrorType.subscription
//             );
//           default:
//             throw ErrorHandler.handle(
//               e,
//               message: 'Purchase failed',
//               specificType: ErrorType.subscription
//             );
//         }
//       }

//       throw ErrorHandler.handle(
//         e,
//         message: 'Failed to purchase package',
//         specificType: ErrorType.subscription
//       );
//     }
//   }

  // Future<bool> validateSubscription(String userId) async {
  //   try {
  //     // First check RevenueCat status
  //    // final hasActiveSubscription = await _revenueCatService.hasActiveSubscription();
  //    // if (!hasActiveSubscription) return false;

  //     // Then verify with local database
  //     final response = await _supabaseClient
  //         .from('user_subscriptions')
  //         .select('status, end_date')
  //         .eq('user_id', userId)
  //         .single();

  //     if (response == null ) {
  //       return false;
  //     }

  //     final status = response['status'] as String;
  //     final endDate = DateTime.parse(response['end_date'] as String);

  //     // Check if subscription is active and not expired
  //     final isValid = status == 'active' &&
  //                    endDate.isAfter(DateTime.now());

  //     // If there's a mismatch between RevenueCat and local database,
  //     // attempt to sync the data
  //    // if (hasActiveSubscription != isValid) {
  //    //   await _syncSubscriptionStatus(userId);
  //    // }

  //     return isValid;
  //   } catch (e) {
  //     print('Error validating subscription: $e');
  //     // In case of error, fall back to RevenueCat status
  //    return //await _revenueCatService.hasActiveSubscription();
  //   }
  // }



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

      if (response['end_date'] < DateTime.now()) {
        return 'Active';
      } else {
        return 'Expired';
      }
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to get subscription status',
          specificType: ErrorType.subscription);
    }
  }

  

  @override
  Future<bool> validateSubscription(String userId) async {
    try {
      final userId = _userService.userId;
      if (userId == null) throw Exception('User not found');

      if (kIsWeb) {
        final response = await getSubscriptionStatus(userId);

        if (response == null) return false;

        return response == 'Active';
      }


      return true;
    } catch (e) {
      throw ErrorHandler.handle(e,
          message: 'Failed to validate subscription',
          specificType: ErrorType.subscription);
    }
  }
}
