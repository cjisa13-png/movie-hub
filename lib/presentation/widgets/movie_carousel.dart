import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';
import 'movie_card.dart';

/// Carrusel horizontal de pósters con un título de sección encima.
/// Estilo "fila de Netflix".
class MovieCarousel extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final double cardWidth;

  const MovieCarousel({
    super.key,
    required this.title,
    required this.movies,
    this.cardWidth = 130,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    // Alto de la fila = póster (ratio 2:3) + texto (título y año).
    final rowHeight = cardWidth * 1.5 + 48;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(title, style: theme.textTheme.titleLarge),
        ),
        SizedBox(
          height: rowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => MovieCard(movie: movies[i], width: cardWidth),
          ),
        ),
      ],
    );
  }
}
