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


Future<void> initialize(String apiKey, String ?userId) async {
await Purchases.configure(
           PurchasesConfiguration(apiKey) ..appUserID = userId
          );


  _isInitialized = true;

}


Future<void> purchasePlan(String offeringName, String entitlementName) async {



  try { 
    Offerings offerings = await Purchases.getOfferings();
    Offering? customOffering = offerings.getOffering(offeringName);

    print ("offerings: $offerings");
    print(customOffering?.identifier);

    if (customOffering != null &&
        customOffering.availablePackages.isNotEmpty == true) {
      Package selectedPackage = customOffering.availablePackages![0];

      // Make the purchase
      CustomerInfo purchaserInfo =
      await Purchases.purchasePackage(selectedPackage);

      print("Here is the purchase info of the payment");
      print(purchaserInfo.entitlements);

      // Check if the entitlement is active
      if (purchaserInfo.entitlements.active.containsKey(entitlementName)) {
        print("✅ PURCHASE SUCCESSFUL");
        // Do something after a successful purchase
        

      }
    }

    
  } catch (e) {
    // Handle platform exceptions
    print("Platform Exception: $e");
    
  }
}


Future<bool> restorePurchases() async {
  try {
    CustomerInfo customerInfo = await Purchases.restorePurchases();
    if (customerInfo.entitlements.active.isNotEmpty) {
      // User has access to some entitlements
      return true;
    }
    return false;
  } on PlatformException catch (e) {
    print('Error restoring purchases: $e');
    return false;
  }
}

Future<String>checkSubscriptionStatus(String entitlement) async {

  try {
      Offerings offerings = await Purchases.getOfferings();
      Offering? customOffering = offerings.getOffering("default");

      if (customOffering != null && customOffering.availablePackages.isNotEmpty == true)  {
        // Display packages for sale
        // For simplicity, let's assume you want to purchase the first available package
        Package selectedPackage = customOffering.availablePackages[0];

             CustomerInfo customerInfo =
      await Purchases.purchasePackage(selectedPackage);


        if (customerInfo.entitlements.active.containsKey(entitlement)) {
          print("User has an active entitlement");
          return entitlement;
        }
        else {
                    return customerInfo.entitlements.active.keys.first;
        //User is subscribed to PRO plan
        }
      } 
      else {
        return "No offerings found";

      }


   

  
} on PlatformException catch (e) {
  print('Error checking subscription status: $e');
  return "Error";
}
}

Future<List<Offering>> getOfferings() async {
   

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
  
  try {
  final paywallResult = await RevenueCatUI.presentPaywall();
  print('Paywall result: $paywallResult');
} on Exception catch (e) {
  print('Error showing paywall: $e');
  // TODO
}
}

Future<void>showPaywallIfNeeded(String entitlement) async {
  final paywallResult = await RevenueCatUI.presentPaywallIfNeeded(entitlement);
  print('Paywall result: $paywallResult');
}


}


