import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/movie_repository.dart' show MovieFilters;
import '../models/cast_model.dart';
import '../models/genre_model.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_model.dart';
import '../models/video_model.dart';
import '../models/watch_provider_model.dart';

/// =============================================================================
///  MovieService
/// =============================================================================
///  Clase central que gestiona TODAS las llamadas a la API de TMDB.
///  Cada método corresponde a un endpoint y devuelve modelos ya parseados.
///
///  Usa el [ApiClient], que se encarga de añadir la api_key, el idioma y de
///  gestionar los errores de red de forma uniforme.
/// =============================================================================
class MovieService {
  final ApiClient _client;

  MovieService(this._client);

  /// Películas en tendencia de la semana.
  Future<List<MovieModel>> getTrending() async {
    final json = await _client.get(ApiConstants.trending);
    return _parseMovieList(json);
  }

  /// Búsqueda avanzada.
  /// - Si hay texto (query): usa el endpoint /search/movie.
  /// - Si solo hay filtros (género, año, plataforma, nota): usa /discover/movie,
  ///   que permite filtrar y ordenar por popularidad.
  Future<List<MovieModel>> searchMovies(MovieFilters filters) async {
    final hasQuery = filters.query != null && filters.query!.trim().isNotEmpty;

    if (hasQuery) {
      return _searchByText(filters);
    } else {
      return _discover(filters);
    }
  }

  Future<List<MovieModel>> _searchByText(MovieFilters filters) async {
    final params = <String, String>{
      'query': filters.query!.trim(),
      'page': '${filters.page}',
      'include_adult': 'false',
    };
    if (filters.year != null) {
      params['primary_release_year'] = '${filters.year}';
    }

    final json = await _client.get(ApiConstants.searchMovie, queryParams: params);
    var movies = _parseMovieList(json);

    // /search no admite filtrar por género/nota/plataforma en el servidor,
    // así que aplicamos esos filtros localmente sobre los resultados.
    movies = _applyClientSideFilters(movies, filters);
    return movies;
  }

  Future<List<MovieModel>> _discover(MovieFilters filters) async {
    final params = <String, String>{
      'sort_by': 'popularity.desc',
      'page': '${filters.page}',
      'include_adult': 'false',
      'vote_count.gte': '50', // Evita películas con casi cero votos
    };
    if (filters.genreId != null) {
      params['with_genres'] = '${filters.genreId}';
    }
    if (filters.year != null) {
      params['primary_release_year'] = '${filters.year}';
    }
    if (filters.minRating != null) {
      params['vote_average.gte'] = '${filters.minRating}';
    }
    if (filters.platformId != null) {
      // Filtra por plataforma disponible en la región configurada.
      params['with_watch_providers'] = '${filters.platformId}';
      params['watch_region'] = ApiConstants.watchRegion;
    }

    final json = await _client.get(ApiConstants.discoverMovie, queryParams: params);
    return _parseMovieList(json);
  }

  /// Detalle completo de una película.
  Future<MovieDetailModel> getMovieDetail(int id) async {
    final json = await _client.get(ApiConstants.movieDetail(id));
    return MovieDetailModel.fromJson(json);
  }

  /// Reparto principal (créditos).
  Future<List<CastModel>> getMovieCast(int id) async {
    final json = await _client.get(ApiConstants.movieCredits(id));
    final cast = (json['cast'] as List?) ?? const [];
    return cast
        .map((e) => CastModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Vídeos (tráilers) de la película.
  /// Pide primero en el idioma configurado; si no hay ninguno, reintenta en
  /// inglés (muchas películas solo tienen tráiler en en-US).
  Future<List<VideoModel>> getMovieVideos(int id) async {
    Future<List<VideoModel>> fetch(String lang) async {
      final json = await _client.get(
        ApiConstants.movieVideos(id),
        queryParams: {'language': lang},
      );
      final results = (json['results'] as List?) ?? const [];
      return results
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    var videos = await fetch(ApiConstants.language);
    if (videos.where((v) => v.isYoutube).isEmpty) {
      videos = await fetch('en-US');
    }
    return videos;
  }

  /// Plataformas donde ver la película ("Where to Watch"), para la región
  /// configurada en ApiConstants.watchRegion.
  Future<WatchProvidersModel> getWatchProviders(int id) async {
    final json = await _client.get(ApiConstants.watchProviders(id));
    return WatchProvidersModel.fromJson(json, ApiConstants.watchRegion);
  }

  /// Lista de géneros oficiales de TMDB.
  Future<List<GenreModel>> getGenres() async {
    final json = await _client.get(ApiConstants.genreList);
    final genres = (json['genres'] as List?) ?? const [];
    return genres
        .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- Helpers privados ---

  List<MovieModel> _parseMovieList(Map<String, dynamic> json) {
    final results = (json['results'] as List?) ?? const [];
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .where((m) => m.posterPath != null) // Solo las que tienen póster
        .toList();
  }

  /// Aplica filtros que /search no soporta en servidor (género y nota mínima).
  List<MovieModel> _applyClientSideFilters(
    List<MovieModel> movies,
    MovieFilters filters,
  ) {
    return movies.where((m) {
      if (filters.genreId != null && !m.genreIds.contains(filters.genreId)) {
        return false;
      }
      if (filters.minRating != null && m.voteAverage < filters.minRating!) {
        return false;
      }
      return true;
    }).toList();
  }
}
