import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Service/FirebaseAuthService.dart';
import '../Provider/WatchlistProvider.dart';
import '../Widgets/MovieCard.dart';
import 'MovieDetailsScreen.dart';
import 'LoginScreen.dart';

class Watched extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String title;

  Watched({
    super.key,
    required this.title,
    required this.toggleTheme,
  });

  @override
  State<Watched> createState() => _WatchedState();
}

class _WatchedState extends State<Watched> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final watchlistProvider = context.watch<WatchlistProvider>();
    final movies = watchlistProvider.watched;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.toggleTheme,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: movies.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    "No Watched Movies",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Movies you finish watching will appear here",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(12),
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                childAspectRatio: 0.48,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
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
    );
  }
}
