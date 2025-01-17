import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';

// Changed to a simple Provider instead of StateNotifierProvider
final apiManagerProvider = Provider.autoDispose<ApiManager>((ref) {
  final supabase = Supabase.instance.client;
  final manager = ApiManager._(supabase);
  // Initialize synchronously to ensure data is loaded
  manager._loadKeysSync();
  manager._loadRevEntitlementsSync();
  return manager;
});

class ApiManager {
  final SupabaseClient _supabaseClient;

  
  Map<String, String> _apiKeys = {};
  Map<String, String> _RevEntitlements = {};

  bool _isInitialized = false;

  ApiManager._(this._supabaseClient);

  Future<void> _loadKeysSync() async {
    try {
      print('Api_Manager Initialize started');
      final response = await _supabaseClient.from('api_resources')
          .select('name,api_key');
      
      _apiKeys = Map.fromEntries(
        response.map<MapEntry<String, String>>((row) => 
          MapEntry(row['name'] as String, row['api_key'] as String)
        )
      );
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing ApiManager: $e');
      throw ErrorHandler.handle(e, message: 'Failed to get keys');
    }
  }

  Future<void> _loadRevEntitlementsSync() async {
    final response = await _supabaseClient.from('revenuecat_entitlements')
        .select('name,Entitlements_ID');


    _RevEntitlements = Map.fromEntries(
      response.map<MapEntry<String, String>>((row) => 
        MapEntry(row['name'] as String, row['Entitlement_ID'] as String)
      )
    );
  }

  String _getRevEntitlementID(String entitlementName) {
    final entitlement = _RevEntitlements?[entitlementName];
    if (entitlement == null) {
      throw StateError('$entitlementName entitlement not found');
    }
    return entitlement;
  }

  String _getKey(String keyName) {
    if (!_isInitialized) {
      throw StateError('ApiManager must be initialized before accessing keys');
    }
    final key = _apiKeys?[keyName];
    if (key == null) {
      throw StateError('$keyName key not found');
    }
    return key;
  }

  String getRevenueCatApiKey() => _getKey('RevenueCat');
  String getEntitlementID() => _getKey('entitlementID');
  String getGoogleAPI() => _getKey('googleAPI');
  String getAppleAPI() => _getKey('appleAPI');
  String getAmazonAPI() => _getKey('amazonAPI');

  String getEntitlementName(String entitlementName) => _getRevEntitlementID(entitlementName);
}