// lib/core/services/authentication/auth_service.dart

import 'package:flashcardstudyapplication/core/interfaces/i_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthService implements IAuthService {
  final SupabaseClient _supabaseClient;

  // Constructor that takes SupabaseClient
  AuthService(this._supabaseClient);

  @override
  Future<void> signIn(String email, String password) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response==null) {
      throw Exception(response); // Throw error if sign-in fails
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();  // Sign the user out
  }

  @override
  Future<void> signUp(String email, String password) async {
    
    try{
      
      final response = await _supabaseClient.auth.signUp(email: email, password: password);

    if (response == null ) {
      throw Exception(response); // Handle error
    }
    }catch (e){
      print (e);
      throw e;
    }
  }

  @override
  Future<void> refreshToken() async {
    final response = await _supabaseClient.auth.refreshSession();
    if (response != null) {
      throw Exception(response); // Handle error
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    return user; // Return current authenticated user
  }
}
