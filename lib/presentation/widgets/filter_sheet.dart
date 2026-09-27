import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/genre.dart';
import '../../domain/repositories/movie_repository.dart';

/// Panel inferior (bottom sheet) con los filtros avanzados de búsqueda:
/// género, año de estreno, valoración mínima y plataforma de streaming.
///
/// Devuelve, mediante Navigator.pop, un objeto [MovieFilters] con la
/// selección del usuario (o null si cancela).
class FilterSheet extends StatefulWidget {
  final MovieFilters current;
  final List<Genre> genres;

  const FilterSheet({super.key, required this.current, required this.genres});

  /// Abre el panel y devuelve los filtros elegidos (o null).
  static Future<MovieFilters?> show(
    BuildContext context, {
    required MovieFilters current,
    required List<Genre> genres,
  }) {
    return showModalBottomSheet<MovieFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(current: current, genres: genres),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  int? _genreId;
  int? _year;
  double? _minRating;
  int? _platformId;

  @override
  void initState() {
    super.initState();
    _genreId = widget.current.genreId;
    _year = widget.current.year;
    _minRating = widget.current.minRating;
    _platformId = widget.current.platformId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;
    final years = [
      for (int y = currentYear; y >= AppConstants.minYear; y--) y,
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Agarradera" del sheet.
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkTextSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Filtros', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            // --- Género ---
            _label('Género', theme),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.genres.map((g) {
                final selected = _genreId == g.id;
                return ChoiceChip(
                  label: Text(g.name),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _genreId = selected ? null : g.id),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // --- Plataforma ---
            _label('Plataforma', theme),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.streamingPlatforms.entries.map((e) {
                final selected = _platformId == e.value;
                return ChoiceChip(
                  label: Text(e.key),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _platformId = selected ? null : e.value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // --- Año ---
            _label('Año de estreno', theme),
            DropdownButtonFormField<int?>(
              value: _year,
              isExpanded: true,
              dropdownColor: AppColors.darkCard,
              hint: const Text('Cualquier año'),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text('Cualquier año')),
                ...years.map((y) =>
                    DropdownMenuItem<int?>(value: y, child: Text('$y'))),
              ],
              onChanged: (v) => setState(() => _year = v),
            ),
            const SizedBox(height: 20),

            // --- Valoración mínima ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Valoración mínima', theme),
                Text(
                  _minRating == null ? 'Cualquiera' : _minRating!.toStringAsFixed(1),
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            Slider(
              value: _minRating ?? 0,
              min: 0,
              max: 9,
              divisions: 18,
              activeColor: AppColors.primary,
              label: (_minRating ?? 0).toStringAsFixed(1),
              onChanged: (v) => setState(() => _minRating = v == 0 ? null : v),
            ),
            const SizedBox(height: 12),

            // --- Botones ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _genreId = null;
                        _year = null;
                        _minRating = null;
                        _platformId = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.darkTextSecondary),
                    ),
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        MovieFilters(
                          genreId: _genreId,
                          year: _year,
                          minRating: _minRating,
                          platformId: _platformId,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Aplicar filtros'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, ThemeData theme) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: theme.textTheme.titleMedium),
      );
}
