import 'package:flutter/material.dart';
import '../Service/TMDBApiService.dart';
import '../Model/MovieModel.dart';
import '../Widgets/MovieCard.dart';
import 'MovieDetailsScreen.dart';

class GenreMoviesScreen extends StatefulWidget {
  final int genreId;
  final String genreName;
  final VoidCallback toggleTheme;

  GenreMoviesScreen({
    super.key,
    required this.genreId,
    required this.genreName,
    required this.toggleTheme,
  });

  @override
  State<GenreMoviesScreen> createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends State<GenreMoviesScreen> {
  final TMDBApiService _apiService = TMDBApiService();
  final ScrollController _scrollController = ScrollController();
  List<MovieModel> _movies = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalResults = 0;
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchGenreMovies(_currentPage);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchGenreMovies(int page) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final result = await _apiService.getMoviesByGenre(widget.genreId, page: page);
      setState(() {
        _movies = result["movies"] as List<MovieModel>;
        _currentPage = result["page"] as int;
        _totalPages = result["totalPages"] as int;
        _totalResults = result["totalResults"] as int;
        _isLoading = false;
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.genreName} Movies"),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 12),
                        Text(_errorMessage, textAlign: TextAlign.center),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _fetchGenreMovies(_currentPage),
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$_totalResults movies",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Page $_currentPage of $_totalPages",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(12),
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          childAspectRatio: 0.48,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return MovieCard(
                            movie: movie,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailsScreen(
                                    movie: movie,
                                    toggleTheme: widget.toggleTheme,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (_totalPages > 1)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _currentPage > 1
                                  ? () => _fetchGenreMovies(_currentPage - 1)
                                  : null,
                              icon: Icon(Icons.arrow_back, size: 16),
                              label: Text("Previous"),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "$_currentPage / $_totalPages",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _currentPage < _totalPages
                                  ? () => _fetchGenreMovies(_currentPage + 1)
                                  : null,
                              icon: Icon(Icons.arrow_forward, size: 16),
                              label: Text("Next"),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}
