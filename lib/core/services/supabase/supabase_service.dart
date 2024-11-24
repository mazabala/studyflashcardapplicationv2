// lib/core/services/supabase/supabase_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_supabase_service.dart';
import 'package:flashcardstudyapplication/core/error/error_handler.dart';
import 'package:yaml/yaml.dart';



class SupabaseService implements ISupabaseService {
  late final String _supabaseUrl;
  late final String _anonKey;

  @override
  SupabaseClient get client {
    return Supabase.instance.client;
  }

  @override
  Future<void> initialize() async {
    try {
      // Read config from YAML file
      final configFile = File('config/api.config');
      final yamlString = await configFile.readAsString();
      final yamlConfig = loadYaml(yamlString);

      // Extract Supabase URL and anon key
      _supabaseUrl = yamlConfig['supabase']['url'];
      _anonKey = yamlConfig['supabase']['anon_key'];

      // Initialize Supabase client
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _anonKey,
      );
    } catch (e) {
      throw ErrorHandler.handle(e, message: 'Failed to initialize Supabase');
    }
  }
}
