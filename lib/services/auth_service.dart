import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      if (e is AuthApiException) {
        if (e.code == 'email_not_confirmed') {
          throw Exception('Por favor confirma tu email antes de iniciar sesión. Revisa tu bandeja de entrada.');
        }
        throw Exception(e.message);
      }
      rethrow;
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'full_name': displayName} : null,
      );
    } catch (e) {
      debugPrint('Error signing up with email: $e');
      if (e is AuthApiException) {
        throw Exception(e.message);
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile info
  Map<String, dynamic>? get userProfile {
    if (currentUser == null) return null;
    return {
      'id': currentUser!.id,
      'email': currentUser!.email,
      'name': currentUser!.userMetadata?['full_name'] ?? 
              currentUser!.userMetadata?['name'] ?? 
              'Usuario',
      'avatar': currentUser!.userMetadata?['avatar_url'] ?? 
                currentUser!.userMetadata?['picture'],
    };
  }

  // Check and refresh session
  Future<bool> hasValidSession() async {
    try {
      final session = _supabase.auth.currentSession;
      return session != null;
    } catch (e) {
      debugPrint('Session check failed: $e');
      return false;
    }
  }
}
