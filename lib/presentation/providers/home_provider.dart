import 'package:flutter/foundation.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_trending_movies.dart';
import 'view_state.dart';

/// Estado de la pantalla de inicio (Home): películas en tendencia.
class HomeProvider extends ChangeNotifier {
  final GetTrendingMovies _getTrending;

  HomeProvider(this._getTrending);

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// La película destacada (primera de la lista) para el "hero" superior.
  Movie? get featured => _movies.isEmpty ? null : _movies.first;

  /// El resto de películas, para el carrusel/grid.
  List<Movie> get rest =>
      _movies.length > 1 ? _movies.sublist(1) : const [];

  Future<void> load() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _movies = await _getTrending();
      _state = _movies.isEmpty ? ViewState.empty : ViewState.loaded;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado.';
      _state = ViewState.error;
    }
    notifyListeners();
  }
}
