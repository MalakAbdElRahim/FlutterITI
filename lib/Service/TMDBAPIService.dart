import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/MovieModel.dart';

class TMDBApiService {
  final String apiKey = "d155a946047c94a3341a8d3e9dd22b93";

  Future<List<MovieModel>> getPopularMovies() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/popular?api_key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load popular movies");
    }
  }

  Future<List<MovieModel>> getTopRatedMovies() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load top rated movies");
    }
  }

  Future<List<MovieModel>> getNowPlayingMovies() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load now playing movies");
    }
  }

  Future<List<MovieModel>> getUpcomingMovies() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load upcoming movies");
    }
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    final url = Uri.parse("https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to search movies");
    }
  }
}

