import 'package:flutter/foundation.dart';

import '../../domain/entities/movie.dart';
import '../../domain/usecases/manage_favorites.dart';
import 'view_state.dart';

/// Estado de la Watchlist (favoritos locales). También expone el método
/// para alternar favoritos, que usan tanto la pantalla de detalle como las
/// tarjetas de película.
class FavoritesProvider extends ChangeNotifier {
  final ManageFavorites _manageFavorites;

  FavoritesProvider(this._manageFavorites);

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  List<Movie> _favorites = [];
  List<Movie> get favorites => _favorites;

  /// Conjunto de ids favoritos, para consultas rápidas (¿es favorita?).
  final Set<int> _favoriteIds = {};

  bool isFavorite(int movieId) => _favoriteIds.contains(movieId);

  Future<void> load() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _favorites = await _manageFavorites.getAll();
      _favoriteIds
        ..clear()
        ..addAll(_favorites.map((m) => m.id));
      _state = _favorites.isEmpty ? ViewState.empty : ViewState.loaded;
    } catch (_) {
      _state = ViewState.empty;
    }
    notifyListeners();
  }

  /// Añade o quita una película de favoritos. Actualiza la lista al vuelo.
  /// Devuelve el nuevo estado (true = ahora es favorita).
  Future<bool> toggle(Movie movie) async {
    final nowFavorite = await _manageFavorites.toggle(movie);

    if (nowFavorite) {
      _favoriteIds.add(movie.id);
      _favorites = [movie, ..._favorites.where((m) => m.id != movie.id)];
    } else {
      _favoriteIds.remove(movie.id);
      _favorites = _favorites.where((m) => m.id != movie.id).toList();
    }

    _state = _favorites.isEmpty ? ViewState.empty : ViewState.loaded;
    notifyListeners();
    return nowFavorite;
  }
}
