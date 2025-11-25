import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile.dart';

class AuthController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  Profile? _profile;
  bool _isLoading = true;

  User? get user => _user;
  Profile? get profile => _profile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthController() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      if (_user != null) {
        _loadProfile();
      } else {
        _profile = null;
        _isLoading = false;
        notifyListeners();
      }
    });

    // Check for existing session
    _user = _supabase.auth.currentUser;
    if (_user != null) {
      await _loadProfile();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', _user!.id)
          .maybeSingle();

      if (data != null) {
        _profile = Profile.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Check if username is already taken
      final existingUsername = await _supabase
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (existingUsername != null) {
        throw Exception('Username already taken');
      }

      // Sign up user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create profile
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'username': username,
          'display_name': username,
        });

        // Reload profile
        _user = response.user;
        await _loadProfile();
      }
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? username,
    String? displayName,
    String? avatarUrl,
  }) async {
    if (_profile == null) return;

    try {
      final updates = <String, dynamic>{
        'id': _user!.id,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updates['username'] = username;
      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase.from('profiles').update(updates).eq('id', _user!.id);

      // Reload profile
      await _loadProfile();
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }
}
