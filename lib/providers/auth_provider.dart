import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? bio,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update user profile
      await userCredential.user?.updateDisplayName('$firstName $lastName');
      await userCredential.user?.reload();

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      _error = 'Failed to sign out';
    }
    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      _error = 'Password reset email sent';
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      _error = 'Failed to send reset email';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Invalid password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email format';
      default:
        return 'Authentication failed: $code';
    }
  }
}
