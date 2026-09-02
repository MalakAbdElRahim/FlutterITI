import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/SearchProvider.dart';
import '../Controller/SearchController.dart' show MovieSearchController;
import '../Widgets/MovieGridView.dart';
import '../Widgets/LoadingWidget.dart';
import '../Widgets/ErrorRetryWidget.dart';
import '../Widgets/PaginationBar.dart';
import 'MovieDetailsScreen.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;
  final VoidCallback toggleTheme;

  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider(),
      child: _SearchResultsView(query: query, toggleTheme: toggleTheme),
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  final String query;
  final VoidCallback toggleTheme;

  const _SearchResultsView({required this.query, required this.toggleTheme});

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
  late MovieSearchController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SearchProvider>(context, listen: false);
    _controller = MovieSearchController(provider: provider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.search(widget.query, page: 1);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int page) async {
    await _controller.search(widget.query, page: page);
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
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Search: "${widget.query}"'),
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
                  onRetry: () => _controller.search(widget.query, page: provider.currentPage),
                )
              : provider.movies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'No movies found for "${widget.query}"',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${provider.totalResults} results found',
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
