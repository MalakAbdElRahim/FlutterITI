import 'package:flutter/material.dart';
import '../Model/MovieModel.dart';

class SearchProvider extends ChangeNotifier {
  List<MovieModel> _movies = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalResults = 0;
  bool _isLoading = false;
  String _errorMessage = '';

  List<MovieModel> get movies => _movies;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalResults => _totalResults;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = '';
    notifyListeners();
  }

  void setResults({
    required List<MovieModel> movies,
    required int page,
    required int totalPages,
    required int totalResults,
  }) {
    _movies = movies;
    _currentPage = page;
    _totalPages = totalPages;
    _totalResults = totalResults;
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
