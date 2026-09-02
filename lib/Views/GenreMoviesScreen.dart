import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/GenreProvider.dart';
import '../Controller/GenreController.dart';
import '../Widgets/MovieGridView.dart';
import '../Widgets/LoadingWidget.dart';
import '../Widgets/ErrorRetryWidget.dart';
import '../Widgets/PaginationBar.dart';
import 'MovieDetailsScreen.dart';

class GenreMoviesScreen extends StatelessWidget {
  final int genreId;
  final String genreName;
  final VoidCallback toggleTheme;

  const GenreMoviesScreen({
    super.key,
    required this.genreId,
    required this.genreName,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GenreProvider(),
      child: _GenreMoviesView(
        genreId: genreId,
        genreName: genreName,
        toggleTheme: toggleTheme,
      ),
    );
  }
}

class _GenreMoviesView extends StatefulWidget {
  final int genreId;
  final String genreName;
  final VoidCallback toggleTheme;

  const _GenreMoviesView({
    required this.genreId,
    required this.genreName,
    required this.toggleTheme,
  });

  @override
  State<_GenreMoviesView> createState() => _GenreMoviesViewState();
}

class _GenreMoviesViewState extends State<_GenreMoviesView> {
  late GenreController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<GenreProvider>(context, listen: false);
    _controller = GenreController(provider: provider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchMoviesByGenre(widget.genreId, page: 1);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int page) async {
    await _controller.fetchMoviesByGenre(widget.genreId, page: page);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<GenreProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.genreName} Movies'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: provider.isLoading
          ? const LoadingWidget()
          : provider.errorMessage.isNotEmpty
              ? ErrorRetryWidget(
                  message: provider.errorMessage,
                  onRetry: () => _controller.fetchMoviesByGenre(
                    widget.genreId,
                    page: provider.currentPage,
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${provider.totalResults} movies',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Page ${provider.currentPage} of ${provider.totalPages}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: MovieGridView(
                        movies: provider.movies,
                        onMovieTap: (movie) {
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
                      ),
                    ),
                    if (provider.totalPages > 1)
                      PaginationBar(
                        currentPage: provider.currentPage,
                        totalPages: provider.totalPages,
                        onPrevious: provider.currentPage > 1
                            ? () => _goToPage(provider.currentPage - 1)
                            : null,
                        onNext: provider.currentPage < provider.totalPages
                            ? () => _goToPage(provider.currentPage + 1)
                            : null,
                      ),
                  ],
                ),
    );
  }
}
