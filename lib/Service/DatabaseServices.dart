import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Model/MovieModel.dart';
import 'SharedPService.dart';

class DatabaseServices {
  static final DatabaseServices instance = DatabaseServices();

  static Database? _database;
  final SharedPService _webStorage = SharedPService.instance;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database;

    try {
      _database = await _initDatabase();
      return _database;
    } catch (e) {
      debugPrint("SQLite initialization error: $e");
      return null;
    }
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'movies.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_movies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        poster_path TEXT,
        backdrop_path TEXT,
        vote_average REAL,
        release_date TEXT,
        overview TEXT,
        list_type TEXT NOT NULL,
        UNIQUE(movie_id, list_type)
      )
    ''');
  }

  // --- Public Operations ---

  Future<int> addMovieToList(MovieModel movie, String listType) async {
    if (kIsWeb) {
      return await _webStorage.addMovie(movie, listType);
    }

    final db = await database;
    if (db != null) {
      final row = {
        'movie_id': movie.id,
        'title': movie.title,
        'poster_path': movie.posterPath,
        'backdrop_path': movie.backdropPath,
        'vote_average': movie.voteAverage,
        'release_date': movie.releaseDate != null ? movie.fullReleaseDate : null,
        'overview': movie.overview,
        'list_type': listType,
      };

      return await db.insert(
        'user_movies',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return 0;
  }

  Future<void> removeMovieFromList(int movieId, String listType) async {
    if (kIsWeb) {
      await _webStorage.removeMovie(movieId, listType);
      return;
    }

    final db = await database;
    if (db != null) {
      await db.delete(
        'user_movies',
        where: 'movie_id = ? AND list_type = ?',
        whereArgs: [movieId, listType],
      );
    }
  }

  Future<bool> isMovieInList(int movieId, String listType) async {
    if (kIsWeb) {
      return await _webStorage.isMovieInList(movieId, listType);
    }

    final db = await database;
    if (db != null) {
      final data = await db.query(
        'user_movies',
        where: 'movie_id = ? AND list_type = ?',
        whereArgs: [movieId, listType],
      );
      return data.isNotEmpty;
    }
    return false;
  }

  Future<List<String>> getMovieLists(int movieId) async {
    if (kIsWeb) {
      return await _webStorage.getMovieLists(movieId);
    }

    final db = await database;
    if (db != null) {
      final data = await db.query(
        'user_movies',
        columns: ['list_type'],
        where: 'movie_id = ?',
        whereArgs: [movieId],
      );
      return data.map((row) => row['list_type'] as String).toList();
    }
    return [];
  }

  Future<List<MovieModel>> getMoviesByListType(String listType) async {
    if (kIsWeb) {
      return await _webStorage.getMoviesByListType(listType);
    }

    final db = await database;
    List<Map<String, dynamic>> rows = [];
    if (db != null) {
      rows = await db.query(
        'user_movies',
        where: 'list_type = ?',
        whereArgs: [listType],
      );
   }

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
