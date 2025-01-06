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

  ApiManager(this._supabaseClient);



  Future<void> initialize() async {
    try {
      final keys = await _supabaseClient.from('api_resources').select('name,api_key');
      
      _getRevenueCatApiKey = keys.firstWhere(
        (row) => row['name'] == 'RevenueCat',
        orElse: () => {'RevenueCat': 'Key not found'}
      )['RevenueCat'];

      _getEntitlementID = keys.firstWhere(
        (row) => row['name'] == 'entitlementID',
        orElse: () => {'entitlementID': 'Key not found'}
      )['entitlementID'];

      _sanbox_Revenecat = keys.firstWhere(
        (row) => row['name'] == 'SandBox_RevenueCat',
        orElse: () => {'SandBox_RevenueCat': 'Key not found'}
      )['SandBox_RevenueCat'];

      _getGoogleAPI = keys.firstWhere(
        (row) => row['name'] == 'googleAPI', 
        orElse: () => {'googleAPI': 'Key not found'}
      )['googleAPI'];

      _getAppleAPI = keys.firstWhere(
        (row) => row['name'] == 'appleAPI',
        orElse: () => {'appleAPI': 'Key not found'}
      )['appleAPI'];

      _getAmazonAPI = keys.firstWhere(
        (row) => row['name'] == 'amazonAPI',
        orElse: () => {'amazonAPI': 'Key not found'}
      )['amazonAPI'];

      _isInitialized = true;
    } on Exception catch (e) {
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