// lib/core/providers/revenue_cat_provider.dart

import 'package:flashcardstudyapplication/core/providers/user_provider.dart';
import 'package:flashcardstudyapplication/core/services/revenuecat/revenuecat_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcardstudyapplication/core/services/api/api_client.dart'; // Import ApiClient

// Provider to initialize and provide RevenueCat_Client
final revenueCatClientProvider = Provider<RevenueCatService>((ref) {
  // Get the ApiClient instance from Riverpod (assuming it has been provided elsewhere in the app)
  final apiClient = ref.watch(apiClientProvider); // Accessing the apiClient

  // Initialize the RevenueCat_Client using the API key fetched from ApiClient
  final revKey = apiClient.getRevenueCatApiKey();
  
  // Return an instance of RevenueCat_Client which is initialized once
  return RevenueCatService(revenueCatApiKey: revKey, userService: ref.read(userServiceProvider));
});
