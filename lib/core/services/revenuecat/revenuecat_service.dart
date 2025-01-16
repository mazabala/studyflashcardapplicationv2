import 'dart:io';

import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'dart:async';
import 'dart:developer';

class RevenueCatService {
  final String revenueCatApiKey;
  final String entitlementId;
  final UserService _userService;
  final String googleAPI;
  final String amazonAPI;
  final String appleAPI;
  bool _isInitialized = false;

  RevenueCatService({
    required this.revenueCatApiKey,
    required this.entitlementId,
    required UserService userService,
    required this.googleAPI,
    required this.amazonAPI,
    required this.appleAPI
    }):_userService = userService;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Purchases.setDebugLogsEnabled(true);
      if (kIsWeb) {
        // Web uses billing portal, so just mark as initialized
        _isInitialized = true;
      } else {
        print('googleapi: $googleAPI');
        final userId = await _getOrCreateUserId();
        

        PurchasesConfiguration configuration = PurchasesConfiguration('');
        if (Platform.isAndroid) {
          configuration = PurchasesConfiguration(googleAPI);
          
         // if (buildingForAmazon) {
         //   // use your preferred way to determine if this build is for Amazon store
         //   // checkout our MagicWeather sample for a suggestion
         //   configuration = AmazonConfiguration(<revenuecat_project_amazon_api_key>);
         // }

        } else if (Platform.isIOS) {
          configuration = PurchasesConfiguration(appleAPI);
        }
        configuration.appUserID = userId;
        await Purchases.configure(configuration);
        _isInitialized = true;
      }
    } catch (e) {
      print("Error during RevenueCat initialization: $e");
      rethrow;
    }
  }

Future<void> initPlatformState() async {
  await Purchases.setDebugLogsEnabled(true);

  PurchasesConfiguration configuration = PurchasesConfiguration('');
  if (Platform.isAndroid) {

    configuration = PurchasesConfiguration(googleAPI);
   // if (buildingForAmazon) {
   //   // use your preferred way to determine if this build is for Amazon store
   //   // checkout our MagicWeather sample for a suggestion
   //   configuration = AmazonConfiguration(<revenuecat_project_amazon_api_key>);
   // }
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration(appleAPI);
  }
  
  await Purchases.configure(configuration);
}




//  Future<void> cancelSubscription() async {
//     if (!_isInitialized) await initialize();

//     try {
//       if (kIsWeb) {
//         // Handle web cancellation through billing portal
//         return;
//       }

//       final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      
//       if (customerInfo.entitlements.active.isEmpty) {
//         throw Exception('No active subscription found');
//       }

//       if (defaultTargetPlatform == TargetPlatform.iOS) {
//         // For iOS, use Settings URL
//         const url = 'app-settings:';
//         if (await canLaunchUrl(Uri.parse(url))) {
//           await launchUrl(Uri.parse(url));
//         } else {
//           throw Exception('Could not open subscription settings');
//         }
//       } else if (defaultTargetPlatform == TargetPlatform.android) {
//         // For Android, use Google Play subscription center
//         const url = 'https://play.google.com/store/account/subscriptions';
//         if (await canLaunchUrl(Uri.parse(url))) {
//           await launchUrl(
//             Uri.parse(url),
//             mode: LaunchMode.externalApplication,
//           );
//         } else {
//           throw Exception('Could not open subscription settings');
//         }
//       }
//     } catch (e) {
//       print("Error during subscription cancellation: $e");
//       rethrow;
//     }
//   }


//   // Helper method to check subscription status
//   Future<bool> hasActiveSubscription() async {
//     if (!_isInitialized) await initialize();

//     try {
//       final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
//       return customerInfo.entitlements.active[entitlementId]?.isActive ?? false;
//     } catch (e) {
//       print("Error checking subscription status: $e");
//       return false;
//     }
//   }

  Future<String?> _getOrCreateUserId() async {
 
    return _userService.getCurrentUserId();

    
 
 
 }

  Future<List<Offering>> getOfferings() async {
    if (!_isInitialized) await initialize();

    try {
      if (kIsWeb) {
        // Return mock offerings for web
        return _getMockOfferings();
      }
      
      final offerings = await Purchases.getOfferings();
      return offerings.all.values.toList();
    } catch (e) {
      print("Error fetching offerings: $e");
      rethrow;
    }
  }

  List<Offering> _getMockOfferings() {
    // Create mock offerings for web platform
    // This should match your actual RevenueCat configuration
    return [];
  }

  // Future<bool> purchasePackage(Package package) async {
  //   if (!_isInitialized) await initialize();

  //   try {
  //     if (kIsWeb) {
  //       await _handleWebPurchase();
  //       return true;
  //     }

  //     final purchaseResult = await Purchases.purchasePackage(package);
  //     return purchaseResult.entitlements.active[entitlementId]?.isActive ?? false;
  //   } catch (e) {
  //     print("Error during purchase: $e");
  //     rethrow;
  //   }
  // }

  // Future<void> _handleWebPurchase() async {
  //   // Implement web-specific purchase flow
  //   // This should redirect to your billing portal
  //   final url = 'https://api.revenuecat.com/v1/public/checkout?customerid=YOUR_CUSTOMER_ID';
  //   // Implement URL launch logic
  // }

  // Future<bool> checkSubscriptionStatus() async {
  //   if (!_isInitialized) await initialize();

  //   try {
  //     if (kIsWeb) {
  //       // Implement web-specific status check
  //       return false;
  //     }

  //     final customerInfo = await Purchases.getCustomerInfo();
  //     return customerInfo.entitlements.all['premium']?.isActive ?? false;
  //   } catch (e) {
  //     print("Error checking subscription status: $e");
  //     rethrow;
  //   }
  // }

  // Future<void> restorePurchases() async {
  //   if (!_isInitialized) await initialize();

  //   try {
  //     if (kIsWeb) return; // Not applicable for web

  //     await Purchases.restorePurchases();
  //   } catch (e) {
  //     print("Error restoring purchases: $e");
  //     rethrow;
  //   }
  // }
}