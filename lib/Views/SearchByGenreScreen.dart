import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/GenreProvider.dart';
import '../Controller/GenreController.dart';
import '../Widgets/LoadingWidget.dart';
import '../Widgets/ErrorRetryWidget.dart';
import 'GenreMoviesScreen.dart';

class SearchByGenreScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const SearchByGenreScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GenreProvider(),
      child: _SearchByGenreView(toggleTheme: toggleTheme),
    );
  }
}

class _SearchByGenreView extends StatefulWidget {
  final VoidCallback toggleTheme;

  const _SearchByGenreView({required this.toggleTheme});

  @override
  State<_SearchByGenreView> createState() => _SearchByGenreViewState();
}

class _SearchByGenreViewState extends State<_SearchByGenreView> {
  late GenreController _controller;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<GenreProvider>(context, listen: false);
    _controller = GenreController(provider: provider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchGenres();
    });
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
    const colors = [
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
    final provider = context.watch<GenreProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search by Genre'),
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
                  onRetry: _controller.fetchGenres,
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select a Genre',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Browse movies by your favorite category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: provider.genres.length,
                          itemBuilder: (context, index) {
                            final genre = provider.genres[index];
                            final genreColor = _getGenreColor(index);
                            final genreIcon = _getGenreIcon(genre.name);

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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: genreColor.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(genreIcon, color: genreColor, size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        genre.name,
                                        style: const TextStyle(
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
                ),
    );
  }
}
