import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_service.dart';
import 'database_service.dart';

/// User model
class User {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? provider; // 'google', etc.

  User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.provider,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'provider': provider,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
      photoUrl: map['photoUrl'] as String?,
      provider: map['provider'] as String?,
    );
  }
}

/// Authentication service
class AuthService extends AppService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  GoogleSignIn? _googleSignIn;
  User? _currentUser;
  bool _isInitialized = false;

  /// Get current user
  User? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Google Sign In
      final String? webClientId = dotenv.env['GOOGLE_SIGN_IN_WEB_CLIENT_ID'];

      _googleSignIn = GoogleSignIn(
        scopes: <String>['email', 'profile'],
        // Use web client ID if available (for web platform)
        clientId: webClientId,
      );

      // Try to restore previous session
      await _restoreSession();

      _isInitialized = true;
    } catch (e) {
      debugPrint('AuthService initialization error: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<User> signInWithGoogle() async {
    if (_googleSignIn == null) {
      throw Exception('AuthService not initialized. Call initialize() first.');
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create user object
      final User user = User(
        id: googleUser.id,
        email: googleUser.email,
        name: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        provider: 'google',
      );

      // Save user to database
      await _saveUserToDatabase(user);

      // Save session locally
      await _saveSession(user);

      _currentUser = user;
      return user;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }

      // Clear local session
      await _clearSession();

      _currentUser = null;
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Save user to database
  Future<void> _saveUserToDatabase(User user) async {
    try {
      final DatabaseService db = DatabaseService();
      if (!db.isConnected) {
        await db.initialize();
      }

      final Map<String, dynamic> userDoc = {
        ...user.toMap(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Upsert user (update if exists, insert if not)
      await db.updateOne(
        'users',
        {'id': user.id},
        userDoc,
        upsert: true,
      );
    } catch (e) {
      debugPrint('Error saving user to database: $e');
      // Don't throw - allow sign in to continue even if DB save fails
    }
  }

  /// Save session to local storage
  Future<void> _saveSession(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    if (user.name != null) {
      await prefs.setString('user_name', user.name!);
    }
    if (user.photoUrl != null) {
      await prefs.setString('user_photo_url', user.photoUrl!);
    }
    if (user.provider != null) {
      await prefs.setString('user_provider', user.provider!);
    }
  }

  /// Restore session from local storage
  Future<void> _restoreSession() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');

      if (userId == null) return;

      // Try to restore from Google Sign In first
      if (_googleSignIn != null) {
        final GoogleSignInAccount? account = await _googleSignIn!.signInSilently();
        if (account != null) {
          _currentUser = User(
            id: account.id,
            email: account.email,
            name: account.displayName,
            photoUrl: account.photoUrl,
            provider: 'google',
          );
          return;
        }
      }

      // Fallback to local storage
      final String? email = prefs.getString('user_email');
      if (email != null) {
        _currentUser = User(
          id: userId,
          email: email,
          name: prefs.getString('user_name'),
          photoUrl: prefs.getString('user_photo_url'),
          provider: prefs.getString('user_provider'),
        );
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
    }
  }

  /// Clear session from local storage
  Future<void> _clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_photo_url');
    await prefs.remove('user_provider');
  }

  @override
  void dispose() {
    _googleSignIn = null;
    _currentUser = null;
    _isInitialized = false;
  }
}


