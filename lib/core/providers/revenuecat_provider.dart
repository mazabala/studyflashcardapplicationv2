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

// Create an AsyncNotifier to handle the RevenueCat initialization
class RevenueCatNotifier extends AsyncNotifier<RevenueCatService> {
  @override
  Future<RevenueCatService> build() async {
    // Wait for ApiManager to be initialized
    final apiManagerAsync = ref.watch(apiManagerProvider);
    
    return apiManagerAsync.when(
      loading: () => throw StateError('ApiManager not initialized'),
      error: (err, stack) => throw err,
      data: (apiManager) {
        final revKey = apiManager.getRevenueCatApiKey();
        final entitlementId = apiManager.getEntitlementID();
        final googleAPI = apiManager.getGoogleAPI();
        final appleAPI = apiManager.getAppleAPI();
        final amazonAPI = apiManager.getAmazonAPI();

        print("revenueCatApiKey: $revKey");

        return RevenueCatService(
          revenueCatApiKey: revKey,
          entitlementId: entitlementId,
          googleAPI: googleAPI,
          appleAPI: appleAPI,
          amazonAPI: amazonAPI,
          userService: ref.read(userServiceProvider)
        );
      }
    );
  }
}

// Provider now returns AsyncValue<RevenueCatService>
final revenueCatClientProvider = AsyncNotifierProvider<RevenueCatNotifier, RevenueCatService>(
  () => RevenueCatNotifier()
);
