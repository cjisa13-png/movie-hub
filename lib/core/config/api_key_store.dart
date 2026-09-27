import '../constants/api_constants.dart';

/// Almacén global de la clave de API de TMDB.
///
/// La clave puede venir de dos sitios:
///   1. `runtimeKey`  -> la que el usuario escribe DENTRO de la app (se guarda
///      en el dispositivo con SharedPreferences). Tiene prioridad.
///   2. `ApiConstants.apiKey` -> la que se deja "quemada" en el código
///      (opcional, para desarrolladores).
///
/// Gracias a esto, el mismo .apk sirve para cualquier persona: cada uno pega
/// su propia clave al abrir la app, sin necesidad de recompilar.
class ApiKeyStore {
  ApiKeyStore._();

  /// Clave introducida por el usuario en tiempo de ejecución.
  static String? runtimeKey;

  /// Clave que se usará realmente en las peticiones.
  static String get effectiveKey {
    if (runtimeKey != null && runtimeKey!.trim().isNotEmpty) {
      return runtimeKey!.trim();
    }
    return ApiConstants.apiKey;
  }

  /// True si todavía no hay ninguna clave válida configurada.
  static bool get isMissing {
    final key = effectiveKey;
    return key.isEmpty || key == 'PON_AQUI_TU_API_KEY_DE_TMDB';
  }
}
