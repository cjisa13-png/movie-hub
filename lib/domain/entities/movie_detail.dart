import 'genre.dart';

/// Información detallada de una película (pantalla de detalle).
/// Amplía los datos básicos de [Movie] con géneros, duración, etc.
class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<Genre> genres;
  final int? runtime; // Duración en minutos
  final String? tagline; // Frase promocional
  final String status;

  const MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genres,
    required this.runtime,
    required this.tagline,
    required this.status,
  });

  String get year {
    if (releaseDate == null || releaseDate!.isEmpty) return '—';
    return releaseDate!.split('-').first;
  }

  String get rating => voteAverage.toStringAsFixed(1);

  /// Duración formateada como "2h 15min".
  String get formattedRuntime {
    if (runtime == null || runtime == 0) return '—';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    if (h == 0) return '${m}min';
    return '${h}h ${m}min';
  }
}
