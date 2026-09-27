import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/movie.dart';
import '../providers/home_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/view_state.dart';
import '../widgets/movie_carousel.dart';
import '../widgets/poster_image.dart';
import '../widgets/rating_badge.dart';
import '../widgets/state_views.dart';
import 'api_key_setup_screen.dart';
import 'detail_screen.dart';

/// Pantalla de inicio: película destacada + carruseles de tendencias.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos las tendencias al montar la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeProvider provider) {
    switch (provider.state) {
      case ViewState.loading:
      case ViewState.initial:
        return const LoadingView();
      case ViewState.error:
        return ErrorView(
          message: provider.errorMessage,
          onRetry: () => provider.load(),
        );
      case ViewState.empty:
        return const EmptyView(
          icon: Icons.movie_outlined,
          message: 'No hay películas para mostrar.',
        );
      case ViewState.loaded:
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => provider.load(),
          child: CustomScrollView(
            slivers: [
              // --- Cabecera con la app y el botón de tema ---
              SliverToBoxAdapter(child: _topBar(context)),
              // --- Película destacada (hero) ---
              if (provider.featured != null)
                SliverToBoxAdapter(child: _FeaturedHero(movie: provider.featured!)),
              // --- Carrusel de tendencias ---
              SliverToBoxAdapter(
                child: MovieCarousel(
                  title: 'Tendencias de la semana',
                  movies: provider.rest,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
    }
  }

  Widget _topBar(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          // Logo tipo "MOVIE HUB" con la M en rojo.
          RichText(
            text: TextSpan(
              style: theme.textTheme.displaySmall?.copyWith(fontSize: 24),
              children: const [
                TextSpan(
                    text: 'MOVIE',
                    style: TextStyle(color: AppColors.primary)),
                TextSpan(text: ' HUB'),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: themeProvider.isDark ? 'Modo claro' : 'Modo oscuro',
            icon: Icon(themeProvider.isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () => themeProvider.toggle(),
          ),
          IconButton(
            tooltip: 'Cambiar clave de TMDB',
            icon: const Icon(Icons.vpn_key_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ApiKeySetupScreen(canGoBack: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloque "hero" con la película destacada a lo grande (estilo portada Netflix).
class _FeaturedHero extends StatelessWidget {
  final Movie movie;

  const _FeaturedHero({required this.movie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              DetailScreen(movieId: movie.id, heroTag: 'featured_${movie.id}'),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 460,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'featured_${movie.id}',
              child: PosterImage(
                url: ApiConstants.posterUrl(movie.posterPath),
                fit: BoxFit.cover,
                borderRadius: 20,
              ),
            ),
            // Degradado para que el texto se lea bien.
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.heroOverlay),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBadge(rating: movie.voteAverage, size: 15),
                  const SizedBox(height: 10),
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.displaySmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${movie.year}  ·  Destacada',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                                movieId: movie.id,
                                heroTag: 'featured_${movie.id}'),
                          ),
                        ),
                        icon: const Icon(Icons.info_outline_rounded),
                        label: const Text('Ver detalles'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
