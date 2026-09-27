import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/api_key_store.dart';

/// Gestiona la configuración de la app que persiste en el dispositivo.
/// Por ahora: la clave de API de TMDB que el usuario introduce dentro de la app.
class SettingsProvider extends ChangeNotifier {
  static const _apiKeyPref = 'tmdb_api_key';

  bool _loaded = false;
  bool get loaded => _loaded;

  /// True si ya hay una clave válida (introducida o quemada en el código).
  bool get hasKey => !ApiKeyStore.isMissing;

  /// Carga la clave guardada al arrancar la app.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_apiKeyPref);
      if (saved != null && saved.trim().isNotEmpty) {
        ApiKeyStore.runtimeKey = saved.trim();
      }
    } catch (_) {
      // Si falla la lectura, seguimos sin clave guardada.
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  /// Guarda una clave nueva introducida por el usuario y la activa.
  Future<void> saveApiKey(String key) async {
    final trimmed = key.trim();
    ApiKeyStore.runtimeKey = trimmed;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyPref, trimmed);
    } catch (_) {
      // Aunque falle el guardado, la clave queda activa en esta sesión.
    }
    notifyListeners();
  }
}
