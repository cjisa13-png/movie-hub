/// Constantes generales de la aplicación (textos, valores por defecto, etc.).
class AppConstants {
  AppConstants._();

  static const String appName = 'Movie Hub';

  /// Año mínimo seleccionable en el filtro de "año de estreno".
  static const int minYear = 1950;

  /// Clave usada en SharedPreferences para recordar el tema elegido.
  static const String themePrefKey = 'is_dark_mode';

  /// Plataformas de streaming más comunes con su ID de proveedor en TMDB.
  /// Se usan en el filtro "¿Dónde ver?" de la pantalla de búsqueda.
  /// (IDs oficiales del endpoint /watch/providers/movie de TMDB.)
  static const Map<String, int> streamingPlatforms = {
    'Netflix': 8,
    'Amazon Prime Video': 119,
    'Disney+': 337,
    'HBO Max': 1899,
    'Apple TV+': 350,
    'Movistar Plus+': 149,
    'SkyShowtime': 1773,
    'Filmin': 63,
  };
}
