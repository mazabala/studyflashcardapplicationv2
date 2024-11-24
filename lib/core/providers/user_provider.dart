import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/interfaces/i_api_service.dart';
import 'package:flashcardstudyapplication/core/services/api/api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcardstudyapplication/core/services/users/users_service.dart';

// Define a provider for Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final supabaseClient = Supabase.instance.client;
  return supabaseClient;
});

Future<String> getUserSubscriptionPlan()
{
  try {
      final userSubscription = getUserSubscriptionPlan();
      return userSubscription;
      }catch(e){
          throw Exception(e);

      }

}



// Define a provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  final apiService = ref.read(apiClientProvider);

  return UserService(supabaseClient, apiService);
});
