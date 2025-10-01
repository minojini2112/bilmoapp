import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/supabase_config.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }
  
  // Get current user
  static User? get currentUser => _supabase.auth.currentUser;
  
  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
  
  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      
      if (response.user != null) {
        await _saveUserSession();
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        await _saveUserSession();
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _clearUserSession();
    } catch (e) {
      rethrow;
    }
  }
  
  // Save user session to SharedPreferences
  static Future<void> _saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_email', currentUser?.email ?? '');
    await prefs.setString('user_id', currentUser?.id ?? '');
  }
  
  // Clear user session from SharedPreferences
  static Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
  }
  
  // Check if user session exists in SharedPreferences
  static Future<bool> hasStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
  
  // Get stored user email
  static Future<String?> getStoredUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }
  
  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
