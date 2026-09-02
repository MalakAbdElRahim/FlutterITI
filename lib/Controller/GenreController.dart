import '../Service/TMDBApiService.dart';
import '../Provider/GenreProvider.dart';
import '../Model/MovieModel.dart';

class GenreController {
  final TMDBApiService _apiService;
  final GenreProvider _provider;

  GenreController({
    required GenreProvider provider,
    TMDBApiService? apiService,
  })  : _provider = provider,
        _apiService = apiService ?? TMDBApiService();

  Future<void> fetchGenres() async {
    _provider.setLoading(true);
    try {
      final genres = await _apiService.getGenres();
      _provider.setGenres(genres);
    } catch (e) {
      _provider.setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> fetchMoviesByGenre(int genreId, {int page = 1}) async {
    _provider.setLoading(true);
    try {
      final result = await _apiService.getMoviesByGenre(genreId, page: page);
      _provider.setMovies(
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
