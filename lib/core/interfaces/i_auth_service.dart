// lib/core/services/authentication/i_auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';



abstract class IAuthService {
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<AuthResponse> signUp(String email, String password, String name, String lastName);
  Future<void> refreshToken();
  Future<User?> getCurrentUser();
  Future<void>  forgotPassword(String email);

   Future<void> signInWithGoogle();
   Future<void> signInWithApple();
   Future<void> inviteUser(String email);
}
