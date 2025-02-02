// lib/core/providers/revenue_cat_provider.dart

import 'dart:developer';

import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart'; // Import ApiClient
import 'package:flashcardstudyapplication/core/services/api/api_manager.dart'; // Add this import

final revenueCatClientProvider = StateNotifierProvider<RevenueCatNotifier, RevenueCatService>((ref) {
  return RevenueCatNotifier(ref);
});

class RevenueCatNotifier extends StateNotifier<RevenueCatService> {
  final Ref ref;

  RevenueCatNotifier(this.ref) : super(RevenueCatService(revenueCatApiKey: ApiManager.instance.getRevenueCatApiKey()));


  Future<void> initialize(String apiKey) async {
    try {

      final user = ref.read(userProvider);
      final userId = user.userId;

      print('revenuecat initialized');
      await state.initialize(apiKey, userId);

    } catch (e) {
      print('RevenueCat initialization error: $e');
      rethrow;
    }

  }

Future<void> restorePurchases() async {
  await state?.restorePurchases();
}

Future<void> checkSubscriptionStatus(String entitlement) async {
  await state?.checkSubscriptionStatus(entitlement);
} 

Future<void> showPaywallProvider() async {
  print('showing wall from revn cat provider');
  await state?.showPaywall();
}


Future<void> showPaywallIfNeeded(String entitlement) async {
  await state?.showPaywallIfNeeded(entitlement);
}



Future<void> purchasePlan(String offeringName, String entitlementName) async {
  await state.purchasePlan(offeringName, entitlementName);
}









}