import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// Caso de uso: buscar/descubrir películas aplicando filtros avanzados.
class SearchMovies {
  final MovieRepository repository;
  const SearchMovies(this.repository);

  Future<List<Movie>> call(MovieFilters filters) =>
      repository.searchMovies(filters);
}
