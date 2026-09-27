import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// Caso de uso: gestionar la Watchlist (favoritos guardados localmente).
/// Reúne las operaciones de leer / añadir / quitar / alternar favoritos.
class ManageFavorites {
  final MovieRepository repository;
  const ManageFavorites(this.repository);

  Future<List<Movie>> getAll() => repository.getFavorites();

  Future<void> add(Movie movie) => repository.addFavorite(movie);

  Future<void> remove(int movieId) => repository.removeFavorite(movieId);

  Future<bool> isFavorite(int movieId) => repository.isFavorite(movieId);

  /// Alterna el estado: si ya es favorita la quita, si no, la añade.
  /// Devuelve el nuevo estado (true = ahora es favorita).
  Future<bool> toggle(Movie movie) async {
    final already = await repository.isFavorite(movie.id);
    if (already) {
      await repository.removeFavorite(movie.id);
      return false;
    } else {
      await repository.addFavorite(movie);
      return true;
    }
  }
}
