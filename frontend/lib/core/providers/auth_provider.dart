import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  Future<void> signIn(String email, String password) async {
    try {
      // TODO: Implement actual Firebase authentication
      _isAuthenticated = true;
      _userEmail = email;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _userName = email.split('@')[0];
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      // TODO: Implement actual Firebase registration
      _isAuthenticated = true;
      _userEmail = email;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _userName = name;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // TODO: Implement actual Firebase sign out
      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;
      _userName = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
} 