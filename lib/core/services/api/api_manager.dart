import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';

// Use a provider to expose the singleton instance
final apiManagerProvider = Provider<ApiManager>((ref) {
  return ApiManager.instance;
});

class ApiManager {
  final SupabaseClient _supabaseClient;
  
  Map<String, String> _apiKeys = {};
  Map<String, String> _RevEntitlements = {};

  bool _isInitialized = false;

  // Private constructor to prevent external instantiation
  ApiManager._(this._supabaseClient);

  // Static variable to hold the single instance
  static ApiManager? _instance;

  // Factory method to get the singleton instance
  static ApiManager get instance {
    if (_instance == null) {
      // This assumes `Supabase` is already initialized when this is accessed.
      final supabaseClient = Supabase.instance.client;
      _instance = ApiManager._(supabaseClient);
    }
    return _instance!;
  }


Future<void> initialize() async {
  try {
  final apiManager = ApiManager.instance;
  await apiManager._loadKeysSync();
  await apiManager._loadRevEntitlementsSync();
  
  print('Api_Manager Initialize finished');
  print('api keys: ${apiManager._apiKeys}');
  print('revenuecat entitlements: ${apiManager._RevEntitlements}');

} on Exception catch (e) {
  throw ErrorHandler.handle(e, message: 'Failed to initialize ApiManager');
}
}

  // Synchronous initialization methods (if needed)
  Future<void> _loadKeysSync() async {
    try {

      final response = await _supabaseClient.from('api_resources')
          .select('name,api_key');
      
      _apiKeys = Map.fromEntries(
        response.map<MapEntry<String, String>>((row) => 
          MapEntry(row['name'] as String, row['api_key'] as String)
        )
      );

      
      
      _isInitialized = true;
    } catch (e) {

      throw ErrorHandler.handle(e, message: 'Failed to get keys');
    }
  }

  Future<void> _loadRevEntitlementsSync() async {
    final response = await _supabaseClient.from('revenuecat_entitlements')
        .select('identifier');

 
    _RevEntitlements = Map.fromEntries(
      response.map<MapEntry<String, String>>((row) => 
        MapEntry(row['identifier'] as String, row['identifier'] as String)
      )
    );
  }

  // Utility methods to get keys and entitlement IDs
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

  String getRevenueCatApiKey() => _getKey('RevenueCat'); // TODO: THIS IS THE SANDBOX ONLY
  String getEntitlementID() => _getKey('entitlementID');
  String getGoogleAPI() => _getKey('googleAPI');
  String getAppleAPI() => _getKey('appleAPI');
  String getAmazonAPI() => _getKey('amazonAPI');

  String getEntitlementName(String entitlementName) => _getRevEntitlementID(entitlementName);
}
