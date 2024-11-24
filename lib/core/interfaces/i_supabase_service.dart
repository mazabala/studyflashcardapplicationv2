// lib/core/services/interfaces/i_supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ISupabaseService {
  SupabaseClient get client;
  Future<void> initialize();
}
