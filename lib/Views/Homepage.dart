import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Service/FirebaseAuthService.dart';
import '../Provider/MovieProvider.dart';
import '../Controller/MovieController.dart';
import '../Widgets/MovieSection.dart';
import 'FavoritesScreen.dart';
import 'WatchListScreen.dart';
import 'LoginScreen.dart';
import 'SearchResultsScreen.dart';
import 'SearchByGenreScreen.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String title;

  HomePage({super.key, required this.title, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _searchController = TextEditingController();
  late MovieController _movieController;

  @override
  void initState() {
    super.initState();
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    _movieController = MovieController(movieProvider: movieProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _movieController.fetchHomeMovies();
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(
            query: query,
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "One Tap Cinema",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.toggleTheme,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.logout_outlined),
          tooltip: 'Logout',
          onPressed: () async {
            await _authService.logOut();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(toggleTheme: widget.toggleTheme),
                ),
              );
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _movieController.fetchHomeMovies(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar & Filter Icon Row
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) => _performSearch(),
                          decoration: InputDecoration(
                            hintText: "Search movies...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              tooltip: 'Search',
                              onPressed: _performSearch,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.tune, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        tooltip: 'Search by Genre',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchByGenreScreen(toggleTheme: widget.toggleTheme),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Favorites(
                                title: "Favorites",
                                toggleTheme: widget.toggleTheme,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.favorite, size: 18),
                        label: Text("Favorites", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WatchListScreen(
                                title: "Watch Lists",
                                toggleTheme: widget.toggleTheme,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.list, size: 18),
                        label: Text("Watch List", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),

              if (movieProvider.isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              else if (movieProvider.errorMessage.isNotEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        SizedBox(height: 10),
                        Text(
                          movieProvider.errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _movieController.fetchHomeMovies(),
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                MovieSection(
                  title: "Popular Movies",
                  movies: movieProvider.popularMovies,
                  toggleTheme: widget.toggleTheme,
                ),
                MovieSection(
                  title: "Now Playing",
                  movies: movieProvider.nowPlayingMovies,
                  toggleTheme: widget.toggleTheme,
                ),
                MovieSection(
                  title: "Top Rated",
                  movies: movieProvider.topRatedMovies,
                  toggleTheme: widget.toggleTheme,
                ),
              ],

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

