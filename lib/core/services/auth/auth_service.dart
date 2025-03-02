import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;

  AuthUser({
    required this.uid,
    this.email,
    this.displayName,
  });
}

class AuthService {
  final SupabaseClient _supabaseClient;

  AuthService(this._supabaseClient);

  Future<AuthUser?> get currentUser async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      return null;
    }

    return AuthUser(
      uid: user.id,
      email: user.email,
      displayName: user.userMetadata?['name'] as String?,
    );
  }

  Future<bool> isUserAdmin(String userId) async {
    if (userId.isEmpty) {
      return false;
    }

    try {
      // Query the user_roles table to check if the user has admin role
      final response = await _supabaseClient
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .eq('role', 'admin')
          .single();

      // If we get a response, the user is an admin
      return response != null;
    } catch (e) {
      // If there's an error or no record found, the user is not an admin
      return false;
    }
  }
}
