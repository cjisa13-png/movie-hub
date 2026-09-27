import '../entities/genre.dart';
import '../repositories/movie_repository.dart';

/// Caso de uso: obtener la lista de géneros (para el filtro de búsqueda).
class GetGenres {
  final MovieRepository repository;
  const GetGenres(this.repository);

  Future<List<Genre>> call() => repository.getGenres();
}
