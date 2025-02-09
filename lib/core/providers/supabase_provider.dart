// lib/core/providers/supabase_provider.dart

import 'package:riverpod/riverpod.dart';
import 'package:flashcardstudyapplication/core/services/supabase/supabase_service.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



// Singleton instance of SupabaseService
SupabaseService? _instance;
