import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcardstudyapplication/core/error/error_handler.dart';

final apiManagerProvider = StateNotifierProvider<ApiManagerNotifier, AsyncValue<ApiManager>>((ref) {
  final supabase = Supabase.instance.client;
  return ApiManagerNotifier(supabase);
});

class ApiManagerNotifier extends StateNotifier<AsyncValue<ApiManager>> {
  final SupabaseClient _supabase;
  
  ApiManagerNotifier(this._supabase) : super(const AsyncValue.loading());
  
  Future<void> initialize() async {
    state = const AsyncValue.loading();
    try {
      final manager = await ApiManager.initialize(_supabase);
      state = AsyncValue.data(manager);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class ApiManager {
  final SupabaseClient _supabaseClient;
  static ApiManager? _instance;
  
  Map<String, String>? _apiKeys;
  bool _isInitialized = false;

  ApiManager._(this._supabaseClient);

  static Future<ApiManager> initialize(SupabaseClient supabaseClient) async {
    if (_instance == null) {
      _instance = ApiManager._(supabaseClient);
      await _instance!._loadKeys();
    }
    return _instance!;
  }

  Future<void> _loadKeys() async {
    try {
      print('Api_Manager Initialize started');
      final keys = await _supabaseClient.from('api_resources').select('name,api_key');
      
      _apiKeys = Map.fromEntries(
        keys.map<MapEntry<String, String>>((row) => 
          MapEntry(row['name'] as String, row['api_key'] as String)
        )
      );
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing ApiManager: $e');
      throw ErrorHandler.handle(e, message: 'Failed to get keys');
    }
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
}