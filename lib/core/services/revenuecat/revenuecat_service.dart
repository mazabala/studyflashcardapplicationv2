import 'dart:io';

import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'dart:async';
import 'dart:developer';

class RevenueCatService {
  late final String revenueCatApiKey;
  late final String ?userId;

  bool _isInitialized = false;

  RevenueCatService({
    required this.revenueCatApiKey,

    this.userId,

  });


Future<void> initialize() async {
  await Purchases.configure(
    PurchasesConfiguration(revenueCatApiKey) ..appUserID = userId
  );

  _isInitialized = true;

}

Future<void> restorePurchases() async {

  try {
  CustomerInfo customerInfo = await Purchases.restorePurchases();
} on PlatformException catch (e) {
  print('Error restoring purchases: $e');
}
  
}

Future<void>checkSubscriptionStatus(String entitlement) async {

  try {
  CustomerInfo customerInfo = await Purchases.getCustomerInfo();
  
  
  if (customerInfo.activeSubscriptions.isNotEmpty) {
    print('User has an active subscription'); // Basic
  } else if (customerInfo.entitlements.all[entitlement]?.isActive == true) {
    print('User has an active entitlement'); //Advanced
  } else if(customerInfo.entitlements.all[entitlement]?.isActive == false) {
    print('User does not have an active subscription'); //Demo
  }
} on PlatformException catch (e) {
  print('Error checking subscription status: $e');
}
}

Future<List<Offering>> getOfferings() async {
    if (!_isInitialized) await initialize();

    try {
      
     
      final offerings = await Purchases.getOfferings();
      return offerings.all.values.toList();
    } catch (e) {
      print("Error fetching offerings: $e");
      rethrow;
    }
  }

Future<void>getCustomerInfo() async {
  CustomerInfo customerInfo = await Purchases.getCustomerInfo();
  
}

Future<void>showPaywall() async {
  
  final paywallResult = await RevenueCatUI.presentPaywall();
  print('Paywall result: $paywallResult');
}

Future<void>showPaywallIfNeeded(String entitlement) async {
  final paywallResult = await RevenueCatUI.presentPaywallIfNeeded(entitlement);
  print('Paywall result: $paywallResult');
}


}