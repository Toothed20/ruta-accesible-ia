import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../domain/models/accessibility_diagnosis.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/scan_view_model.dart';

/// Pantalla 3: Resultado del Diagnóstico adaptable a Alto Riesgo, Riesgo Medio y Camino Seguro.
class DiagnosisResultView extends StatelessWidget {
  const DiagnosisResultView({
    super.key,
    required this.viewModel,
    required this.diagnosis,
  });

  final ScanViewModel viewModel;
  final AccessibilityDiagnosis diagnosis;

  @override
  Widget build(BuildContext context) {
    final palette = _RiskPalette.fromLevel(diagnosis.riskLevel);
    final imagePath = diagnosis.imagePath;
    final hasFile = imagePath != null && File(imagePath).existsSync();
    final isSpeaking = viewModel.isSpeaking;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Tarjeta Principal: Diagnóstico Rápido (Alto / Medio / Seguro)
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: palette.cardBackground,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: palette.iconCircleBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          palette.headerIcon,
                          color: palette.iconColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DIAGNÓSTICO RÁPIDO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: palette.overlineColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              diagnosis.riskLevel.badgeTitle,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                color: palette.titleColor,
                                letterSpacing: -0.4,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Recuadro interior blanco de alto contraste
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnosis.headline,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          diagnosis.obstaclesDescription,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Tarjeta de Comprobación Directa: ¿TIENE RAMPA?
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: diagnosis.hasRamp
                        ? AppColors.surfaceContainer
                        : AppColors.dangerBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    diagnosis.hasRamp
                        ? Icons.accessible_forward_rounded
                        : Icons.not_accessible_rounded,
                    color: diagnosis.hasRamp
                        ? AppColors.secondary
                        : AppColors.dangerAccent,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿TIENE RAMPA?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        diagnosis.rampStatusText,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: diagnosis.hasRamp
                              ? AppColors.primary
                              : AppColors.dangerAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: diagnosis.hasRamp
                        ? AppColors.safeGreenBadge
                        : AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    diagnosis.hasRamp
                        ? Icons.done_all_rounded
                        : Icons.cancel_rounded,
                    color: diagnosis.hasRamp
                        ? AppColors.safeGreenContainer
                        : AppColors.dangerAccent,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Botón Destacado: Escuchar en voz alta
          Semantics(
            button: true,
            label: isSpeaking
                ? 'Detener lectura en voz alta'
                : 'Escuchar explicación en voz alta',
            child: Material(
              color: diagnosis.riskLevel == RiskLevel.bajo
                  ? AppColors.primaryContainer
                  : AppColors.secondary,
              borderRadius: BorderRadius.circular(18),
              elevation: 3,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: viewModel.toggleSpeakDiagnosis,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 76),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSpeaking
                              ? Icons.pause_circle_filled_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSpeaking
                                  ? 'Reproduciendo audio...'
                                  : 'Escuchar en voz alta',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isSpeaking
                                  ? 'Toque de nuevo para detener'
                                  : 'Le explicamos el lugar por audio',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryFixed,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSpeaking
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.secondary,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 4. Fotografía del Lugar Analizado
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 195,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasFile)
                    Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    )
                  else
                    _AnalyzedPlaceIllustration(riskLevel: diagnosis.riskLevel),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            diagnosis.riskLevel == RiskLevel.bajo
                                ? Icons.verified_rounded
                                : Icons.photo_camera_rounded,
                            size: 18,
                            color: palette.overlineColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            diagnosis.riskLevel.photoBadgeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 5. Tarjeta de Recomendación Práctica: ¿QUÉ HACER AHORA?
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    diagnosis.riskLevel == RiskLevel.bajo
                        ? Icons.thumb_up_alt_rounded
                        : Icons.lightbulb_rounded,
                    color: AppColors.secondary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿QUÉ HACER AHORA?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        diagnosis.actionRecommendation,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 6. Botón Enorme de Acción Principal: Escanear Otro Lugar
          SizedBox(
            height: 64,
            child: ElevatedButton.icon(
              onPressed: viewModel.resetToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.photo_camera_rounded, size: 28),
              label: const Text(
                'Escanear Otro Lugar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskPalette {
  const _RiskPalette({
    required this.cardBackground,
    required this.iconCircleBackground,
    required this.iconColor,
    required this.overlineColor,
    required this.titleColor,
    required this.headerIcon,
  });

  final Color cardBackground;
  final Color iconCircleBackground;
  final Color iconColor;
  final Color overlineColor;
  final Color titleColor;
  final IconData headerIcon;

  factory _RiskPalette.fromLevel(RiskLevel level) {
    return switch (level) {
      RiskLevel.alto => const _RiskPalette(
        cardBackground: AppColors.dangerBackground,
        iconCircleBackground: AppColors.dangerAccent,
        iconColor: Colors.white,
        overlineColor: AppColors.dangerAccent,
        titleColor: AppColors.dangerTitle,
        headerIcon: Icons.warning_rounded,
      ),
      RiskLevel.medio => const _RiskPalette(
        cardBackground: AppColors.cautionBackground,
        iconCircleBackground: AppColors.cautionBadge,
        iconColor: AppColors.cautionAccent,
        overlineColor: AppColors.cautionLabel,
        titleColor: AppColors.cautionTitle,
        headerIcon: Icons.warning_amber_rounded,
      ),
      RiskLevel.bajo => const _RiskPalette(
        cardBackground: AppColors.surfaceContainerLow,
        iconCircleBackground: AppColors.safeGreenBadge,
        iconColor: AppColors.safeGreenContainer,
        overlineColor: AppColors.safeGreenText,
        titleColor: AppColors.primary,
        headerIcon: Icons.check_circle_rounded,
      ),
    };
  }
}

class _AnalyzedPlaceIllustration extends StatelessWidget {
  const _AnalyzedPlaceIllustration({required this.riskLevel});

  final RiskLevel riskLevel;

  @override
  Widget build(BuildContext context) {
    final gradientColors = switch (riskLevel) {
      RiskLevel.alto => const [Color(0xFF4A3535), Color(0xFF7D5A50)],
      RiskLevel.medio => const [Color(0xFF5C4D32), Color(0xFF8C7A5B)],
      RiskLevel.bajo => const [Color(0xFF2E5A44), Color(0xFF5B8C72)],
    };

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              riskLevel == RiskLevel.bajo
                  ? Icons.accessible_forward_rounded
                  : Icons.report_problem_rounded,
              size: 54,
              color: Colors.white.withValues(alpha: 0.78),
            ),
            const SizedBox(height: 8),
            Text(
              riskLevel == RiskLevel.alto
                  ? 'Vista previa: Banqueta con desnivel y fractura'
                  : riskLevel == RiskLevel.medio
                  ? 'Vista previa: Acera estrecha con pendiente moderada'
                  : 'Vista previa: Cruce peatonal con rampa despejada',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
