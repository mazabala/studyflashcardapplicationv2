import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_subscription_service.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';
import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';

class SubscriptionService implements ISubscriptionService {
  final SupabaseClient _supabaseClient;
  final UserService _userService;
  final RevenueCatService _revenueCatService;
  
  bool _isInitialized = false;
  

  SubscriptionService(
    this._supabaseClient, 
    this._userService,
    this._revenueCatService,
    
  );


 Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        _isInitialized = true;
        return;
      }

      final userId = _userService.getCurrentUserId();
      if (userId == null) throw Exception('User not found');

      final configuration = PurchasesConfiguration(_revenueCatService.revenueCatApiKey);
      configuration.appUserID = userId;
      await Purchases.configure(configuration);
      _isInitialized = true;
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to initialize subscription service',
        specificType: ErrorType.subscription
      );
    }
  }

  Future<bool> _checkRevenueCatSubscription() async {
    if (kIsWeb) return true; // Web platform handling

    try {
      final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      print("Error checking subscription status: $e");
      return false;
    }
  }
  @override
  Future<void> updateSubscription(String userId, String subscriptionTier) async {
    if (!_isInitialized) await initialize();

    try {
      final hasActiveSubscription = await _checkRevenueCatSubscription();
      if (!hasActiveSubscription) {
        throw ErrorHandler.handle(
          Exception('No active subscription found'),
          message: 'Subscription not found',
          specificType: ErrorType.subscription
        );
      }

      await _updateSubscriptionInDatabase(
        userId: userId,
        subscriptionTier: subscriptionTier,
      );
    } catch (e) {
      throw ErrorHandler.handle(e,
        message: 'Failed to update subscription',
        specificType: ErrorType.subscription
      );
    }
  }
  Future<void> _updateSubscriptionInDatabase({required String userId, required String subscriptionTier}) async {
      // Update subscription in database
    final response = await _supabaseClient
        .from('user_subscriptions')
        .upsert({
          'user_id': userId,
          'subscriptionTypeID': subscriptionTier,
          'status': 'active',
          'start_date': DateTime.now().toIso8601String(),
          'end_date': _calculateEndDate(subscriptionTier).toIso8601String(),
        });
    
    if (response.error != null) {
      throw ErrorHandler.handleDatabaseError(
        response.error!,
        specificType: ErrorType.subscription
      );
    }
  }

  @override
  Future<void> renewSubscription(String userId) async {
    try {
      // First verify with RevenueCat
      final hasActiveSubscription = await _revenueCatService.hasActiveSubscription();
      
      if (!hasActiveSubscription) {
        throw ErrorHandler.handle(
          Exception('No active subscription to renew'), 
          message: 'No active subscription',
          specificType: ErrorType.subscription
        );
      }

      final currentTier = await _getCurrentSubscriptionTier(userId);
      
      final response = await _supabaseClient
          .from('user_subscriptions')
          .update({
            'end_date': _calculateEndDate(currentTier).toIso8601String(),
            'status': 'active',
            'renewed_at': DateTime.now().toIso8601String()
          })
          .eq('user_id', userId);

      if (response.error != null) {
        throw ErrorHandler.handleDatabaseError(
          response.error!,
          specificType: ErrorType.subscription
        );
      }
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to renew subscription',
        specificType: ErrorType.subscription
      );
    }
  }

  @override
  Future<void> cancelSubscription(String userId) async {
    try {
      // Handle cancellation through RevenueCat
      await _revenueCatService.cancelSubscription();

      // Update local database
      final response = await _supabaseClient
          .from('user_subscriptions')
          .update({
            'status': 'cancelled',
            'cancelled_at': DateTime.now().toIso8601String()
          })
          .eq('user_id', userId);

      if (response.error != null) {
        throw ErrorHandler.handleDatabaseError(
          response.error!,
          specificType: ErrorType.subscription
        );
      }
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to cancel subscription',
        specificType: ErrorType.subscription
      );
    }
  }

  @override
  Future<bool> checkIfExpired() async {
    try {
      // First check with RevenueCat
      final hasActiveSubscription = await _revenueCatService.hasActiveSubscription();
      if (!hasActiveSubscription) return true;

      // Then verify with local database
      final expiryDate = await _userService.getSubscriptionExpiry();
      if (expiryDate == null) return true;
      
      return await _userService.isUserExpired(expiryDate);
    } catch (e) {
      throw ErrorHandler.handle(e, 
        message: 'Failed to check subscription status',
        specificType: ErrorType.subscription
      );
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
        specificType: ErrorType.subscription
      );
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

  // Helper method to handle subscription restoration
  Future<void> restoreSubscription(String userId) async {
    try {
      await _revenueCatService.restorePurchases();
      
      // Check if restoration was successful
      final hasActiveSubscription = await _revenueCatService.hasActiveSubscription();
      if (hasActiveSubscription) {
        // Update local database with restored subscription
        await renewSubscription(userId);
      }
    } catch (e) {
      throw ErrorHandler.handle(e,
        message: 'Failed to restore subscription',
        specificType: ErrorType.subscription
      );
    }
  }

  // Helper method to validate subscription
  Future<bool> _validateSubscription(String userId) async {
    try {
      final hasActiveSubscription = await _revenueCatService.hasActiveSubscription();
      if (!hasActiveSubscription) return false;

      final response = await _supabaseClient
          .from('user_subscriptions')
          .select('status')
          .eq('user_id', userId)
          .single();

      return response['status'] == 'active';
    } catch (e) {
      print('Error validating subscription: $e');
      return false;
    }
  }
  
  @override
  Future<List<Package>> getAvailablePackages() async {
    try {
      if (kIsWeb) {
        // Return web-specific packages
        return await _getWebPackages();
      }

      // Get offerings through RevenueCat service
      final offerings = await _revenueCatService.getOfferings();
      
      if (offerings.isEmpty) {
        throw ErrorHandler.handle(
          Exception('No offerings available'),
          message: 'No subscription packages found',
          specificType: ErrorType.subscription
        );
      }
      
      // Get all available packages from all offerings
      final List<Package> allPackages = [];
      for (final offering in offerings) {
        allPackages.addAll(offering.availablePackages);
      }

      // Filter out any invalid packages and sort by price
      final validPackages = allPackages.where((package) => 
        package.storeProduct.price > 0 && 
        package.storeProduct.identifier.isNotEmpty
      ).toList()
        ..sort((a, b) => a.storeProduct.price.compareTo(b.storeProduct.price));

      return validPackages;
    } catch (e) {
      throw ErrorHandler.handle(
        e,
        message: 'Failed to get available packages',
        specificType: ErrorType.subscription
      );
    }
  }

  
@override
  Future<bool> purchasePackage(String userId, Package package) async {
    try {
      if (kIsWeb) {
        return await _handleWebPurchase(userId, package);
      }

      // Verify user exists
      final userExists = await _userService.getCurrentUserId() == userId;
      if (!userExists) {
        throw ErrorHandler.handle(
          Exception('Invalid user'),
          message: 'User not found',
          specificType: ErrorType.subscription
        );
      }

      // Attempt purchase through RevenueCat
      final success = await _revenueCatService.purchasePackage(package);
      
      if (success) {
        // Update local database with new subscription
        await _updateSubscriptionInDatabase(
          userId: userId,
          subscriptionTier: package.identifier,

        );

        // Verify purchase was successful
        final isValid = await validateSubscription(userId);
        if (!isValid) {
          throw ErrorHandler.handle(
            Exception('Purchase validation failed'),
            message: 'Could not validate purchase',
            specificType: ErrorType.subscription
          );
        }
      }

      return success;
    } catch (e) {
      // Handle specific RevenueCat errors
      if (e is PurchasesErrorCode) {
        switch (e) {
          case PurchasesErrorCode.purchaseCancelledError:
            return false;
          case PurchasesErrorCode.paymentPendingError:
            throw ErrorHandler.handle(
              e,
              message: 'Payment is pending',
              specificType: ErrorType.subscription
            );
          default:
            throw ErrorHandler.handle(
              e,
              message: 'Purchase failed',
              specificType: ErrorType.subscription
            );
        }
      }
      
      throw ErrorHandler.handle(
        e,
        message: 'Failed to purchase package',
        specificType: ErrorType.subscription
      );
    }
  }

  @override
  Future<bool> validateSubscription(String userId) async {
    try {
      // First check RevenueCat status
      final hasActiveSubscription = await _revenueCatService.hasActiveSubscription();
      if (!hasActiveSubscription) return false;

      // Then verify with local database
      final response = await _supabaseClient
          .from('user_subscriptions')
          .select('status, end_date')
          .eq('user_id', userId)
          .single();

      if (response == null ) {
        return false;
      }

      final status = response['status'] as String;
      final endDate = DateTime.parse(response['end_date'] as String);

      // Check if subscription is active and not expired
      final isValid = status == 'active' && 
                     endDate.isAfter(DateTime.now());

      // If there's a mismatch between RevenueCat and local database,
      // attempt to sync the data
      if (hasActiveSubscription != isValid) {
        await _syncSubscriptionStatus(userId);
      }

      return isValid;
    } catch (e) {
      print('Error validating subscription: $e');
      // In case of error, fall back to RevenueCat status
      return await _revenueCatService.hasActiveSubscription();
    }
  }
  Future<List<Package>> _getWebPackages() async {
  try {
    // Fetch packages/products from Stripe
    final response = await _supabaseClient
        .from('subscription_packages')
        .select()
        .eq('is_active', true);

    if (response == null) {
      throw ErrorHandler.handle(
        Exception('No packages found'),
        message: 'No subscription packages available',
        specificType: ErrorType.subscription
      );
    }

    // Convert database records to Package objects
    return [] as List<Package>; //TODO: Implement this
  } catch (e) {
    throw ErrorHandler.handle(
      e,
      message: 'Failed to fetch web packages',
      specificType: ErrorType.subscription
    );
  }
}

Future<bool> _handleWebPurchase(String userId, Package package) async {
  try {
    // Create Stripe checkout session //TODO: Change to USE STRIPE
    final response = await _supabaseClient.functions.invoke(
      'create-checkout-session',
      body: {
        'userId': userId,
        'priceId': package.identifier,
        'successUrl': 'YOUR_SUCCESS_URL',
        'cancelUrl': 'YOUR_CANCEL_URL',
      },
    );

    if (response == null) {
      throw Exception(response);
    }

    final sessionUrl = response.data['url'];
    // Return true to indicate successful creation of checkout session
    // Actual purchase completion will be handled by webhook
    return true;
  } catch (e) {
    throw ErrorHandler.handle(
      e,
      message: 'Failed to initiate web purchase',
      specificType: ErrorType.subscription
    );
  }
}


Future<void> _syncSubscriptionStatus(String userId) async {
  try {
    // Get current subscription status from Stripe
    final response = await _supabaseClient.functions.invoke(
      'get-subscription-status',
      body: {'userId': userId},
    );

    if (response== null) {
      throw Exception(response);
    }

    final stripeStatus = response.data['status'];
    final stripeValidUntil = DateTime.parse(response.data['current_period_end']);

    // Update local database with Stripe subscription status
    await _supabaseClient
        .from('user_subscriptions')
        .update({
          'status': _mapStripeStatus(stripeStatus),
          'end_date': stripeValidUntil.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);

  } catch (e) {
    // Log error but don't throw to prevent disrupting validation flow
    print('Error syncing subscription status: $e');
  }
}
  // Helper method to map Stripe subscription status to our status
String _mapStripeStatus(String stripeStatus) {
  switch (stripeStatus) {
    case 'active':
    case 'trialing':
      return 'active';
    case 'canceled':
    case 'incomplete_expired':
      return 'cancelled';
    case 'incomplete':
    case 'past_due':
      return 'pending';
    default:
      return 'expired';
  }
}

  // 
}