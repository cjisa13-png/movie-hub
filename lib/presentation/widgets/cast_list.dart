import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/cast.dart';
import 'poster_image.dart';

/// Fila horizontal con el reparto principal (foto + nombre + personaje).
class CastList extends StatelessWidget {
  final List<CastMember> cast;

  const CastList({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    // Mostramos como mucho los 15 primeros.
    final items = cast.take(15).toList();

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final member = items[i];
          return SizedBox(
            width: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: member.profilePath != null
                      ? PosterImage(
                          url: ApiConstants.profileUrl(member.profilePath),
                          width: 80,
                          height: 80,
                          borderRadius: 40,
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: AppColors.darkCard,
                          child: const Icon(Icons.person,
                              color: AppColors.darkTextSecondary, size: 36),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  member.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  member.character,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
