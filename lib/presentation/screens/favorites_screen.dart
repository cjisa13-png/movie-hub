import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/view_state.dart';
import '../widgets/movie_grid.dart';
import '../widgets/state_views.dart';

/// Pantalla "Mi lista": muestra las películas guardadas en favoritos (Watchlist).
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoritesProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Mi lista', style: theme.textTheme.displaySmall),
            ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(FavoritesProvider provider) {
    switch (provider.state) {
      case ViewState.loading:
      case ViewState.initial:
        return const LoadingView();
      case ViewState.empty:
        return const EmptyView(
          icon: Icons.bookmark_border_rounded,
          message: 'Tu lista está vacía',
          subtitle:
              'Pulsa el corazón en cualquier película para guardarla aquí y verla luego.',
        );
      case ViewState.error:
      case ViewState.loaded:
        return RefreshIndicator(
          onRefresh: () => provider.load(),
          child: MovieGrid(
            movies: provider.favorites,
            physics: const AlwaysScrollableScrollPhysics(),
          ),
        );
    }
  }
}
