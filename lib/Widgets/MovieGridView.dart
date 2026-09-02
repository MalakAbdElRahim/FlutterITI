import 'package:flutter/material.dart';
import '../Model/MovieModel.dart';
import 'MovieCard.dart';

class MovieGridView extends StatelessWidget {
  final List<MovieModel> movies;
  final void Function(MovieModel movie) onMovieTap;

  const MovieGridView({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
          onTap: () => onMovieTap(movie),
        );
      },
    );
  }
}
