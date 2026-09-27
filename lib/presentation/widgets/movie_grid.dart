import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';
import 'movie_card.dart';

/// Rejilla (grid) responsiva de pósters. El número de columnas se ajusta
/// automáticamente al ancho de la pantalla (más columnas en tablets).
class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const MovieGrid({
    super.key,
    required this.movies,
    this.padding = const EdgeInsets.all(16),
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculamos columnas según el ancho disponible (~150px por póster).
        final width = constraints.maxWidth;
        final crossAxisCount = (width / 160).floor().clamp(2, 6);

        return GridView.builder(
          padding: padding,
          physics: physics,
          shrinkWrap: shrinkWrap,
          itemCount: movies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
            // Alto = póster (1.5) + espacio para el texto.
            childAspectRatio: 0.52,
          ),
          itemBuilder: (context, index) {
            // width infinito: la tarjeta ocupa toda la celda del grid.
            return MovieCard(movie: movies[index], width: double.infinity);
          },
        );
      },
    );
  }
}
