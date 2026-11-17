import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Encabezado superior accesible de RutaAccesible IA (fiel al diseño de Google Stitch v2).
class RutaHeader extends StatelessWidget {
  const RutaHeader({
    super.key,
    required this.title,
    required this.autoVoiceEnabled,
    required this.onToggleAutoVoice,
    this.showBackButton = false,
    this.onBack,
  });

  final String title;
  final bool autoVoiceEnabled;
  final VoidCallback onToggleAutoVoice;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            Semantics(
              button: true,
              label: 'Volver a la pantalla anterior',
              child: Material(
                color: AppColors.surfaceContainerHigh,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack,
                  child: const SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 26,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RUTAACCESIBLE IA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            toggled: autoVoiceEnabled,
            label: autoVoiceEnabled
                ? 'Asistencia por voz activada. Toque para silenciar.'
                : 'Asistencia por voz desactivada. Toque para activar.',
            child: Material(
              color: autoVoiceEnabled
                  ? AppColors.secondaryContainer
                  : AppColors.surfaceContainerHigh,
              shape: const CircleBorder(),
              elevation: autoVoiceEnabled ? 3 : 0,
              shadowColor: AppColors.secondary.withValues(alpha: 0.35),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onToggleAutoVoice,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(
                    autoVoiceEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    size: 28,
                    color: autoVoiceEnabled
                        ? Colors.white
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
