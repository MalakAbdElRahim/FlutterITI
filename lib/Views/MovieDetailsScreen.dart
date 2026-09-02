import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/MovieModel.dart';
import '../Model/CastModel.dart';
import '../Provider/MovieDetailsProvider.dart';
import '../Provider/WatchlistProvider.dart';
import '../Controller/MovieDetailsController.dart';
import '../Widgets/ActionButtonWidget.dart';
import '../Widgets/CastCardWidget.dart';
import '../Widgets/LoadingWidget.dart';

class MovieDetailsScreen extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback toggleTheme;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieDetailsProvider(),
      child: _MovieDetailsView(movie: movie, toggleTheme: toggleTheme),
    );
  }
}

class _MovieDetailsView extends StatefulWidget {
  final MovieModel movie;
  final VoidCallback toggleTheme;

  const _MovieDetailsView({required this.movie, required this.toggleTheme});

  @override
  State<_MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends State<_MovieDetailsView> {
  late MovieDetailsController _controller;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MovieDetailsProvider>(context, listen: false);
    _controller = MovieDetailsController(provider: provider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchDetails(widget.movie.id);
    });
  }

  Future<void> _searchOnline(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.google.com/search?q=$encodedQuery');
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
            content: Text('Could not open browser: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatCurrency(num amount) {
    if (amount <= 0) return 'N/A';
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
    return '\$${buffer.toString().split('').reversed.join('')}';
  }

  String _formatRuntime(int? minutes) {
    if (minutes == null || minutes <= 0) return 'N/A';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final detailsProvider = context.watch<MovieDetailsProvider>();
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
              icon: const Icon(Icons.arrow_back),
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
            child: detailsProvider.isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: LoadingWidget(),
                  )
                : detailsProvider.errorMessage.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 12),
                            Text(detailsProvider.errorMessage, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _controller.fetchDetails(widget.movie.id),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _buildDetails(
                        context,
                        detailsProvider.details,
                        watchlistProvider,
                        isFav,
                        isWatching,
                        isToWatch,
                        isWatched,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    Map<String, dynamic> details,
    WatchlistProvider watchlistProvider,
    bool isFav,
    bool isWatching,
    bool isToWatch,
    bool isWatched,
  ) {
    final credits = details['credits'] != null
        ? CastModel.fromJson(details['credits'])
        : null;
    final castList = credits?.cast ?? [];
    final crewList = credits?.crew ?? [];
    final directors = crewList
        .where((c) => c.job == 'Director')
        .map((c) => c.name)
        .toList();

    final genres = (details['genres'] as List<dynamic>?)
            ?.map((g) => g['name'] as String)
            .toList() ??
        [];

    final runtime = details['runtime'] as int?;
    final tagline = (details['tagline'] as String?) ?? '';
    final budget = details['budget'] as num? ?? 0;
    final revenue = details['revenue'] as num? ?? 0;
    final status = (details['status'] as String?) ?? 'Released';
    final voteCount = details['vote_count'] as num? ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 4),
              Text(
                '${widget.movie.voteAverage.toStringAsFixed(1)} / 10',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              if (voteCount > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '($voteCount)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text(_formatRuntime(runtime), style: const TextStyle(fontSize: 13)),
              const Spacer(),
              if (widget.movie.originalLanguage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

          const SizedBox(height: 16),
          Row(
            children: [
              ActionButtonWidget(
                label: 'Favorite',
                icon: isFav ? Icons.favorite : Icons.favorite_border,
                isActive: isFav,
                activeColor: Colors.red,
                onTap: () async {
                  final added = await watchlistProvider.toggleFavorite(widget.movie);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(added ? 'Added to Favorites' : 'Removed from Favorites'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              ActionButtonWidget(
                label: 'Watching',
                icon: isWatching ? Icons.play_circle_fill : Icons.play_circle_outline,
                isActive: isWatching,
                activeColor: Colors.blueAccent,
                onTap: () async {
                  final added = await watchlistProvider.toggleWatching(widget.movie);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(added
                            ? 'Added to Currently Watching'
                            : 'Removed from Currently Watching'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              ActionButtonWidget(
                label: 'To Watch',
                icon: isToWatch ? Icons.bookmark : Icons.bookmark_border,
                isActive: isToWatch,
                activeColor: Colors.orangeAccent,
                onTap: () async {
                  final added = await watchlistProvider.toggleToWatch(widget.movie);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(added
                            ? 'Added to Want to Watch'
                            : 'Removed from Want to Watch'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              ActionButtonWidget(
                label: 'Watched',
                icon: isWatched ? Icons.check_circle : Icons.check_circle_outline,
                isActive: isWatched,
                activeColor: Colors.green,
                onTap: () async {
                  final added = await watchlistProvider.toggleWatched(widget.movie);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(added ? 'Marked as Watched' : 'Removed from Watched'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          if (tagline.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              '"$tagline"',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 15,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (genres.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: genres.map((genreName) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    genreName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 20),

          const Text(
            'Storyline',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.movie.overview.isNotEmpty
                ? widget.movie.overview
                : 'No overview available for this movie.',
            style: TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),

          if (castList.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Top Cast',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: castList.length > 15 ? 15 : castList.length,
                itemBuilder: (context, index) => CastCardWidget(actor: castList[index]),
              ),
            ),
          ],
          if (directors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Directed by: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Expanded(
                  child: Text(
                    directors.join(', '),
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

          const SizedBox(height: 20),
          const Text(
            'Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Release Date',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    Text(widget.movie.fullReleaseDate,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Budget',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    Text(_formatCurrency(budget),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Revenue',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    Text(_formatCurrency(revenue),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _searchOnline('${widget.movie.title} trigger warnings'),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text(
                    'Trigger Warning',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _searchOnline('${widget.movie.title} parents guide'),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text(
                    'Parent Guide',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
