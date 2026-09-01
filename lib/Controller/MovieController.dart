import '../Service/TMDBApiService.dart';
import '../Provider/MovieProvider.dart';

class MovieController {
  final TMDBApiService _apiService;
  final MovieProvider _movieProvider;

  MovieController({
    required MovieProvider movieProvider,
    TMDBApiService? apiService,
  })  : _movieProvider = movieProvider,
        _apiService = apiService ?? TMDBApiService();

  Future<void> fetchHomeMovies() async {
    _movieProvider.setLoading(true);
    _movieProvider.setErrorMessage("");

    try {
      final results = await Future.wait([
        _apiService.getPopularMovies(),
        _apiService.getNowPlayingMovies(),
        _apiService.getTopRatedMovies(),
      ]);

      _movieProvider.setMovies(
        popular: results[0],
        nowPlaying: results[1],
        topRated: results[2],
      );
    } catch (e) {
      _movieProvider.setLoading(false);
      _movieProvider.setErrorMessage(e.toString().replaceAll("Exception: ", ""));
    }
  }
}
