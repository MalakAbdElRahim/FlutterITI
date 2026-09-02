import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Model/MovieModel.dart';
import 'SharedPService.dart';

class DatabaseServices {
  static final DatabaseServices instance = DatabaseServices();

  static Database? _database;
  final SharedPService _webStorage = SharedPService.instance;

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

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
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS user_movies');
          await _createDatabase(db, newVersion);
        }
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_movies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        movie_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        poster_path TEXT,
        backdrop_path TEXT,
        vote_average REAL,
        release_date TEXT,
        overview TEXT,
        list_type TEXT NOT NULL,
        UNIQUE(user_id, movie_id, list_type)
      )
    ''');
  }

  // --- Public Operations ---

  Future<int> addMovieToList(MovieModel movie, String listType) async {
    final uid = _currentUserId;
    if (kIsWeb) {
      return await _webStorage.addMovie(movie, listType, userId: uid);
    }

    final db = await database;
    if (db != null) {
      final row = {
        'user_id': uid,
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
    final uid = _currentUserId;
    if (kIsWeb) {
      await _webStorage.removeMovie(movieId, listType, userId: uid);
      return;
    }

    final db = await database;
    if (db != null) {
      await db.delete(
        'user_movies',
        where: 'user_id = ? AND movie_id = ? AND list_type = ?',
        whereArgs: [uid, movieId, listType],
      );
    }
  }

  Future<bool> isMovieInList(int movieId, String listType) async {
    final uid = _currentUserId;
    if (kIsWeb) {
      return await _webStorage.isMovieInList(movieId, listType, userId: uid);
    }

    final db = await database;
    if (db != null) {
      final data = await db.query(
        'user_movies',
        where: 'user_id = ? AND movie_id = ? AND list_type = ?',
        whereArgs: [uid, movieId, listType],
      );
      return data.isNotEmpty;
    }
    return false;
  }

  Future<List<String>> getMovieLists(int movieId) async {
    final uid = _currentUserId;
    if (kIsWeb) {
      return await _webStorage.getMovieLists(movieId, userId: uid);
    }

    final db = await database;
    if (db != null) {
      final data = await db.query(
        'user_movies',
        columns: ['list_type'],
        where: 'user_id = ? AND movie_id = ?',
        whereArgs: [uid, movieId],
      );
      return data.map((row) => row['list_type'] as String).toList();
    }
    return [];
  }

  Future<List<MovieModel>> getMoviesByListType(String listType) async {
    final uid = _currentUserId;
    if (kIsWeb) {
      return await _webStorage.getMoviesByListType(listType, userId: uid);
    }

    final db = await database;
    List<Map<String, dynamic>> rows = [];
    if (db != null) {
      rows = await db.query(
        'user_movies',
        where: 'user_id = ? AND list_type = ?',
        whereArgs: [uid, listType],
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
