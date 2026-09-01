import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/MovieModel.dart';
import '../Model/GenreModel.dart';

class TMDBApiService {
  final String apiKey = "d155a946047c94a3341a8d3e9dd22b93";

  List<MovieModel> _parseAndFilterMovies(List<dynamic> results) {
    return results
        .map((e) => MovieModel.fromJson(e))
        .where((movie) => !movie.adult && !movie.softcore)
        .toList();
  }

  Future<List<Genre>> getGenres() async {
    final url = Uri.parse("https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final genreModel = GenreModel.fromJson(data);
      return genreModel.genres;
    } else {
      throw Exception("Failed to load genres: HTTP ${response.statusCode}");
    }
  }

  Future<List<MovieModel>> getPopularMovies() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&include_adult=false");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"] ?? [];
      return _parseAndFilterMovies(results);
    } else {
      throw Exception("Failed to load popular movies");
    }
  }

  Future<List<MovieModel>> getTopRatedMovies() async {
    final url = Uri.parse("https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&sort_by=vote_average.desc&vote_count.gte=300&include_adult=false");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"] ?? [];
      return _parseAndFilterMovies(results);
    } else {
      throw Exception("Failed to load top rated movies");
    }
  }

  Future<List<MovieModel>> getNowPlayingMovies() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey&include_adult=false");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"] ?? [];
      return _parseAndFilterMovies(results);
    } else {
      throw Exception("Failed to load now playing movies");
    }
  }

  Future<List<MovieModel>> getUpcomingMovies() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey&region=US&include_adult=false");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"] ?? [];
      return _parseAndFilterMovies(results);
    } else {
      throw Exception("Failed to load upcoming movies");
    }
  }

  Future<Map<String, dynamic>> searchMoviesPaginated(String query, {int page = 1}) async {
    final uri = Uri.https("api.themoviedb.org", "/3/search/movie", {
      "api_key": apiKey,
      "query": query.trim(),
      "page": page.toString(),
      "include_adult": "false",
    });
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"] ?? [];
      final List<MovieModel> movies = _parseAndFilterMovies(results);
      return {
        "movies": movies,
        "page": (data["page"] as num?)?.toInt() ?? page,
        "totalPages": (data["total_pages"] as num?)?.toInt() ?? 1,
        "totalResults": (data["total_results"] as num?)?.toInt() ?? 0,
      };
    } else {
      throw Exception("Failed to search movies: HTTP ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final uri = Uri.https("api.themoviedb.org", "/3/discover/movie", {
      "api_key": apiKey,
      "with_genres": genreId.toString(),
      "page": page.toString(),
      "include_adult": "false",
    });
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"] ?? [];
      final List<MovieModel> movies = _parseAndFilterMovies(results);
      return {
        "movies": movies,
        "page": (data["page"] as num?)?.toInt() ?? page,
        "totalPages": (data["total_pages"] as num?)?.toInt() ?? 1,
        "totalResults": (data["total_results"] as num?)?.toInt() ?? 0,
      };
    } else {
      throw Exception("Failed to load genre movies: HTTP ${response.statusCode}");
    }
  }
}

