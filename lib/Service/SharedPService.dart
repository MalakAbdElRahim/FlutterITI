import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/MovieModel.dart';

class SharedPService {
  static final SharedPService instance = SharedPService._internal();

  SharedPService._internal();

  static const String _webStorageKey = 'user_movies_web';

  Future<List<Map<String, dynamic>>> _getWebMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_webStorageKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint("Error reading shared preferences: $e");
      return [];
    }
  }

  Future<void> _saveWebMovies(List<Map<String, dynamic>> movies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(movies);
      await prefs.setString(_webStorageKey, encoded);
    } catch (e) {
      debugPrint("Error saving to shared preferences: $e");
    }
  }

  Future<int> addMovie(MovieModel movie, String listType, {String userId = 'guest'}) async {
    final row = {
      'user_id': userId,
      'movie_id': movie.id,
      'title': movie.title,
      'poster_path': movie.posterPath,
      'backdrop_path': movie.backdropPath,
      'vote_average': movie.voteAverage,
      'release_date': movie.releaseDate != null ? movie.fullReleaseDate : null,
      'overview': movie.overview,
      'list_type': listType,
    };

    final movies = await _getWebMovies();
    movies.removeWhere(
      (m) =>
          (m['user_id'] == userId || (userId == 'guest' && m['user_id'] == null)) &&
          m['movie_id'] == movie.id &&
          m['list_type'] == listType,
    );
    movies.add(row);
    await _saveWebMovies(movies);
    return 1;
  }

  Future<void> removeMovie(int movieId, String listType, {String userId = 'guest'}) async {
    final movies = await _getWebMovies();
    movies.removeWhere(
      (m) =>
          (m['user_id'] == userId || (userId == 'guest' && m['user_id'] == null)) &&
          m['movie_id'] == movieId &&
          m['list_type'] == listType,
    );
    await _saveWebMovies(movies);
  }

  Future<bool> isMovieInList(int movieId, String listType, {String userId = 'guest'}) async {
    final movies = await _getWebMovies();
    return movies.any(
      (m) =>
          (m['user_id'] == userId || (userId == 'guest' && m['user_id'] == null)) &&
          m['movie_id'] == movieId &&
          m['list_type'] == listType,
    );
  }

  Future<List<String>> getMovieLists(int movieId, {String userId = 'guest'}) async {
    final movies = await _getWebMovies();
    return movies
        .where(
          (m) =>
              (m['user_id'] == userId || (userId == 'guest' && m['user_id'] == null)) &&
              m['movie_id'] == movieId,
        )
        .map((m) => m['list_type'] as String)
        .toList();
  }

  Future<List<MovieModel>> getMoviesByListType(String listType, {String userId = 'guest'}) async {
    final movies = await _getWebMovies();
    final rows = movies.where(
      (m) =>
          (m['user_id'] == userId || (userId == 'guest' && m['user_id'] == null)) &&
          m['list_type'] == listType,
    ).toList();

    return rows.map<MovieModel>((row) {
      return MovieModel.fromJson({
        'id': row['movie_id'],
        'title': row['title'],
        'poster_path': row['poster_path'],
        'backdrop_path': row['backdrop_path'],
        'vote_average': row['vote_average'],
        'release_date': row['release_date'],
        'overview': row['overview'],
        'adult': false,
        'softcore': false,
        'video': false,
        'original_language': 'en',
        'popularity': 0.0,
        'genre_ids': <int>[],
      });
    }).toList();
  }
}
