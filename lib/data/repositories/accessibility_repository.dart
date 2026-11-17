import '../../domain/models/accessibility_diagnosis.dart';
import '../services/accessibility_api_service.dart';

/// Repositorio único para evaluar la accesibilidad de un tramo urbano.
class AccessibilityRepository {
  AccessibilityRepository({required this._apiService});

  final AccessibilityApiService _apiService;

  /// Indica si se configuró `BACKEND_API_URL` por variable de entorno.
  bool get hasLiveBackend => _apiService.hasConfiguredBackend;

  /// Evalúa una imagen y/o consulta por voz.
  /// Si hay un backend configurado y [forceDemoMode] es `false`, consulta el servidor real;
  /// de lo contrario usa el escenario de demostración indicado en [demoScenario].
  Future<AccessibilityDiagnosis> evaluatePath({
    required RiskLevel demoScenario,
    String? imagePath,
    String? voicePrompt,
    bool forceDemoMode = false,
  }) async {
    if (hasLiveBackend && !forceDemoMode) {
      final apiModel = await _apiService.analyzeInfrastructure(
        imagePath: imagePath,
        voicePrompt: voicePrompt,
      );
      return apiModel.toDomain(
        imagePath: imagePath,
        userVoicePrompt: voicePrompt,
      );
    }

    final demoModel = await _apiService.fetchDemoDiagnosis(
      demoRiskLevel: demoScenario,
      voicePrompt: voicePrompt,
    );
    return demoModel.toDomain(
      imagePath: imagePath,
      userVoicePrompt: voicePrompt,
    );
  }
}
