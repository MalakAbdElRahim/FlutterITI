import '../Service/TMDBApiService.dart';
import '../Provider/MovieDetailsProvider.dart';

class MovieDetailsController {
  final TMDBApiService _apiService;
  final MovieDetailsProvider _provider;

  MovieDetailsController({
    required MovieDetailsProvider provider,
    TMDBApiService? apiService,
  })  : _provider = provider,
        _apiService = apiService ?? TMDBApiService();

  Future<void> fetchDetails(int movieId) async {
    _provider.setLoading(true);
    try {
      final details = await _apiService.getMovieDetailsFull(movieId);
      _provider.setDetails(details);
    } catch (e) {
      _provider.setError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
