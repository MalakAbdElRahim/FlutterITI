import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/WatchlistProvider.dart';
import '../Widgets/MovieGridView.dart';
import '../Widgets/EmptyStateWidget.dart';
import 'MovieDetailsScreen.dart';

class Watched extends StatelessWidget {
  final VoidCallback toggleTheme;
  final String title;

  const Watched({
    super.key,
    required this.title,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final watchlistProvider = context.watch<WatchlistProvider>();
    final movies = watchlistProvider.watched;

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
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
              title: 'No Watched Movies',
              subtitle: 'Movies you finish watching will appear here',
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
