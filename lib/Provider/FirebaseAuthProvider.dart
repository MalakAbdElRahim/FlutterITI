import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Service/FirebaseAuthService.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _isLoading = false;
  String _warning = '';
  User? _user;

  bool get isLoading => _isLoading;
  String get warning => _warning;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setWarning(String warn) {
    _warning = warn;
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void clearWarning() {
    _warning = '';
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.logOut();
    _user = null;
    notifyListeners();
  }
}