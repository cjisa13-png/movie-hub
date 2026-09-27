import '../../domain/entities/watch_provider.dart';

class WatchProviderModel extends WatchProvider {
  const WatchProviderModel({
    required super.providerId,
    required super.providerName,
    required super.logoPath,
  });

  factory WatchProviderModel.fromJson(Map<String, dynamic> json) {
    return WatchProviderModel(
      providerId: json['provider_id'] as int,
      providerName: (json['provider_name'] ?? '') as String,
      logoPath: json['logo_path'] as String?,
    );
  }
}

/// Parsea el bloque de "watch/providers" de TMDB para una región concreta.
class WatchProvidersModel extends WatchProviders {
  const WatchProvidersModel({
    super.link,
    super.flatrate,
    super.rent,
    super.buy,
  });

  /// El JSON llega como { results: { ES: {...}, US: {...} } }.
  /// [region] indica de qué país tomar los datos (ej. "ES").
  factory WatchProvidersModel.fromJson(
    Map<String, dynamic> json,
    String region,
  ) {
    final results = json['results'] as Map<String, dynamic>?;
    final regionData = results?[region] as Map<String, dynamic>?;

    if (regionData == null) {
      return const WatchProvidersModel();
    }

    List<WatchProvider> parse(String key) {
      final list = regionData[key] as List?;
      if (list == null) return const [];
      return list
          .map((e) => WatchProviderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return WatchProvidersModel(
      link: regionData['link'] as String?,
      flatrate: parse('flatrate'),
      rent: parse('rent'),
      buy: parse('buy'),
    );
  }
}
