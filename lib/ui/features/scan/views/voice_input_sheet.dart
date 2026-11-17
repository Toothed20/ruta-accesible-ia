import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/scan_view_model.dart';

/// Panel inferior de alta accesibilidad para dictar por micrófono o escribir una consulta sobre el camino.
class VoiceInputSheet extends StatefulWidget {
  const VoiceInputSheet({
    super.key,
    required this.viewModel,
  });

  final ScanViewModel viewModel;

  @override
  State<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<VoiceInputSheet> {
  late final TextEditingController _controller;
  bool _micUnavailableWarning = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.viewModel.voicePrompt);
  }

  @override
  void dispose() {
    widget.viewModel.stopMicListening();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleMicToggle() async {
    final started = await widget.viewModel.toggleMicListening(
      onWordsRecognized: (words) {
        if (!mounted) return;
        _controller.text = words;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      },
    );
    if (!started && mounted) {
      setState(() {
        _micUnavailableWarning = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final isListening = widget.viewModel.isListeningMic;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.record_voice_over_rounded,
                          color: AppColors.secondary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dictar obstáculo por voz',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Describa lo que ve o haga una pregunta',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    onChanged: widget.viewModel.updateVoicePrompt,
                    decoration: InputDecoration(
                      hintText:
                          'Ejemplo: "Hay un auto estacionado sobre la rampa, ¿es seguro pasar?"',
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: AppColors.outline,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.outlineVariant,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.secondary,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                  if (_micUnavailableWarning) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cautionBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cautionAccent),
                      ),
                      child: const Text(
                        'El reconocimiento de voz no está activo o requiere permiso de micrófono. Puede escribir su descripción arriba.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cautionTitle,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: OutlinedButton.icon(
                      onPressed: _handleMicToggle,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isListening
                            ? AppColors.dangerBackground
                            : AppColors.surfaceContainer,
                        side: BorderSide(
                          color: isListening
                              ? AppColors.dangerAccent
                              : AppColors.secondary,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(
                        isListening ? Icons.stop_circle_rounded : Icons.mic,
                        size: 28,
                        color: isListening
                            ? AppColors.dangerAccent
                            : AppColors.secondary,
                      ),
                      label: Text(
                        isListening
                            ? 'Escuchando... (Toque para detener)'
                            : 'Tocar para dictar con micrófono',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isListening
                              ? AppColors.dangerTitle
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final text = _controller.text.trim();
                        Navigator.of(context).pop();
                        widget.viewModel.startAnalysis(customVoicePrompt: text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.send_rounded, size: 24),
                      label: const Text(
                        'Analizar con esta descripción',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
