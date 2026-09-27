import 'package:flutter/material.dart';

/// Tipografía de la app. Usamos la fuente por defecto del sistema
/// (San Francisco en iOS, Roboto en Android) para no depender de descargas,
/// definiendo tamaños y pesos coherentes en toda la app.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
        // Títulos grandes (ej. nombre de película en el detalle)
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: primary,
          letterSpacing: -0.5,
        ),
        // Cabeceras de sección ("Tendencias", "Reparto"...)
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        // Cuerpo de texto (sinopsis, descripciones)
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: primary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: secondary,
        ),
        // Texto pequeño (metadatos, etiquetas)
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          color: secondary,
        ),
      );
}
