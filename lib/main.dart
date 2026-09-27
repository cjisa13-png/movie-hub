import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/favorites_local_datasource.dart';
import 'data/datasources/movie_service.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'domain/repositories/movie_repository.dart';
import 'domain/usecases/get_genres.dart';
import 'domain/usecases/get_movie_detail.dart';
import 'domain/usecases/get_trending_movies.dart';
import 'domain/usecases/manage_favorites.dart';
import 'domain/usecases/search_movies.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/api_key_setup_screen.dart';
import 'presentation/screens/main_navigation.dart';

void main() {
  // Aseguramos que Flutter esté listo (necesario para plugins como sqflite).
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MovieHubApp());
}

/// Raíz de la aplicación. Aquí se hace la "inyección de dependencias":
/// se crean las capas (datasources -> repository -> usecases -> providers)
/// y se ponen a disposición de toda la app con MultiProvider.
class MovieHubApp extends StatelessWidget {
  const MovieHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 1. Capa de datos ---
    final apiClient = ApiClient();
    final movieService = MovieService(apiClient);
    final localDataSource = FavoritesLocalDataSource();

    // --- 2. Repositorio ---
    final MovieRepository repository = MovieRepositoryImpl(
      remote: movieService,
      local: localDataSource,
    );

    // --- 3. Casos de uso ---
    final getTrending = GetTrendingMovies(repository);
    final searchMovies = SearchMovies(repository);
    final getMovieDetail = GetMovieDetail(repository);
    final getGenres = GetGenres(repository);
    final manageFavorites = ManageFavorites(repository);

    return MultiProvider(
      providers: [
        // El caso de uso del detalle se expone como valor para que la
        // pantalla de detalle pueda crear su propio DetailProvider.
        Provider<GetMovieDetail>.value(value: getMovieDetail),

        // SettingsProvider carga la clave de API guardada al arrancar.
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider(getTrending)),
        ChangeNotifierProvider(
            create: (_) => SearchProvider(searchMovies, getGenres)),
        ChangeNotifierProvider(
            create: (_) => FavoritesProvider(manageFavorites)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const _AppEntryPoint(),
          );
        },
      ),
    );
  }
}

/// Decide qué pantalla mostrar al arrancar:
///   - Mientras carga la configuración: un splash sencillo.
///   - Si no hay clave de API: la pantalla para introducirla.
///   - Si hay clave: la app (navegación principal).
class _AppEntryPoint extends StatelessWidget {
  const _AppEntryPoint();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (!settings.loaded) {
      return const Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!settings.hasKey) {
      return const ApiKeySetupScreen();
    }

    return const MainNavigation();
  }
}
