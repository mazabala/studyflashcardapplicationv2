// lib/core/providers/supabase_provider.dart

import 'package:riverpod/riverpod.dart';
import 'package:flashcardstudyapplication/core/services/supabase/supabase_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



// Singleton instance of SupabaseService
SupabaseService? _instance;

// Define a Provider for SupabaseClient
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Define a Provider for SupabaseService that maintains a singleton instance
final supabaseServiceProvider = Provider<ISupabaseService>((ref) {
  _instance ??= SupabaseService();
  return _instance!;
});
