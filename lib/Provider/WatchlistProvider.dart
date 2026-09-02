import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/MovieModel.dart';
import '../Service/DatabaseServices.dart';

class WatchlistProvider extends ChangeNotifier {
  final DatabaseServices _dbService = DatabaseServices.instance;

  List<MovieModel> _favorites = [];
  List<MovieModel> _watching = [];
  List<MovieModel> _toWatch = [];
  List<MovieModel> _watched = [];
  bool _isLoading = false;

  List<MovieModel> get favorites => _favorites;
  List<MovieModel> get watching => _watching;
  List<MovieModel> get toWatch => _toWatch;
  List<MovieModel> get watched => _watched;
  bool get isLoading => _isLoading;

  WatchlistProvider() {
    loadAllLists();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      loadAllLists();
    });
  }

  Future<void> loadAllLists() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _dbService.getMoviesByListType('favorites');
      _watching = await _dbService.getMoviesByListType('watching');
      _toWatch = await _dbService.getMoviesByListType('to_watch');
      _watched = await _dbService.getMoviesByListType('watched');
    } catch (e) {
      debugPrint("Error loading watchlist from database: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(int movieId) {
    return _favorites.any((m) => m.id == movieId);
  }

  bool isWatching(int movieId) {
    return _watching.any((m) => m.id == movieId);
  }

  bool isToWatch(int movieId) {
    return _toWatch.any((m) => m.id == movieId);
  }

  bool isWatched(int movieId) {
    return _watched.any((m) => m.id == movieId);
  }

  Future<bool> toggleFavorite(MovieModel movie) async {
    final exists = isFavorite(movie.id);
    if (exists) {
      await _dbService.removeMovieFromList(movie.id, 'favorites');
      _favorites.removeWhere((m) => m.id == movie.id);
    } else {
      await _dbService.addMovieToList(movie, 'favorites');
      _favorites.add(movie);
    }
    notifyListeners();
    return !exists;
  }

  Future<bool> toggleWatching(MovieModel movie) async {
    final exists = isWatching(movie.id);
    if (exists) {
      await _dbService.removeMovieFromList(movie.id, 'watching');
      _watching.removeWhere((m) => m.id == movie.id);
    } else {
      await _dbService.addMovieToList(movie, 'watching');
      _watching.add(movie);
    }
    notifyListeners();
    return !exists;
  }

  Future<bool> toggleToWatch(MovieModel movie) async {
    final exists = isToWatch(movie.id);
    if (exists) {
      await _dbService.removeMovieFromList(movie.id, 'to_watch');
      _toWatch.removeWhere((m) => m.id == movie.id);
    } else {
      await _dbService.addMovieToList(movie, 'to_watch');
      _toWatch.add(movie);
    }
    notifyListeners();
    return !exists;
  }

  Future<bool> toggleWatched(MovieModel movie) async {
    final exists = isWatched(movie.id);
    if (exists) {
      await _dbService.removeMovieFromList(movie.id, 'watched');
      _watched.removeWhere((m) => m.id == movie.id);
    } else {
      await _dbService.addMovieToList(movie, 'watched');
      _watched.add(movie);
    }
    notifyListeners();
    return !exists;
  }

  Future<void> removeMovie(int movieId, String listType) async {
    await _dbService.removeMovieFromList(movieId, listType);
    if (listType == 'favorites') {
      _favorites.removeWhere((m) => m.id == movieId);
    } else if (listType == 'watching') {
      _watching.removeWhere((m) => m.id == movieId);
    } else if (listType == 'to_watch') {
      _toWatch.removeWhere((m) => m.id == movieId);
    } else if (listType == 'watched') {
      _watched.removeWhere((m) => m.id == movieId);
    }
    notifyListeners();
  }
}
