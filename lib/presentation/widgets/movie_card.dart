import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../domain/entities/movie.dart';
import '../screens/detail_screen.dart';
import 'poster_image.dart';
import 'rating_badge.dart';

/// Tarjeta vertical de película (póster + título + año), usada en grids
/// y carruseles. Al pulsarla, navega al detalle.
///
/// - En un carrusel: se le pasa un [width] fijo (ej. 140).
/// - En un grid: se le pasa `width: double.infinity` y la tarjeta rellena
///   la celda; el póster ocupa el alto disponible (ratio 2:3) gracias a
///   Expanded, evitando cálculos de alto infinito.
class MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;

  const MovieCard({super.key, required this.movie, this.width = 140});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finiteWidth = width.isFinite;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              DetailScreen(movieId: movie.id, heroTag: 'poster_${movie.id}'),
        ),
      ),
      child: SizedBox(
        width: finiteWidth ? width : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // El póster ocupa el alto disponible manteniendo el ratio 2:3.
            Expanded(
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: 'poster_${movie.id}',
                        child: PosterImage(
                          url: ApiConstants.posterUrl(movie.posterPath),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: RatingBadge(rating: movie.voteAverage),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge,
            ),
            Text(movie.year, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
