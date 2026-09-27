import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Gestiona el tema de la app (oscuro/claro) y recuerda la elección del
/// usuario entre sesiones usando SharedPreferences.
class ThemeProvider extends ChangeNotifier {
  // Por defecto arrancamos en modo oscuro (estética Netflix).
  bool _isDark = true;
  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _load();
  }

  /// Carga la preferencia guardada al iniciar.
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(AppConstants.themePrefKey) ?? true;
      notifyListeners();
    } catch (_) {
      // Si falla la lectura, nos quedamos con el modo oscuro por defecto.
    }
  }

  /// Cambia entre oscuro y claro y guarda la nueva preferencia.
  Future<void> toggle() async {
    _isDark = !_isDark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themePrefKey, _isDark);
    } catch (_) {
      // Ignoramos errores de guardado: no es crítico.
    }
  }
}
