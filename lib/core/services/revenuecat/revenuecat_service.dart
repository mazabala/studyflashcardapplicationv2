import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCat_Client {
  final String rev_key;
  bool _isInitialized = false;

  RevenueCat_Client({required this.rev_key});

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        // Web doesn't need initialization - it uses billing portal
        print("RevenueCat Web mode - No initialization needed");
        _isInitialized = true;
      } else {
        // Mobile initialization remains the same
        print("Initializing RevenueCat for Mobile...");
        await Purchases.configure(PurchasesConfiguration(rev_key));
        _isInitialized = true;
      }
    } catch (e) {
      print("Error during RevenueCat initialization: $e");
      rethrow;
    }
  }

  // Method to open billing portal
  Future<void> openBillingPortal({
    required String customerId,
    String? planId,
  }) async {
    if (kIsWeb) {
      final url = 'https://api.revenuecat.com/v1/public/checkout?customerid=$customerId';
      // Use window.open to redirect to billing portal
      js.context.callMethod('open', [url, '_blank']);
    } else {
      throw UnsupportedError('Billing portal is only available on web platform');
    }
  }

  // Method to check entitlements
  Future<bool> hasAccess() async {
    if (kIsWeb) {
      // Implement your web-specific entitlement checking logic here
      // This might involve checking your backend for the user's subscription status
      return false; // Replace with actual implementation
    } else {
      final customerInfo = await Purchases.getCustomerInfo();
      // Replace 'your_entitlement_id' with your actual entitlement ID
      return customerInfo.entitlements.all.containsKey('your_entitlement_id');
    }
  }

  bool isInitialized() => _isInitialized;
}