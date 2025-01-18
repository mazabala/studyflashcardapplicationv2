// lib/core/services/authentication/auth_service.dart

import 'dart:convert';

import 'package:flashcardstudyapplication/core/interfaces/i_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService implements IAuthService {
  final SupabaseClient _supabaseClient;

  // Constructor that takes SupabaseClient
  AuthService(this._supabaseClient) {
    // Initialize session persistence
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      // Handle auth state changes if needed
    });
  }


@override
  Future<void> inviteUser(String email) async{
    try{
      print('======= sending invite =====');
   await _supabaseClient.auth.admin.inviteUserByEmail(email);
    }
    catch (e)
    {print ('Error: on auth service: $e');}
}

Future<void>  forgotPassword(String email) async{

      final response = await Supabase.instance.client.auth
        .resetPasswordForEmail(email);

}
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
      rethrow;
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
    // This will now return the persisted user if available
    
    final user = _supabaseClient.auth.currentUser;
    
    return user;
  }

Future<void> signInWithGoogle() async {
  /// TODO: update the Web client ID with your own.
  ///
  /// Web Client ID that you registered with Google Cloud.
  const webClientId = '554533078721-j7rkh5nqttb4svljrvkhh8mi77oloote.apps.googleusercontent.com';

  /// TODO: update the iOS client ID with your own.
  ///
  /// iOS Client ID that you registered with Google Cloud.
  const iosClientId = '554533078721-2i39941fuqmjh4mka39rvn5tv49ig56p.apps.googleusercontent.com';

  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: iosClientId,
    serverClientId: webClientId,
  );
  final googleUser = await googleSignIn.signIn();
  final googleAuth = await googleUser!.authentication;
  final accessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;

  if (accessToken == null) {
    throw 'No Access Token found.';
  }
  if (idToken == null) {
    throw 'No ID Token found.';
  }

  await _supabaseClient.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );
}

/// Performs Apple sign in on iOS or macOS
Future<AuthResponse> signInWithApple() async {
  final rawNonce = _supabaseClient.auth.generateRawNonce();
  final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );

  final idToken = credential.identityToken;
  if (idToken == null) {
    throw const AuthException(
        'Could not find ID Token from generated credential.');
  }

  return _supabaseClient.auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: idToken,
    nonce: rawNonce,
  );
}

}
