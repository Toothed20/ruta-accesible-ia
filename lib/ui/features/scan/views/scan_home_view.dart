import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../domain/models/accessibility_diagnosis.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/scan_view_model.dart';
import 'voice_input_sheet.dart';

/// Pantalla 1: Escaneo Simple (fiel al diseño de Google Stitch v2).
class ScanHomeView extends StatelessWidget {
  const ScanHomeView({
    super.key,
    required this.viewModel,
  });

  final ScanViewModel viewModel;

  void _openVoiceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceInputSheet(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPath = viewModel.selectedImagePath;
    final hasFile = selectedPath != null && File(selectedPath).existsSync();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Tarjeta de estado amigable: "Listo para mirar"
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Listo para mirar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Le diremos de inmediato si hay escalones o rampas libres.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.dangerBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.dangerAccent),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.dangerAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dangerTitle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // 2. Visor de Cámara Amigable y Grande (relación 4:5)
          AspectRatio(
            aspectRatio: 4 / 4.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Fondo de imagen capturada o representación visual de acera urbana
                  if (hasFile)
                    Image.file(
                      File(selectedPath),
                      fit: BoxFit.cover,
                    )
                  else
                    const _UrbanStreetPreviewBackground(),

                  // Degradado sutil para garantizar contraste del texto
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.35),
                          Colors.transparent,
                          AppColors.primary.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),

                  // Contenido interior del visor
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Píldora guía superior
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.center_focus_strong_rounded,
                                color: AppColors.secondary,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Apunte al frente o al cruce',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Recuadro central "Camino a la vista"
                        Container(
                          width: 210,
                          height: 190,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.94),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.visibility_outlined,
                                  color: AppColors.secondary,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Camino a la vista',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Mensaje tranquilizador inferior dentro del visor
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                color: AppColors.safeGreenText,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Mantenga el teléfono firme un segundo',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
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

          // 3. Botón Gigante Primario: Revisar Camino
          Semantics(
            button: true,
            label: 'Revisar el camino con la cámara ahora',
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: viewModel.captureWithCameraAndAnalyze,
                child: Container(
                  height: 82,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Revisar Camino',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Tocar aquí para analizar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryFixedDim,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 4. Botón Secundario: Subir foto de galería
          SizedBox(
            height: 58,
            child: OutlinedButton.icon(
              onPressed: viewModel.pickFromGalleryAndAnalyze,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLowest,
                side: const BorderSide(
                  color: AppColors.outlineVariant,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.secondary,
                size: 24,
              ),
              label: const Text(
                'Subir foto de galería',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 5. Divisor claro: O SI LO PREFIERE
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  color: AppColors.surfaceContainerHigh,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'O SI LO PREFIERE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: AppColors.surfaceContainerHigh,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 6. Botón Gigante Secundario: Hablar por micrófono
          Semantics(
            button: true,
            label:
                'Hablar por micrófono. Describa el obstáculo o pregunte sobre el camino.',
            child: Material(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openVoiceSheet(context),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 82),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: AppColors.secondary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hablar por micrófono',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Describa el obstáculo o pregunte sobre el camino',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.onSurfaceVariant,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 7. Selector de escenario de prueba (visible cuando aún no se conecta el backend)
          if (!viewModel.hasLiveBackend) ...[
            const SizedBox(height: 22),
            _DemoModeSelectorCard(viewModel: viewModel),
          ],
        ],
      ),
    );
  }
}

/// Selector para probar las 3 pantallas de resultado (Alto, Medio y Seguro) mientras el backend está en construcción.
class _DemoModeSelectorCard extends StatelessWidget {
  const _DemoModeSelectorCard({required this.viewModel});

  final ScanViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science_outlined,
                size: 20,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Modo Demostración (Simulador IA)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: viewModel.startAnalysis,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Probar directo →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Elija qué resultado simular al tomar o elegir una foto:',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ScenarioChip(
                label: 'Alto Riesgo',
                color: AppColors.dangerAccent,
                selected: viewModel.demoScenario == RiskLevel.alto,
                onTap: () => viewModel.setDemoScenario(RiskLevel.alto),
              ),
              const SizedBox(width: 8),
              _ScenarioChip(
                label: 'Riesgo Medio',
                color: AppColors.cautionAccent,
                selected: viewModel.demoScenario == RiskLevel.medio,
                onTap: () => viewModel.setDemoScenario(RiskLevel.medio),
              ),
              const SizedBox(width: 8),
              _ScenarioChip(
                label: 'Seguro',
                color: AppColors.safeGreenText,
                selected: viewModel.demoScenario == RiskLevel.bajo,
                onTap: () => viewModel.setDemoScenario(RiskLevel.bajo),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScenarioChip extends StatelessWidget {
  const _ScenarioChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.14)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : AppColors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected ? color : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Ilustración de fondo para el visor cuando aún no se captura una fotografía.
class _UrbanStreetPreviewBackground extends StatelessWidget {
  const _UrbanStreetPreviewBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StreetPerspectivePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _StreetPerspectivePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Cielo y entorno urbano suave
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF8FB5D8),
          Color(0xFFC5D8EC),
          Color(0xFF9BA8B5),
        ],
        stops: [0.0, 0.48, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Árboles difuminados al fondo
    final foliagePaint = Paint()..color = const Color(0xFF4F6F52);
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.36),
      65,
      foliagePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.34),
      75,
      foliagePaint,
    );

    // Acera y paso peatonal en perspectiva
    final roadPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.25, size.height * 0.48)
      ..lineTo(size.width * 0.75, size.height * 0.48)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      roadPath,
      Paint()..color = const Color(0xFFB4BDC7),
    );

    // Líneas de cruce peatonal
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final left = size.width * (0.22 + i * 0.15);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height * 0.63, size.width * 0.09, 16),
          const Radius.circular(4),
        ),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
