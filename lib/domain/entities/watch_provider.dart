/// Plataforma donde se puede ver una película (Netflix, Disney+, etc.).
/// Proviene del endpoint /watch/providers de TMDB (datos de JustWatch).
class WatchProvider {
  final int providerId;
  final String providerName;
  final String? logoPath;

  const WatchProvider({
    required this.providerId,
    required this.providerName,
    required this.logoPath,
  });
}

/// Agrupa las plataformas por tipo de acceso para una región concreta.
///   - flatrate: incluido en la suscripción (ej. verlo en Netflix)
///   - rent: alquiler
///   - buy: compra
class WatchProviders {
  final String? link; // Enlace a la página de JustWatch para esa película
  final List<WatchProvider> flatrate;
  final List<WatchProvider> rent;
  final List<WatchProvider> buy;

  const WatchProviders({
    this.link,
    this.flatrate = const [],
    this.rent = const [],
    this.buy = const [],
  });

  bool get isEmpty => flatrate.isEmpty && rent.isEmpty && buy.isEmpty;
}
