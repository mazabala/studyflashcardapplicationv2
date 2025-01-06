// lib/core/providers/revenue_cat_provider.dart

import 'dart:developer';

import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart'; // Import ApiClient
import 'package:flashcardstudyapplication/core/services/api/api_manager.dart'; // Add this import


void presentPaywall() async {
  final paywallResult = await RevenueCatUI.presentPaywall();
  log('Paywall result: $paywallResult');
}

void presentPaywallIfNeeded() async {
  final paywallResult = await RevenueCatUI.presentPaywallIfNeeded("basic");
  log('Paywall result: $paywallResult');
}

// Provider to initialize and provide RevenueCat_Client
final revenueCatClientProvider = Provider<RevenueCatService>((ref) {
  // Get the ApiClient instance from Riverpod (assuming it has been provided elsewhere in the app)
  final apiManager = ref.watch(apiManagerProvider); // Accessing the apiManager

  // Initialize the RevenueCat_Client using the API key fetched from ApiManager
  final revKey = apiManager.getRevenueCatApiKey();
  final entitlementId = apiManager.getEntitlementID(); 
  final googleAPI = apiManager.getGoogleAPI();
  final appleAPI = apiManager.getAppleAPI();
  final amazonAPI = apiManager.getAmazonAPI();

  print("revenueCatApiKey: $revKey");
  
  // Return an instance of RevenueCat_Client which is initialized once
  return RevenueCatService(
    revenueCatApiKey: revKey,
    entitlementId: entitlementId,
    googleAPI: googleAPI,
    appleAPI: appleAPI,
    amazonAPI: amazonAPI,
    userService: ref.read(userServiceProvider)
  );
});
