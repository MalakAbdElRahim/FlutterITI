import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/WatchlistProvider.dart';
import '../Widgets/ListCardWidget.dart';
import 'WatchingScreen.dart';
import 'ToWatchScreen.dart';
import 'WatchedScreen.dart';

class WatchListScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final String title;

  const WatchListScreen({
    super.key,
    required this.title,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final watchlistProvider = context.watch<WatchlistProvider>();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Movie Lists',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Track movies you're watching, want to watch, or completed",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ListCardWidget(
              title: 'Currently Watching',
              description: 'Movies you are currently watching',
              count: watchlistProvider.watching.length,
              icon: Icons.play_circle_fill,
              color: Colors.blueAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WatchingScreen(
                    title: 'Currently Watching',
                    toggleTheme: toggleTheme,
                  ),
                ),
              ),
            ),
            ListCardWidget(
              title: 'Want to Watch',
              description: 'Movies saved to watch later',
              count: watchlistProvider.toWatch.length,
              icon: Icons.bookmark,
              color: Colors.orangeAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ToWatch(
                    title: 'Want to Watch',
                    toggleTheme: toggleTheme,
                  ),
                ),
              ),
            ),
            ListCardWidget(
              title: 'Watched',
              description: 'Movies you have completed',
              count: watchlistProvider.watched.length,
              icon: Icons.check_circle,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Watched(
                    title: 'Watched',
                    toggleTheme: toggleTheme,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
