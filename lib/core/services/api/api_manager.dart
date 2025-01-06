import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcardstudyapplication/core/error/error_handler.dart';

final apiManagerProvider = Provider<ApiManager>((ref) {
  final supabase = Supabase.instance.client;
  return ApiManager(supabase);
});

class ApiManager {
  final SupabaseClient _supabaseClient;
  late final String _getRevenueCatApiKey;
  late final String _getEntitlementID;
  late final String _getGoogleAPI;
  late final String _getAppleAPI;
  late final String _getAmazonAPI;
  late final String _sanbox_Revenecat;

  bool _isInitialized = false;

  ApiManager(this._supabaseClient); //TODO: THIS IS NOT WORKING BECAUSE WE NEED CREDS TO HIT TE DB. needs a workaround



  Future<void> initialize() async {
    try {
      final keys = await _supabaseClient.from('api_resources').select('name,api_key');
      print('Fetched keys: $keys'); // Debug print
      
      _getRevenueCatApiKey = keys.firstWhere(
        (row) => row['name'] == 'RevenueCat',
        orElse: () => throw StateError('RevenueCat key not found'),
      )['api_key'];

      _getEntitlementID = keys.firstWhere(
        (row) => row['name'] == 'entitlementID',
        orElse: () => throw StateError('entitlementID key not found'),
      )['api_key'];

      _sanbox_Revenecat = keys.firstWhere(
        (row) => row['name'] == 'SandBox_RevenueCat',
        orElse: () => throw StateError('SandBox_RevenueCat key not found'),
      )['api_key'];

      _getGoogleAPI = keys.firstWhere(
        (row) => row['name'] == 'googleAPI',
        orElse: () => throw StateError('googleAPI key not found'),
      )['api_key'];

      _getAppleAPI = keys.firstWhere(
        (row) => row['name'] == 'appleAPI',
        orElse: () => throw StateError('appleAPI key not found'),
      )['api_key'];

      _getAmazonAPI = keys.firstWhere(
        (row) => row['name'] == 'amazonAPI',
        orElse: () => throw StateError('amazonAPI key not found'),
      )['api_key'];

      _isInitialized = true;
    } on Exception catch (e) {
      print('Error initializing ApiManager: $e');
      throw ErrorHandler.handle(e, message: 'Failed to get keys');
    }
  }



  String getRevenueCatApiKey() {
    if (!_isInitialized) throw StateError('RevenueCatAPI must be initialized before accessing keys');
    return _getRevenueCatApiKey;
  }

  String getEntitlementID() {
    if (!_isInitialized) throw StateError('entitlementID must be initialized before accessing keys');
    return _getEntitlementID;
  }

  String getGoogleAPI() {
    if (!_isInitialized) throw StateError('GoogleAPI must be initialized before accessing keys');
    return _getGoogleAPI;
  }

  String getAppleAPI() {
    if (!_isInitialized) throw StateError('AppleAPI must be initialized before accessing keys');
    return _getAppleAPI;
  }

  String getAmazonAPI() {
    if (!_isInitialized) throw StateError('AmazonAPI must be initialized before accessing keys');
    return _getAmazonAPI;
  }


}