import '../../domain/entities/cast.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/watch_provider.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../datasources/movie_service.dart';
import '../models/movie_model.dart';

/// Implementación concreta del [MovieRepository].
///
/// Orquesta las dos fuentes de datos:
///   - [MovieService]  -> datos remotos (API de TMDB)
///   - [FavoritesLocalDataSource] -> datos locales (SQLite)
///
/// La UI nunca habla con estas fuentes directamente: siempre pasa por aquí.
class MovieRepositoryImpl implements MovieRepository {
  final MovieService remote;
  final FavoritesLocalDataSource local;

  MovieRepositoryImpl({required this.remote, required this.local});

  @override
  Future<List<Movie>> getTrending() => remote.getTrending();

  @override
  Future<List<Movie>> searchMovies(MovieFilters filters) =>
      remote.searchMovies(filters);

  @override
  Future<MovieDetail> getMovieDetail(int id) => remote.getMovieDetail(id);

  @override
  Future<List<CastMember>> getMovieCast(int id) => remote.getMovieCast(id);

  @override
  Future<List<Video>> getMovieVideos(int id) => remote.getMovieVideos(id);

  @override
  Future<WatchProviders> getWatchProviders(int id) =>
      remote.getWatchProviders(id);

  @override
  Future<List<Genre>> getGenres() => remote.getGenres();

  // --- Favoritos (locales) ---

  @override
  Future<List<Movie>> getFavorites() => local.getAll();

  @override
  Future<void> addFavorite(Movie movie) =>
      local.add(MovieModel.fromEntity(movie));

  @override
  Future<void> removeFavorite(int movieId) => local.remove(movieId);

  @override
  Future<bool> isFavorite(int movieId) => local.isFavorite(movieId);
}
