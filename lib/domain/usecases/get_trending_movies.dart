import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

/// Caso de uso: obtener las películas en tendencia de la semana.
/// Un "caso de uso" encapsula una única acción del negocio y delega
/// en el repositorio. Mantiene la lógica de la app separada de la UI.
class GetTrendingMovies {
  final MovieRepository repository;
  const GetTrendingMovies(this.repository);

  Future<List<Movie>> call() => repository.getTrending();
}
