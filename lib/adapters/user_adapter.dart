import 'package:supabase_flutter/supabase_flutter.dart';

class UserAdapter {
  // inscription par email/password
  Future signUp(String email, String password) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  // connexion par email/password
  Future signIn(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // connexion via Google
  Future<bool> signInWithGoogle() async {
    return await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  // connexion via Apple
  Future<bool> signInWithApple() async {
    return await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.apple,
    );
  }
}
