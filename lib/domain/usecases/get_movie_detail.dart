import '../entities/cast.dart';
import '../entities/movie_detail.dart';
import '../entities/video.dart';
import '../entities/watch_provider.dart';
import '../repositories/movie_repository.dart';

/// Agrupa toda la información de la pantalla de detalle en un solo objeto,
/// para que la UI la reciba de una vez.
class MovieDetailBundle {
  final MovieDetail detail;
  final List<CastMember> cast;
  final List<Video> videos;
  final WatchProviders providers;
  final bool isFavorite;

  const MovieDetailBundle({
    required this.detail,
    required this.cast,
    required this.videos,
    required this.providers,
    required this.isFavorite,
  });

  /// Devuelve el primer tráiler de YouTube disponible, o null si no hay.
  Video? get bestTrailer {
    final trailers = videos.where((v) => v.isYoutube).toList();
    if (trailers.isEmpty) return null;
    // Preferimos un "Trailer"; si no, cualquier vídeo de YouTube.
    return trailers.firstWhere(
      (v) => v.isTrailer,
      orElse: () => trailers.first,
    );
  }
}

/// Caso de uso: cargar TODO el detalle de una película en paralelo
/// (info + reparto + vídeos + dónde ver + estado de favorito).
class GetMovieDetail {
  final MovieRepository repository;
  const GetMovieDetail(this.repository);

  Future<MovieDetailBundle> call(int movieId) async {
    // Lanzamos las peticiones a la vez con Future.wait para que sea más rápido.
    final results = await Future.wait([
      repository.getMovieDetail(movieId),
      repository.getMovieCast(movieId),
      repository.getMovieVideos(movieId),
      repository.getWatchProviders(movieId),
      repository.isFavorite(movieId),
    ]);

    return MovieDetailBundle(
      detail: results[0] as MovieDetail,
      cast: results[1] as List<CastMember>,
      videos: results[2] as List<Video>,
      providers: results[3] as WatchProviders,
      isFavorite: results[4] as bool,
    );
  }
}
