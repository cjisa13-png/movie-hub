import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/search_provider.dart';
import '../providers/view_state.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/movie_grid.dart';
import '../widgets/state_views.dart';

/// Pantalla de búsqueda avanzada: barra de búsqueda + botón de filtros +
/// rejilla de resultados.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargamos los géneros para el panel de filtros.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().loadGenres();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final provider = context.read<SearchProvider>();
    final result = await FilterSheet.show(
      context,
      current: provider.filters,
      genres: provider.genres,
    );
    if (result != null) {
      provider.applyFilters(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Buscar', style: theme.textTheme.displaySmall),
            ),
            // --- Barra de búsqueda + botón de filtros ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onChanged: provider.onQueryChanged,
                      decoration: InputDecoration(
                        hintText: 'Título de la película...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _controller.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _controller.clear();
                                  provider.onQueryChanged('');
                                  setState(() {});
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _FilterButton(
                    count: provider.activeFilterCount,
                    onTap: _openFilters,
                  ),
                ],
              ),
            ),
            // --- Chips de filtros activos ---
            if (provider.activeFilterCount > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 12),
                  child: TextButton.icon(
                    onPressed: provider.clearFilters,
                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                    label: Text(
                        'Quitar filtros (${provider.activeFilterCount})'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(child: _buildResults(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(SearchProvider provider) {
    switch (provider.state) {
      case ViewState.initial:
        return const EmptyView(
          icon: Icons.movie_filter_outlined,
          message: 'Busca tu próxima película',
          subtitle:
              'Escribe un título o usa los filtros por género, año, nota y plataforma.',
        );
      case ViewState.loading:
        return const LoadingView();
      case ViewState.error:
        return ErrorView(message: provider.errorMessage, onRetry: provider.retry);
      case ViewState.empty:
        return const EmptyView(
          icon: Icons.search_off_rounded,
          message: 'Sin resultados',
          subtitle: 'Prueba con otro título o cambia los filtros.',
        );
      case ViewState.loaded:
        return MovieGrid(movies: provider.results);
    }
  }
}

/// Botón de filtros con un indicador (badge) del nº de filtros activos.
class _FilterButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _FilterButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: count > 0 ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Icon(Icons.tune_rounded),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
