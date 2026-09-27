import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/usecases/get_genres.dart';
import '../../domain/usecases/search_movies.dart';
import 'view_state.dart';

/// Estado de la pantalla de búsqueda avanzada: texto + filtros.
class SearchProvider extends ChangeNotifier {
  final SearchMovies _searchMovies;
  final GetGenres _getGenres;

  SearchProvider(this._searchMovies, this._getGenres);

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  List<Movie> _results = [];
  List<Movie> get results => _results;

  List<Genre> _genres = [];
  List<Genre> get genres => _genres;

  MovieFilters _filters = const MovieFilters();
  MovieFilters get filters => _filters;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Timer? _debounce;

  /// Nº de filtros activos (para mostrar un badge en el botón de filtros).
  int get activeFilterCount {
    var count = 0;
    if (_filters.genreId != null) count++;
    if (_filters.year != null) count++;
    if (_filters.minRating != null) count++;
    if (_filters.platformId != null) count++;
    return count;
  }

  /// Carga los géneros una sola vez (para el selector de filtros).
  Future<void> loadGenres() async {
    if (_genres.isNotEmpty) return;
    try {
      _genres = await _getGenres();
      notifyListeners();
    } catch (_) {
      // No es crítico: si fallan los géneros, el resto de la búsqueda funciona.
    }
  }

  /// Se llama al escribir en el buscador. Usa "debounce" para no lanzar una
  /// petición en cada tecla, sino 500 ms después de dejar de escribir.
  void onQueryChanged(String query) {
    _filters = _filters.copyWith(query: query, page: 1);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _run();
    });
    notifyListeners();
  }

  /// Aplica un conjunto nuevo de filtros (desde el panel de filtros).
  void applyFilters(MovieFilters newFilters) {
    _filters = newFilters.copyWith(query: _filters.query, page: 1);
    _run();
  }

  /// Borra todos los filtros (mantiene el texto de búsqueda si lo hay).
  void clearFilters() {
    _filters = MovieFilters(query: _filters.query);
    _run();
  }

  Future<void> _run() async {
    // Si no hay ni texto ni filtros, volvemos al estado inicial.
    if (_filters.isEmpty) {
      _results = [];
      _state = ViewState.initial;
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();

    try {
      _results = await _searchMovies(_filters);
      _state = _results.isEmpty ? ViewState.empty : ViewState.loaded;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado.';
      _state = ViewState.error;
    }
    notifyListeners();
  }

  /// Reintenta la última búsqueda (botón "Reintentar").
  Future<void> retry() => _run();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
