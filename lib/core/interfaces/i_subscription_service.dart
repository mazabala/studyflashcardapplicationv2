import 'package:purchases_flutter/purchases_flutter.dart';

/// Interface defining subscription service capabilities.
/// Provides methods for managing user subscriptions, including updates,
/// renewals, cancellations, and status checks.
abstract class ISubscriptionService {
  /// Updates a user's subscription tier in both RevenueCat and local database.
  /// 
  /// [userId] The ID of the user whose subscription is being updated.
  /// [subscriptionTier] The new subscription tier to apply.
  /// 
  /// Throws an error if the subscription update fails or if no active subscription is found.
  Future<void> updateSubscription(String userId, String subscriptionTier);

  /// Renews an existing subscription for a user.
  /// 
  /// [userId] The ID of the user whose subscription is being renewed.
  /// 
  /// Throws an error if renewal fails or if no active subscription is found.
  Future<void> renewSubscription(String userId);

  /// Cancels a user's subscription.
  /// This will handle both RevenueCat cancellation and local database updates.
  /// 
  /// [userId] The ID of the user whose subscription is being cancelled.
  /// 
  /// Throws an error if cancellation fails.
  Future<void> cancelSubscription(String userId);

  /// Checks if the current user's subscription has expired.
  /// 
  /// Returns `true` if the subscription is expired or not found,
  /// `false` if the subscription is active.
  /// 
  /// Throws an error if the check fails.
  Future<bool> checkIfExpired();

  /// Attempts to restore a user's previous purchases.
  /// This will verify with RevenueCat and update the local database if successful.
  /// 
  /// [userId] The ID of the user whose subscription is being restored.
  /// 
  /// Throws an error if restoration fails.


  /// Gets the available subscription packages from RevenueCat.
  /// 
  /// Throws an error if unable to fetch packages.
  Future<List<String>> getAvailablePackages();

  /// Attempts to purchase a subscription package.
  /// 
  /// [userId] The ID of the user making the purchase.
  /// [package] The RevenueCat package to purchase.
  /// 
  /// Returns `true` if purchase was successful, `false` otherwise.
  /// Throws an error if the purchase process fails.
 

  /// Validates whether a subscription is currently active.
  /// This performs checks with both RevenueCat and the local database.
  /// 
  /// [userId] The ID of the user whose subscription is being validated.
  /// 
  /// Returns `true` if subscription is valid and active, `false` otherwise.
  Future<bool> validateSubscription(String userId);

  Future<String> getSubscriptionStatus(String userId);
}