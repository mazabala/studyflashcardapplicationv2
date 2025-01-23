// lib/core/providers/revenue_cat_provider.dart

import 'dart:developer';

import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart'; // Import ApiClient
import 'package:flashcardstudyapplication/core/services/api/api_manager.dart'; // Add this import

final revenueCatClientProvider = StateNotifierProvider<RevenueCatNotifier, RevenueCatService?>((ref) {
  return RevenueCatNotifier(ref);
});

class RevenueCatNotifier extends StateNotifier<RevenueCatService?> {
  final Ref ref;

  RevenueCatNotifier(this.ref) : super(null);

  Future<void> initialize() async {
    try {
      final apiManager = ApiManager.instance;
      final revKey = apiManager.getRevenueCatApiKey();
      
      state = RevenueCatService(
        revenueCatApiKey: revKey,
      );

      await state?.initialize();
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

Future<void> showPaywall() async {
  print('showing wall from revn cat provider');
  await state?.showPaywall();
}

Future<void> showPaywallIfNeeded(String entitlement) async {
  await state?.showPaywallIfNeeded(entitlement);
}

Future<void> getCustomerInfo() async {
  await state?.getCustomerInfo();
}

Future<List<Offering>> getOfferings() async {
  return await state?.getOfferings() ?? [];
}







}