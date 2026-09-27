import '../entities/cast.dart';
import '../entities/genre.dart';
import '../entities/movie.dart';
import '../entities/movie_detail.dart';
import '../entities/video.dart';
import '../entities/watch_provider.dart';

/// Filtros aplicables en la búsqueda avanzada.
class MovieFilters {
  final String? query; // Texto de búsqueda por título
  final int? genreId; // Género
  final int? year; // Año de estreno
  final double? minRating; // Valoración mínima (0-10)
  final int? platformId; // Plataforma de streaming (watch provider)
  final int page;

  const MovieFilters({
    this.query,
    this.genreId,
    this.year,
    this.minRating,
    this.platformId,
    this.page = 1,
  });

  /// True si no hay ningún criterio (útil para decidir qué endpoint usar).
  bool get isEmpty =>
      (query == null || query!.trim().isEmpty) &&
      genreId == null &&
      year == null &&
      minRating == null &&
      platformId == null;

  MovieFilters copyWith({
    String? query,
    int? genreId,
    int? year,
    double? minRating,
    int? platformId,
    int? page,
    bool clearGenre = false,
    bool clearYear = false,
    bool clearRating = false,
    bool clearPlatform = false,
  }) {
    return MovieFilters(
      query: query ?? this.query,
      genreId: clearGenre ? null : (genreId ?? this.genreId),
      year: clearYear ? null : (year ?? this.year),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      platformId: clearPlatform ? null : (platformId ?? this.platformId),
      page: page ?? this.page,
    );
  }
}

/// Contrato del repositorio de películas.
/// La capa de presentación depende de esta abstracción, NO de la
/// implementación concreta (que vive en /data). Así se cumple la
/// inversión de dependencias de Clean Architecture.
abstract class MovieRepository {
  Future<List<Movie>> getTrending();

  /// Busca/descubre películas según los [filters].
  /// Si hay texto de búsqueda usa /search; si solo hay filtros usa /discover.
  Future<List<Movie>> searchMovies(MovieFilters filters);

  Future<MovieDetail> getMovieDetail(int id);

  Future<List<CastMember>> getMovieCast(int id);

  Future<List<Video>> getMovieVideos(int id);

  Future<WatchProviders> getWatchProviders(int id);

  Future<List<Genre>> getGenres();

  // --- Favoritos (Watchlist) locales ---
  Future<List<Movie>> getFavorites();
  Future<void> addFavorite(Movie movie);
  Future<void> removeFavorite(int movieId);
  Future<bool> isFavorite(int movieId);
}
