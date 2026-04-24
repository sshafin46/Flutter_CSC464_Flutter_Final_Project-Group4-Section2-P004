import 'package:flutter/material.dart';

class MockUser {
  final String uid;
  final String email;

  MockUser({required this.uid, required this.email});
}

class AuthProvider extends ChangeNotifier {
  MockUser? _currentUser;
  final Map<String, String> _users = {'test@example.com': 'password123'};

  MockUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (!_users.containsKey(email)) {
        _error = 'User not found';
        return false;
      }

      if (_users[email] != password) {
        _error = 'Invalid password';
        return false;
      }

      _currentUser = MockUser(uid: email.hashCode.toString(), email: email);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
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
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (_users.containsKey(email)) {
        _error = 'User already exists';
        return false;
      }

      _users[email] = password;
      _currentUser = MockUser(uid: email.hashCode.toString(), email: email);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      if (!_users.containsKey(email)) {
        _error = 'User not found';
        return false;
      }
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
