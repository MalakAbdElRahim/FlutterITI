import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/WatchlistProvider.dart';
import '../Widgets/MovieGridView.dart';
import '../Widgets/EmptyStateWidget.dart';
import 'MovieDetailsScreen.dart';

class Favorites extends StatelessWidget {
  final VoidCallback toggleTheme;
  final String title;

  const Favorites({
    super.key,
    required this.title,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final watchlistProvider = context.watch<WatchlistProvider>();
    final movies = watchlistProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: toggleTheme,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: movies.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.favorite_outline,
              iconColor: Colors.redAccent,
              title: 'No Favorites Yet',
            )
          : MovieGridView(
              movies: movies,
              onMovieTap: (movie) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(
                    movie: movie,
                    toggleTheme: toggleTheme,
                  ),
                ),
              ),
            ),
    );
  }
}
