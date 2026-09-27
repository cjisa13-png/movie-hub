import 'package:flutter/material.dart';

/// Paleta de colores de la app, inspirada en Netflix.
/// Se definen los colores para el modo oscuro (principal) y el modo claro.
class AppColors {
  AppColors._();

  // --- Color de marca (rojo Netflix) ---
  static const Color primary = Color(0xFFE50914);
  static const Color primaryDark = Color(0xFFB0060F);

  // --- Modo Oscuro (por defecto) ---
  static const Color darkBackground = Color(0xFF0B0B0F);
  static const Color darkSurface = Color(0xFF1A1A20);
  static const Color darkCard = Color(0xFF23232B);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);

  // --- Modo Claro ---
  static const Color lightBackground = Color(0xFFF7F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF141414);
  static const Color lightTextSecondary = Color(0xFF5A5A5A);

  // --- Colores de apoyo ---
  static const Color rating = Color(0xFFF5C518); // Amarillo tipo IMDb
  static const Color success = Color(0xFF46D369);
  static const Color error = Color(0xFFE50914);

  // --- Degradados para superponer sobre las imágenes (efecto "poster") ---
  static const LinearGradient posterOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC0B0B0F)],
    stops: [0.4, 1.0],
  );

  static const LinearGradient heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x990B0B0F),
      Color(0xFF0B0B0F),
    ],
    stops: [0.0, 0.6, 1.0],
  );
}
