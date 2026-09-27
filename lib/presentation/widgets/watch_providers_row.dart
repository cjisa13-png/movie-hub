import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/watch_provider.dart';
import 'poster_image.dart';

/// Sección "¿Dónde ver?": muestra los logos de las plataformas donde está
/// disponible la película, agrupadas por tipo (suscripción / alquiler / compra).
class WatchProvidersSection extends StatelessWidget {
  final WatchProviders providers;

  const WatchProvidersSection({super.key, required this.providers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (providers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.tv_off_rounded,
                color: AppColors.darkTextSecondary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No disponible en plataformas de tu región por ahora.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (providers.flatrate.isNotEmpty)
          _group(context, 'En streaming (suscripción)', providers.flatrate),
        if (providers.rent.isNotEmpty)
          _group(context, 'Alquiler', providers.rent),
        if (providers.buy.isNotEmpty)
          _group(context, 'Compra', providers.buy),
      ],
    );
  }

  Widget _group(BuildContext context, String label, List<WatchProvider> list) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(label,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: AppColors.darkTextSecondary)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final provider = list[i];
                return Tooltip(
                  message: provider.providerName,
                  child: PosterImage(
                    url: ApiConstants.logoUrl(provider.logoPath),
                    width: 56,
                    height: 56,
                    borderRadius: 12,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
