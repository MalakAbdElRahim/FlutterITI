import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _warning = "";
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
    _warning = "";
    notifyListeners();
  }
}