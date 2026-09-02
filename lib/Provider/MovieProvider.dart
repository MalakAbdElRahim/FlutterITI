import 'package:flutter/material.dart';
import '../Model/MovieModel.dart';

class MovieProvider extends ChangeNotifier {
  List<MovieModel> _popularMovies = [];
  List<MovieModel> _nowPlayingMovies = [];
  List<MovieModel> _topRatedMovies = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<MovieModel> get popularMovies => _popularMovies;
  List<MovieModel> get nowPlayingMovies => _nowPlayingMovies;
  List<MovieModel> get topRatedMovies => _topRatedMovies;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setMovies({
    required List<MovieModel> popular,
    required List<MovieModel> nowPlaying,
    required List<MovieModel> topRated,
  }) {
    _popularMovies = popular;
    _nowPlayingMovies = nowPlaying;
    _topRatedMovies = topRated;
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }
}
