import 'package:flutter/material.dart';

class MovieDetailsProvider extends ChangeNotifier {
  Map<String, dynamic> _details = {};
  bool _isLoading = false;
  String _errorMessage = '';

  Map<String, dynamic> get details => _details;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setDetails(Map<String, dynamic> details) {
    _details = details;
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
