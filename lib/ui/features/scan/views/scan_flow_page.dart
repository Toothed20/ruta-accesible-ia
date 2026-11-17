import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ruta_header.dart';
import '../view_models/scan_view_model.dart';
import 'analyzing_view.dart';
import 'diagnosis_result_view.dart';
import 'scan_home_view.dart';

/// Contenedor principal del flujo de escaneo y resultados de RutaAccesible IA.
class ScanFlowPage extends StatelessWidget {
  const ScanFlowPage({
    super.key,
    required this.viewModel,
  });

  final ScanViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final step = viewModel.currentStep;
        final isHome = step == ScanStep.home;

        return PopScope(
          canPop: isHome,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              if (step == ScanStep.analyzing) {
                viewModel.cancelAnalysis();
              } else {
                viewModel.resetToHome();
              }
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.surface,
            body: SafeArea(
              child: Column(
                children: [
                  RutaHeader(
                    title: step == ScanStep.analyzing
                        ? 'Navegación Activa'
                        : 'Navegación En Vivo',
                    autoVoiceEnabled: viewModel.autoVoiceEnabled,
                    onToggleAutoVoice: viewModel.toggleAutoVoice,
                    showBackButton: !isHome,
                    onBack: () {
                      if (step == ScanStep.analyzing) {
                        viewModel.cancelAnalysis();
                      } else {
                        viewModel.resetToHome();
                      }
                    },
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: switch (step) {
                        ScanStep.home => ScanHomeView(
                          key: const ValueKey('scan_home'),
                          viewModel: viewModel,
                        ),
                        ScanStep.analyzing => AnalyzingView(
                          key: const ValueKey('scan_analyzing'),
                          viewModel: viewModel,
                        ),
                        ScanStep.result => DiagnosisResultView(
                          key: const ValueKey('scan_result'),
                          viewModel: viewModel,
                          diagnosis: viewModel.diagnosis!,
                        ),
                      },
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
