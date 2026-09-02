import '../Service/TMDBApiService.dart';
import '../Provider/SearchProvider.dart';
import '../Model/MovieModel.dart';

class MovieSearchController {
  final TMDBApiService _apiService;
  final SearchProvider _provider;

  MovieSearchController({
    required SearchProvider provider,
    TMDBApiService? apiService,
  })  : _provider = provider,
        _apiService = apiService ?? TMDBApiService();

  Future<void> search(String query, {int page = 1}) async {
    _provider.setLoading(true);
    try {
      final result = await _apiService.searchMoviesPaginated(query, page: page);
      _provider.setResults(
        movies: result['movies'] as List<MovieModel>,
        page: result['page'] as int,
        totalPages: result['totalPages'] as int,
        totalResults: result['totalResults'] as int,
      );
    } catch (e) {
      _provider.setError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
