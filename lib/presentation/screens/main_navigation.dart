import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';

/// Contenedor principal con la barra de navegación inferior
/// (Inicio / Buscar / Mi lista).
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  // Se mantienen vivas con IndexedStack para no recargar al cambiar de pestaña.
  final _screens = const [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
  ];

  void _onTap(int i) {
    setState(() => _index = i);
    // Al entrar en "Mi lista", refrescamos los favoritos.
    if (i == 2) {
      context.read<FavoritesProvider>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border_rounded),
            activeIcon: Icon(Icons.bookmark_rounded),
            label: 'Mi lista',
          ),
        ],
      ),
    );
  }
}
