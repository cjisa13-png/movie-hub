import 'package:flutter/foundation.dart';

import '../../core/utils/failure.dart';
import '../../domain/usecases/get_movie_detail.dart';
import 'view_state.dart';

/// Estado de la pantalla de detalle de una película.
/// Carga en paralelo info + reparto + tráilers + dónde ver.
class DetailProvider extends ChangeNotifier {
  final GetMovieDetail _getMovieDetail;

  DetailProvider(this._getMovieDetail);

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  MovieDetailBundle? _bundle;
  MovieDetailBundle? get bundle => _bundle;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> load(int movieId) async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _bundle = await _getMovieDetail(movieId);
      _state = ViewState.loaded;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    } catch (_) {
      _errorMessage = 'No se pudo cargar el detalle de la película.';
      _state = ViewState.error;
    }
    notifyListeners();
  }
}
