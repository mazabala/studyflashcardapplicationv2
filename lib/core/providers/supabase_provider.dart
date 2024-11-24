// lib/core/providers/supabase_provider.dart

import 'package:riverpod/riverpod.dart';
import 'package:flashcardstudyapplication/core/services/supabase/supabase_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_supabase_service.dart';


// Define a FutureProvider for the SupabaseService
final supabaseServiceProvider = FutureProvider<ISupabaseService>((ref) async {
  final supabaseService = SupabaseService();
  
  // Initialize the Supabase service asynchronously
  await supabaseService.initialize();
  
  // Return the SupabaseService instance after initialization
  return supabaseService;
});