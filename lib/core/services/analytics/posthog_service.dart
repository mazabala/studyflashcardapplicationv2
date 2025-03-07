import 'dart:developer';

import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../interfaces/i_posthog_service.dart';

class PostHogService implements IPostHogService {
  final SupabaseClient _supabaseClient;
  late final Posthog _posthog;

  PostHogService(this._supabaseClient);

  @override
  Future<void> initialize() async {
    try {
      // Fetch PostHog API key from Supabase
      final response = await _supabaseClient
          .from('api_resources')
          .select('api_key')
          .eq('name', 'Posthog_api_key')
          .single();

      final apiKey = response['api_key'] as String;
      log('apiKey: $apiKey');

      // Initialize PostHog
      _posthog = Posthog();
      await _posthog.setup(
        PostHogConfig(apiKey)
          ..host = 'https://us.i.posthog.com'
          ..captureApplicationLifecycleEvents = true
          ..debug = true // Set to false in production
          ..preloadFeatureFlags = true,
      );
    } catch (e) {
      log('Error initializing PostHog: $e');
      rethrow;
    }
  }

  @override
  void capture({required String eventName, Map<String, dynamic>? properties}) {
    try {
      _posthog.capture(
        eventName: eventName,
        properties:
            properties?.map((key, value) => MapEntry(key, value as Object)),
      );
    } catch (e) {
      print('Error capturing event: $e');
    }
  }

  @override
  void identify(
      {required String userId, Map<String, dynamic>? userProperties}) {
    try {
      _posthog.identify(
        userId: userId,
        userProperties:
            userProperties?.map((key, value) => MapEntry(key, value as Object)),
      );
    } catch (e) {
      print('Error identifying user: $e');
    }
  }

  @override
  void screen({required String screenName, Map<String, dynamic>? properties}) {
    try {
      _posthog.screen(
        screenName: screenName,
        properties:
            properties?.map((key, value) => MapEntry(key, value as Object)),
      );
    } catch (e) {
      print('Error logging screen view: $e');
    }
  }

  @override
  void reset() {
    try {
      _posthog.reset();
    } catch (e) {
      print('Error resetting PostHog: $e');
    }
  }
}
