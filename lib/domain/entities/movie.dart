/// Entidad base de una película, tal como se usa en las listas
/// (tendencias, resultados de búsqueda, favoritos, grids...).
///
/// Las "entidades" del dominio no saben nada de JSON ni de la API:
/// son objetos puros de Dart. La conversión desde/hacia JSON vive en
/// la capa de datos (MovieModel).
class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genreIds,
  });

  /// Año de estreno como texto ("2024") o "—" si no está disponible.
  String get year {
    if (releaseDate == null || releaseDate!.isEmpty) return '—';
    return releaseDate!.split('-').first;
  }

  /// Valoración redondeada a un decimal (ej. 8.4).
  String get rating => voteAverage.toStringAsFixed(1);
}
