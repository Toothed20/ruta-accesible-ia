import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../view_models/scan_view_model.dart';

/// Pantalla 2: Estado de espera "Analizando el camino con IA..." (Google Stitch v2).
class AnalyzingView extends StatefulWidget {
  const AnalyzingView({
    super.key,
    required this.viewModel,
  });

  final ScanViewModel viewModel;

  @override
  State<AnalyzingView> createState() => _AnalyzingViewState();
}

class _AnalyzingViewState extends State<AnalyzingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.viewModel.selectedImagePath;
    final hasFile = imagePath != null && File(imagePath).existsSync();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Banner superior de estado activo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VISIÓN ARTIFICIAL ACTIVA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Procesando imagen con IA... Mantenga la vista aquí',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Visor de fotografía capturada con haz de escaneo animado
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasFile)
                    Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryContainer,
                            Color(0xFF1E3A5F),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.landscape_rounded,
                          size: 84,
                          color: Colors.white24,
                        ),
                      ),
                    ),

                  // Capa tintada de escaneo
                  Container(
                    color: AppColors.secondary.withValues(alpha: 0.14),
                  ),

                  // Haz de escaneo animado de arriba hacia abajo
                  AnimatedBuilder(
                    animation: _scanController,
                    builder: (context, _) {
                      return Align(
                        alignment: Alignment(
                          0,
                          (_scanController.value * 1.6) - 0.8,
                        ),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.secondaryContainer,
                                Colors.white,
                                AppColors.secondaryContainer,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryContainer.withValues(
                                  alpha: 0.85,
                                ),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Píldora inferior de detección en vivo
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'Reconociendo desniveles, textura y rampas...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Bloque principal de progreso y telemetría
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          color: AppColors.secondary,
                          backgroundColor: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      const Icon(
                        Icons.manage_search_rounded,
                        color: AppColors.secondary,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Analizando el camino con IA...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Detectando obstáculos físicos, ancho de acera, escalones y accesibilidad de rampa en tiempo real.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(color: AppColors.surfaceContainerHigh, height: 1),
                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TelemetryStepItem(
                      icon: Icons.check_rounded,
                      label: 'Captura',
                      isDone: true,
                      isActive: false,
                    ),
                    _TelemetryStepItem(
                      icon: Icons.straighten_rounded,
                      label: 'Desniveles',
                      isDone: false,
                      isActive: true,
                    ),
                    _TelemetryStepItem(
                      icon: Icons.record_voice_over_rounded,
                      label: 'Síntesis',
                      isDone: false,
                      isActive: false,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Tarjeta de aviso del asistente de voz
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.hearing_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asistente de voz preparando diagnóstico',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'En unos segundos le leeremos el resultado en voz alta automáticamente para su comodidad.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.onSurfaceVariant,
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

          // 5. Botón de Cancelar Análisis
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: widget.viewModel.cancelAnalysis,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.dangerBackground,
                side: BorderSide(
                  color: AppColors.dangerAccent.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.dangerAccent,
                size: 22,
              ),
              label: const Text(
                'Cancelar Análisis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dangerAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetryStepItem extends StatelessWidget {
  const _TelemetryStepItem({
    required this.icon,
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDone
        ? AppColors.secondary
        : isActive
        ? AppColors.secondaryContainer
        : AppColors.surfaceContainer;
    final iconColor = (isDone || isActive)
        ? Colors.white
        : AppColors.onSurfaceVariant;
    final textColor = isActive
        ? AppColors.secondary
        : isDone
        ? AppColors.onSurface
        : AppColors.onSurfaceVariant;

    return Opacity(
      opacity: (isDone || isActive) ? 1.0 : 0.45,
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
