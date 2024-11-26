// // lib/core/services/supabase/supabase_configuration.dart

// import 'dart:io';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:yaml/yaml.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flashcardstudyapplication/core/error/error_handler.dart';

// // Configuration class to initialize and provide Supabase Client
// class SupabaseConfig {
//   static late final String _supabaseUrl;
//   static late final String _anonKey;

//   // Initialize Supabase configuration by reading from the api.config.yaml
//   static Future<void> initialize() async {
//     try {
//       final configFile = File('config/api.config');
//       final yamlString = await configFile.readAsString();
//       final yamlConfig = loadYaml(yamlString);

//       // Extract Supabase URL and anon key
//       _supabaseUrl = yamlConfig['supabase']['url'];
//       _anonKey = yamlConfig['supabase']['anon_key'];

//       // Initialize Supabase client
//       await Supabase.initialize(
//         url: _supabaseUrl,
//         anonKey: _anonKey,
//       );
//     } catch (e) {
//       throw ErrorHandler.handle(e, message: 'Failed to initialize Supabase');
//     }
//   }

//   static SupabaseClient get client {
//     return Supabase.instance.client;
//   }

//   // You can add more methods for convenience, such as fetching tables, user sessions, etc.
// }

// // Define a provider for SupabaseClient
// final supabaseClientProvider = FutureProvider<SupabaseClient>((ref) {

//   // This will provide access to the Supabase client in your app
//   return SupabaseConfig.client;
// });
