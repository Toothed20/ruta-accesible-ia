import 'package:flutter/material.dart';

/// Paleta de colores y tipografía oficial de RutaAccesible IA (Google Stitch v2).
abstract final class AppColors {
  // Superficies y fondos de alto contraste para exteriores
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);

  // Colores principales
  static const Color primary = Color(0xFF000F22);
  static const Color primaryContainer = Color(0xFF0A2540);
  static const Color primaryFixedDim = Color(0xFFB0C8EB);

  // Azul eléctrico secundario
  static const Color secondary = Color(0xFF0D50D5);
  static const Color secondaryContainer = Color(0xFF386BEF);
  static const Color secondaryFixed = Color(0xFFDBE1FF);
  static const Color onSecondaryFixed = Color(0xFF00174D);

  // Textos y bordes
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF43474D);
  static const Color outline = Color(0xFF74777E);
  static const Color outlineVariant = Color(0xFFC4C6CE);

  // Semáforo 1: Camino Seguro (Bajo Riesgo)
  static const Color safeGreenText = Color(0xFF1A9E70);
  static const Color safeGreenContainer = Color(0xFF002A1B);
  static const Color safeGreenBadge = Color(0xFF85F8C4);

  // Semáforo 2: Riesgo Medio (Precaución - Ámbar)
  static const Color cautionBackground = Color(0xFFFFFBEB);
  static const Color cautionBadge = Color(0xFFFEF3C7);
  static const Color cautionAccent = Color(0xFFD97706);
  static const Color cautionLabel = Color(0xFFB45309);
  static const Color cautionTitle = Color(0xFF78350F);

  // Semáforo 3: Alto Riesgo (Peligro - Rojo)
  static const Color dangerBackground = Color(0xFFFFDAD6);
  static const Color dangerAccent = Color(0xFFBA1A1A);
  static const Color dangerTitle = Color(0xFF7F1D1D);
}

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.dangerAccent,
        onError: Colors.white,
      ),
    );
  }
}
