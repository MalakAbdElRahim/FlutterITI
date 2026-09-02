import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../Model/MovieModel.dart';

class DatabaseServices {
  static final DatabaseServices instance = DatabaseServices();

  static Database? _database;
  static bool _factoryInitialized = false;

  final List<Map<String, dynamic>> _inMemoryStore = [];

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    try {
      
      _database = await _initDatabase();
      return _database;
    } catch (e) {
      debugPrint("SQLite initialization fallback: $e");
      return null;
    }
  }

  Future<Database> _initDatabase() async {
    if (!_factoryInitialized) {
      if (kIsWeb) {
        databaseFactory = databaseFactoryFfiWebNoWebWorker;
      } else if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      _factoryInitialized = true;
    }

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

  Future<int> addMovieToList(MovieModel movie, String listType) async {
    final db = await database;
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

    if (db != null) {
      return await db.insert(
        'user_movies',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _inMemoryStore.removeWhere((m) => m['movie_id'] == movie.id && m['list_type'] == listType);
      _inMemoryStore.add(row);
      return 1;
    }
  }

  Future<void> removeMovieFromList(int movieId, String listType) async {
    final db = await database;
    if (db != null) {
      await db.delete(
        'user_movies',
        where: 'movie_id = ? AND list_type = ?',
        whereArgs: [movieId, listType],
      );
    } else {
      _inMemoryStore.removeWhere((m) => m['movie_id'] == movieId && m['list_type'] == listType);
    }
  }

  Future<bool> isMovieInList(int movieId, String listType) async {
    final db = await database;
    if (db != null) {
      final data = await db.query(
        'user_movies',
        where: 'movie_id = ? AND list_type = ?',
        whereArgs: [movieId, listType],
      );
      return data.isNotEmpty;
    } else {
      return _inMemoryStore.any((m) => m['movie_id'] == movieId && m['list_type'] == listType);
    }
  }

  Future<List<String>> getMovieLists(int movieId) async {
    final db = await database;
    if (db != null) {
      final data = await db.query(
        'user_movies',
        columns: ['list_type'],
        where: 'movie_id = ?',
        whereArgs: [movieId],
      );
      return data.map((row) => row['list_type'] as String).toList();
    } else {
      return _inMemoryStore
          .where((m) => m['movie_id'] == movieId)
          .map((m) => m['list_type'] as String)
          .toList();
    }
  }

  Future<List<MovieModel>> getMoviesByListType(String listType) async {
    final db = await database;
    List<Map<String, dynamic>> rows = [];
    if (db != null) {
      rows = await db.query(
        'user_movies',
        where: 'list_type = ?',
        whereArgs: [listType],
      );
    } else {
      rows = _inMemoryStore.where((m) => m['list_type'] == listType).toList();
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
