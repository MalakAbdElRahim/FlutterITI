import 'package:flutter/material.dart';
import '../Service/TMDBApiService.dart';
import '../Model/GenreModel.dart';
import 'GenreMoviesScreen.dart';

class SearchByGenreScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  SearchByGenreScreen({
    super.key,
    required this.toggleTheme,
  });

  @override
  State<SearchByGenreScreen> createState() => _SearchByGenreScreenState();
}

class _SearchByGenreScreenState extends State<SearchByGenreScreen> {
  final TMDBApiService _apiService = TMDBApiService();
  late Future<List<Genre>> _genresFuture;

  @override
  void initState() {
    super.initState();
    _genresFuture = _apiService.getGenres();
  }

  IconData _getGenreIcon(String name) {
    switch (name.toLowerCase()) {
      case 'action':
        return Icons.local_fire_department;
      case 'adventure':
        return Icons.explore;
      case 'animation':
        return Icons.color_lens;
      case 'comedy':
        return Icons.sentiment_very_satisfied;
      case 'crime':
        return Icons.fingerprint;
      case 'documentary':
        return Icons.videocam;
      case 'drama':
        return Icons.theater_comedy;
      case 'family':
        return Icons.family_restroom;
      case 'fantasy':
        return Icons.auto_awesome;
      case 'history':
        return Icons.menu_book;
      case 'horror':
        return Icons.nightlight_round;
      case 'music':
        return Icons.music_note;
      case 'mystery':
        return Icons.search;
      case 'romance':
        return Icons.favorite;
      case 'science fiction':
      case 'sci-fi':
        return Icons.rocket_launch;
      case 'tv movie':
        return Icons.tv;
      case 'thriller':
        return Icons.bolt;
      case 'war':
        return Icons.shield;
      case 'western':
        return Icons.terrain;
      default:
        return Icons.movie;
    }
  }

  Color _getGenreColor(int index) {
    final colors = [
      Colors.orange,
      Colors.green,
      Colors.pink,
      Colors.amber,
      Colors.blueGrey,
      Colors.teal,
      Colors.purple,
      Colors.cyan,
      Colors.indigo,
      Colors.brown,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.blue,
      Colors.red,
      Colors.lightBlue,
      Colors.lime,
      Colors.yellow,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Search by Genre"),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: FutureBuilder<List<Genre>>(
        future: _genresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 12),
                  Text("Failed to load genres"),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _genresFuture = _apiService.getGenres();
                      });
                    },
                    child: Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final genres = snapshot.data ?? [];

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select a Genre",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Browse movies by your favorite category",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: genres.length,
                    itemBuilder: (context, index) {
                      final genre = genres[index];
                      final Color genreColor = _getGenreColor(index);
                      final IconData genreIcon = _getGenreIcon(genre.name);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenreMoviesScreen(
                                genreId: genre.id,
                                genreName: genre.name,
                                toggleTheme: widget.toggleTheme,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: genreColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: genreColor.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: genreColor.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  genreIcon,
                                  color: genreColor,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  genre.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
