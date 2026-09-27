/// =============================================================================
///  CONFIGURACIÓN DE LA API DE TMDB (The Movie Database)
/// =============================================================================
///
///  👉 PASO OBLIGATORIO ANTES DE EJECUTAR LA APP:
///
///  1. Entra en https://www.themoviedb.org/ y crea una cuenta (es gratis).
///  2. Ve a: Ajustes (tu avatar) -> Settings -> API -> "Create" / "Solicitar clave API".
///     Elige la opción "Developer" y rellena el formulario (puedes poner datos
///     genéricos: nombre de la app "Movie Hub", uso personal/educativo, etc.).
///  3. Te darán dos cosas:
///        - "API Key (v3 auth)"  ->  es una cadena corta tipo: 8f2c...e9
///        - "API Read Access Token (v4)" -> es un token largo tipo: eyJhbGciOi...
///
///  4. Pega TU clave v3 en la constante `apiKey` de abajo, entre las comillas.
///     (Esta app usa la autenticación v3 con `api_key`, que es la más simple.)
///
///  Ejemplo:
///     static const String apiKey = '8f2c1d3b4a5e6f7089abcd1234567890';
///
///  ⚠️  No compartas tu clave públicamente ni la subas a un repositorio público.
/// =============================================================================
class ApiConstants {
  ApiConstants._();

  // ⬇️⬇️⬇️  PEGA AQUÍ TU CLAVE DE API DE TMDB (v3)  ⬇️⬇️⬇️
  static const String apiKey = 'PON_AQUI_TU_API_KEY_DE_TMDB';
  // ⬆️⬆️⬆️  PEGA AQUÍ TU CLAVE DE API DE TMDB (v3)  ⬆️⬆️⬆️

  /// URL base de la API de TMDB.
  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// URL base para las imágenes (pósters, backdrops). Se le concatena el tamaño.
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  /// Tamaños de imagen recomendados por TMDB.
  static const String posterSize = 'w500';
  static const String backdropSize = 'w780';
  static const String profileSize = 'w185';
  static const String logoSize = 'w92';

  /// Idioma por defecto de las respuestas (español de España).
  /// Cámbialo a 'es-MX', 'en-US', etc. si lo prefieres.
  static const String language = 'es-ES';

  /// Región usada para "dónde ver" (watch providers).
  /// 'ES' = España. Cámbialo a 'MX', 'AR', 'US'... según tu país.
  static const String watchRegion = 'ES';

  // --- Endpoints ---
  static const String trending = '/trending/movie/week';
  static const String searchMovie = '/search/movie';
  static const String discoverMovie = '/discover/movie';
  static const String genreList = '/genre/movie/list';
  static String movieDetail(int id) => '/movie/$id';
  static String movieVideos(int id) => '/movie/$id/videos';
  static String movieCredits(int id) => '/movie/$id/credits';
  static String watchProviders(int id) => '/movie/$id/watch/providers';

  // --- Helpers para construir URLs de imagen completas ---
  static String posterUrl(String? path) =>
      path == null ? '' : '$imageBaseUrl/$posterSize$path';
  static String backdropUrl(String? path) =>
      path == null ? '' : '$imageBaseUrl/$backdropSize$path';
  static String profileUrl(String? path) =>
      path == null ? '' : '$imageBaseUrl/$profileSize$path';
  static String logoUrl(String? path) =>
      path == null ? '' : '$imageBaseUrl/$logoSize$path';

  /// Devuelve `true` si el usuario todavía no ha configurado su clave.
  static bool get isApiKeyMissing =>
      apiKey.isEmpty || apiKey == 'PON_AQUI_TU_API_KEY_DE_TMDB';
}
