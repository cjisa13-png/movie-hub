import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/usecases/get_movie_detail.dart';
import '../providers/detail_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/view_state.dart';
import '../widgets/cast_list.dart';
import '../widgets/poster_image.dart';
import '../widgets/rating_badge.dart';
import '../widgets/state_views.dart';
import '../widgets/trailer_player.dart';
import '../widgets/watch_providers_row.dart';

/// Pantalla de detalle de una película.
///
/// Se le pasa el [movieId] y ella misma pide todos los datos (detalle,
/// reparto, tráilers y "dónde ver") a través del [DetailProvider].
class DetailScreen extends StatefulWidget {
  final int movieId;
  final String? heroTag;

  const DetailScreen({super.key, required this.movieId, this.heroTag});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final DetailProvider _detailProvider;

  @override
  void initState() {
    super.initState();
    // Creamos un DetailProvider propio para esta pantalla, reutilizando el
    // caso de uso ya registrado en el árbol de providers.
    _detailProvider = DetailProvider(context.read<GetMovieDetail>());
    _detailProvider.load(widget.movieId);
  }

  @override
  void dispose() {
    _detailProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _detailProvider,
      child: Scaffold(
        body: Consumer<DetailProvider>(
          builder: (context, provider, _) {
            switch (provider.state) {
              case ViewState.loading:
              case ViewState.initial:
                return const _LoadingScaffold();
              case ViewState.error:
                return _ErrorScaffold(
                  message: provider.errorMessage,
                  onRetry: () => provider.load(widget.movieId),
                );
              case ViewState.empty:
              case ViewState.loaded:
                return _DetailContent(
                  bundle: provider.bundle!,
                  heroTag: widget.heroTag,
                );
            }
          },
        ),
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const LoadingView(),
        SafeArea(child: BackButton(color: Theme.of(context).iconTheme.color)),
      ],
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorScaffold({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ErrorView(message: message, onRetry: onRetry),
        SafeArea(child: BackButton(color: Theme.of(context).iconTheme.color)),
      ],
    );
  }
}

/// Contenido principal del detalle (cuando ya hay datos).
class _DetailContent extends StatelessWidget {
  final MovieDetailBundle bundle;
  final String? heroTag;

  const _DetailContent({required this.bundle, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = bundle.detail;
    final trailer = bundle.bestTrailer;

    return CustomScrollView(
      slivers: [
        // --- Cabecera con imagen de fondo (backdrop) ---
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: const _CircleBackButton(),
          actions: [_FavoriteButton(movie: _toMovie(detail))],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: heroTag ?? 'detail_${detail.id}',
                  child: PosterImage(
                    url: ApiConstants.backdropUrl(
                        detail.backdropPath ?? detail.posterPath),
                    fit: BoxFit.cover,
                    borderRadius: 0,
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.heroOverlay),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Título + metadatos ---
                Text(detail.title, style: theme.textTheme.displaySmall),
                if (detail.tagline != null && detail.tagline!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail.tagline!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    RatingBadge(rating: detail.voteAverage, size: 15),
                    const SizedBox(width: 12),
                    _metaChip(context, Icons.calendar_today_rounded, detail.year),
                    const SizedBox(width: 8),
                    if (detail.runtime != null && detail.runtime! > 0)
                      _metaChip(context, Icons.schedule_rounded,
                          detail.formattedRuntime),
                  ],
                ),
                const SizedBox(height: 14),

                // --- Géneros ---
                if (detail.genres.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: detail.genres
                        .map((g) => Chip(
                              label: Text(g.name),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 20),

                // --- Tráiler embebido ---
                if (trailer != null) ...[
                  Text('Tráiler', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TrailerPlayer(videoKey: trailer.key),
                  const SizedBox(height: 24),
                ],

                // --- Sinopsis ---
                Text('Sinopsis', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  detail.overview.isEmpty
                      ? 'Sin sinopsis disponible en español.'
                      : detail.overview,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // --- ¿Dónde ver? ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Text('¿Dónde ver?', style: theme.textTheme.titleLarge),
          ),
        ),
        SliverToBoxAdapter(
          child: WatchProvidersSection(providers: bundle.providers),
        ),

        // --- Reparto ---
        if (bundle.cast.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Text('Reparto', style: theme.textTheme.titleLarge),
            ),
          ),
          SliverToBoxAdapter(child: CastList(cast: bundle.cast)),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _metaChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.darkTextSecondary),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  /// Convierte el MovieDetail en un Movie ligero para poder guardarlo
  /// como favorito desde la pantalla de detalle.
  Movie _toMovie(MovieDetail d) => Movie(
        id: d.id,
        title: d.title,
        overview: d.overview,
        posterPath: d.posterPath,
        backdropPath: d.backdropPath,
        voteAverage: d.voteAverage,
        voteCount: d.voteCount,
        releaseDate: d.releaseDate,
        genreIds: d.genres.map((g) => g.id).toList(),
      );
}

/// Botón de retroceso circular sobre la imagen.
class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.5),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

/// Botón de favorito (corazón) que usa el FavoritesProvider global.
class _FavoriteButton extends StatelessWidget {
  final Movie movie;
  const _FavoriteButton({required this.movie});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorite(movie.id);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.5),
        child: IconButton(
          icon: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFav ? AppColors.primary : Colors.white,
          ),
          onPressed: () async {
            final nowFav = await favorites.toggle(movie);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(nowFav
                      ? 'Añadida a tu lista'
                      : 'Quitada de tu lista'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
