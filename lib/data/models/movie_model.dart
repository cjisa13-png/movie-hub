import '../../domain/entities/movie.dart';

/// Modelo de datos de una película. Extiende la entidad [Movie] y añade
/// la conversión desde/hacia JSON (API de TMDB) y hacia/desde la base de
/// datos local (SQLite).
class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.backdropPath,
    required super.voteAverage,
    required super.voteCount,
    required super.releaseDate,
    required super.genreIds,
  });

  /// Crea un MovieModel a partir del JSON devuelto por la API de TMDB.
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: (json['title'] ?? json['original_title'] ?? 'Sin título') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List?)?.map((e) => e as int).toList() ??
          const [],
    );
  }

  /// Convierte el modelo en un Map para guardarlo en SQLite.
  /// (Los géneros se guardan como una cadena separada por comas.)
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds.join(','),
    };
  }

  /// Reconstruye un MovieModel desde una fila de la base de datos local.
  factory MovieModel.fromDbMap(Map<String, dynamic> map) {
    final rawGenres = (map['genre_ids'] as String?) ?? '';
    return MovieModel(
      id: map['id'] as int,
      title: map['title'] as String,
      overview: (map['overview'] as String?) ?? '',
      posterPath: map['poster_path'] as String?,
      backdropPath: map['backdrop_path'] as String?,
      voteAverage: (map['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: (map['vote_count'] as num?)?.toInt() ?? 0,
      releaseDate: map['release_date'] as String?,
      genreIds: rawGenres.isEmpty
          ? const []
          : rawGenres.split(',').map(int.parse).toList(),
    );
  }

  /// Crea un MovieModel a partir de una entidad Movie (para guardar favoritos).
  factory MovieModel.fromEntity(Movie movie) {
    return MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      releaseDate: movie.releaseDate,
      genreIds: movie.genreIds,
    );
  }
}
