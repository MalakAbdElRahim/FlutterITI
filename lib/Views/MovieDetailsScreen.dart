import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/MovieModel.dart';
import '../Model/CastModel.dart';
import '../Service/TMDBApiService.dart';
import '../Provider/WatchlistProvider.dart';

class MovieDetailsScreen extends StatefulWidget {
  final MovieModel movie;
  final VoidCallback toggleTheme;

  MovieDetailsScreen({
    super.key,
    required this.movie,
    required this.toggleTheme,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final TMDBApiService _apiService = TMDBApiService();
  late Future<Map<String, dynamic>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _apiService.getMovieDetailsFull(widget.movie.id);
  }

  Future<void> _searchOnline(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse("https://www.google.com/search?q=$encodedQuery");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open browser: $e"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatCurrency(num amount) {
    if (amount <= 0) return "N/A";
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    return "\$${buffer.toString().split('').reversed.join('')}";
  }

  String _formatRuntime(int? minutes) {
    if (minutes == null || minutes <= 0) return "N/A";
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return "${hours}h ${mins}m";
    }
    return "${mins}m";
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.18)
                : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? activeColor
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? activeColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCastCard(Cast actor) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 75,
              height: 75,
              color: Theme.of(context).colorScheme.tertiary,
              child: Image.network(
                actor.fullProfilePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(
            actor.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 2),
          Text(
            actor.character ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final watchlistProvider = context.watch<WatchlistProvider>();

    final isFav = watchlistProvider.isFavorite(widget.movie.id);
    final isWatching = watchlistProvider.isWatching(widget.movie.id);
    final isToWatch = watchlistProvider.isToWatch(widget.movie.id);
    final isWatched = watchlistProvider.isWatched(widget.movie.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Toggle Theme',
                onPressed: widget.toggleTheme,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.movie.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.movie.fullBackdropPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _detailsFuture,
              builder: (context, snapshot) {
                final details = snapshot.data ?? {};
                final credits = details["credits"] != null
                    ? CastModel.fromJson(details["credits"])
                    : null;
                final castList = credits?.cast ?? [];
                final crewList = credits?.crew ?? [];
                final directors = crewList
                    .where((c) => c.job == "Director")
                    .map((c) => c.name)
                    .toList();

                final genres = (details["genres"] as List<dynamic>?)
                        ?.map((g) => g["name"] as String)
                        .toList() ??
                    [];

                final runtime = details["runtime"] as int?;
                final tagline = (details["tagline"] as String?) ?? "";
                final budget = details["budget"] as num? ?? 0;
                final revenue = details["revenue"] as num? ?? 0;
                final status = (details["status"] as String?) ?? "Released";
                final voteCount = details["vote_count"] as num? ?? 0;

                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                          SizedBox(width: 4),
                          Text(
                            "${widget.movie.voteAverage.toStringAsFixed(1)} / 10",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (voteCount > 0) ...[
                            SizedBox(width: 4),
                            Text(
                              "($voteCount)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                          SizedBox(width: 16),
                          Icon(Icons.access_time, size: 16),
                          SizedBox(width: 4),
                          Text(
                            _formatRuntime(runtime),
                            style: TextStyle(fontSize: 13),
                          ),
                          Spacer(),
                          if (widget.movie.originalLanguage.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.movie.originalLanguage.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 16),
                      Row(
                        children: [
                          _buildActionButton(
                            context: context,
                            label: "Favorite",
                            icon: isFav ? Icons.favorite : Icons.favorite_border,
                            isActive: isFav,
                            activeColor: Colors.red,
                            onTap: () async {
                              final added = await watchlistProvider.toggleFavorite(widget.movie);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(added
                                        ? "Added to Favorites"
                                        : "Removed from Favorites"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(width: 8),
                          _buildActionButton(
                            context: context,
                            label: "Watching",
                            icon: isWatching ? Icons.play_circle_fill : Icons.play_circle_outline,
                            isActive: isWatching,
                            activeColor: Colors.blueAccent,
                            onTap: () async {
                              final added = await watchlistProvider.toggleWatching(widget.movie);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(added
                                        ? "Added to Currently Watching"
                                        : "Removed from Currently Watching"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(width: 8),
                          _buildActionButton(
                            context: context,
                            label: "To Watch",
                            icon: isToWatch ? Icons.bookmark : Icons.bookmark_border,
                            isActive: isToWatch,
                            activeColor: Colors.orangeAccent,
                            onTap: () async {
                              final added = await watchlistProvider.toggleToWatch(widget.movie);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(added
                                        ? "Added to Want to Watch"
                                        : "Removed from Want to Watch"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(width: 8),
                          _buildActionButton(
                            context: context,
                            label: "Watched",
                            icon: isWatched ? Icons.check_circle : Icons.check_circle_outline,
                            isActive: isWatched,
                            activeColor: Colors.green,
                            onTap: () async {
                              final added = await watchlistProvider.toggleWatched(widget.movie);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(added
                                        ? "Marked as Watched"
                                        : "Removed from Watched"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      if (tagline.isNotEmpty) ...[
                        SizedBox(height: 18),
                        Text(
                          "\"$tagline\"",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (genres.isNotEmpty) ...[
                        SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: genres.map((genreName) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                genreName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      SizedBox(height: 20),

                      // Storyline / Overview
                      Text(
                        "Storyline",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.movie.overview.isNotEmpty
                            ? widget.movie.overview
                            : "No overview available for this movie.",
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.6,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),

                      // Cast Section
                      if (castList.isNotEmpty) ...[
                        SizedBox(height: 24),
                        Text(
                          "Top Cast",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          height: 130,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            itemCount: castList.length > 15 ? 15 : castList.length,
                            itemBuilder: (context, index) {
                              return _buildCastCard(castList[index]);
                            },
                          ),
                        ),
                      ],
                      if (directors.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Directed by: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                directors.join(", "),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: 20),
                      Text(
                        "Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Release Date", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                                Text(widget.movie.fullReleaseDate, style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Status", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                                Text(status, style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Budget", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                                Text(_formatCurrency(budget), style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Revenue", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                                Text(_formatCurrency(revenue), style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _searchOnline("${widget.movie.title} trigger warnings"),
                              icon: Icon(Icons.search, size: 18),
                              label: Text(
                                "Trigger Warning",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _searchOnline("${widget.movie.title} parents guide"),
                              icon: Icon(Icons.search, size: 18),
                              label: Text(
                                "Parent Guide",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
