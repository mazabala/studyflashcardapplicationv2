// app_initializer.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';

class RevenueCat_Client {
  final String rev_key;

  RevenueCat_Client({required this.rev_key});



  Future<void> initialize() async {
    

    try {
      // Get the RevenueCat API key from Supabase
      String revenueCatApiKey = rev_key;

      // Initialize RevenueCat
      await Purchases.setDebugLogsEnabled(true);
      await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));

      print("RevenueCat initialized successfully.");
    } catch (e) {
      print("Error during RevenueCat initialization: $e");
      throw Exception("Failed to initialize RevenueCat");
    }
  }


}
