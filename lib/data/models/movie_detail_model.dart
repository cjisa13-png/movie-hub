import '../../domain/entities/movie_detail.dart';
import 'genre_model.dart';

class MovieDetailModel extends MovieDetail {
  const MovieDetailModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.backdropPath,
    required super.voteAverage,
    required super.voteCount,
    required super.releaseDate,
    required super.genres,
    required super.runtime,
    required super.tagline,
    required super.status,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    final genresJson = (json['genres'] as List?) ?? const [];
    return MovieDetailModel(
      id: json['id'] as int,
      title: (json['title'] ?? json['original_title'] ?? 'Sin título') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      releaseDate: json['release_date'] as String?,
      genres: genresJson
          .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      runtime: (json['runtime'] as num?)?.toInt(),
      tagline: json['tagline'] as String?,
      status: (json['status'] ?? '') as String,
    );
  }
}
