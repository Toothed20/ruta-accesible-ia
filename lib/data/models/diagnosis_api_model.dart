import '../../domain/models/accessibility_diagnosis.dart';

/// Modelo de datos para serializar y deserializar la respuesta del backend en Python.
/// Soporta tanto respuestas en JSON estructurado como el texto directo de Gemini
/// mostrado en el Caso de Estudio.
class DiagnosisApiModel {
  const DiagnosisApiModel({
    required this.hasRamp,
    required this.headline,
    required this.obstacles,
    required this.riskLevel,
    required this.recommendation,
    required this.audioMessage,
  });

  final bool hasRamp;
  final String headline;
  final String obstacles;
  final String riskLevel;
  final String recommendation;
  final String audioMessage;

  /// Crea una instancia a partir de un mapa JSON del backend.
  factory DiagnosisApiModel.fromJson(Map<String, dynamic> json) {
    // Si el backend envía el texto crudo de Gemini dentro de un campo "resultado" o "text"
    final rawResult = json['resultado'] ?? json['result'] ?? json['text'];
    if (rawResult is String &&
        !json.containsKey('riesgo') &&
        !json.containsKey('risk_level') &&
        !json.containsKey('nivel_riesgo')) {
      return DiagnosisApiModel.fromRawText(rawResult);
    }

    final rawRamp =
        json['tiene_rampa'] ?? json['rampa'] ?? json['has_ramp'] ?? false;
    final bool parsedRamp = switch (rawRamp) {
      final bool b => b,
      final String s =>
        s.toLowerCase().contains('sí') ||
            s.toLowerCase().contains('si') ||
            s.toLowerCase().contains('true'),
      _ => false,
    };

    final String parsedRisk =
        (json['nivel_riesgo'] ??
                json['riesgo'] ??
                json['risk_level'] ??
                'Medio')
            .toString();

    final String parsedObstacles =
        (json['obstaculos'] ??
                json['obstaculos_detectados'] ??
                json['obstacles'] ??
                'Sin obstáculos adicionales reportados.')
            .toString();

    final String parsedHeadline =
        (json['titulo'] ??
                json['resumen'] ??
                json['headline'] ??
                _defaultHeadlineForRisk(parsedRisk))
            .toString();

    final String parsedAudio =
        (json['mensaje_audio'] ??
                json['advertencia_auditiva'] ??
                json['audio_message'] ??
                json['recomendacion'] ??
                parsedObstacles)
            .toString();

    final String parsedRecommendation =
        (json['recomendacion'] ??
                json['que_hacer'] ??
                json['recommendation'] ??
                parsedAudio)
            .toString();

    return DiagnosisApiModel(
      hasRamp: parsedRamp,
      headline: parsedHeadline,
      obstacles: parsedObstacles,
      riskLevel: parsedRisk,
      recommendation: parsedRecommendation,
      audioMessage: parsedAudio,
    );
  }

  /// Interpreta una respuesta en texto plano estructurado en 4 puntos (tal como el script del PDF).
  factory DiagnosisApiModel.fromRawText(String rawText) {
    final lower = rawText.toLowerCase();
    final hasRamp =
        lower.contains('rampa: sí') ||
        lower.contains('rampa? sí') ||
        lower.contains('1. sí') ||
        lower.contains('1. si') ||
        (lower.contains('sí') && !lower.contains('no cuenta con rampa'));

    String riskLevel = 'Medio';
    if (lower.contains('alto')) {
      riskLevel = 'Alto';
    } else if (lower.contains('bajo')) {
      riskLevel = 'Bajo';
    }

    return DiagnosisApiModel(
      hasRamp: hasRamp,
      headline: _defaultHeadlineForRisk(riskLevel),
      obstacles: rawText.trim(),
      riskLevel: riskLevel,
      recommendation:
          'Revise las indicaciones auditivas antes de avanzar por este tramo.',
      audioMessage: rawText.replaceAll('\n', ' ').trim(),
    );
  }

  static String _defaultHeadlineForRisk(String risk) {
    final normalized = risk.toLowerCase();
    if (normalized.contains('alto')) {
      return 'La banqueta presenta obstáculos de alto riesgo.';
    }
    if (normalized.contains('medio')) {
      return 'Banqueta con obstáculos moderados; avance con precaución.';
    }
    return 'Esta banqueta es plana y segura para avanzar.';
  }

  Map<String, dynamic> toJson() {
    return {
      'tiene_rampa': hasRamp,
      'titulo': headline,
      'obstaculos_detectados': obstacles,
      'nivel_riesgo': riskLevel,
      'recomendacion': recommendation,
      'advertencia_auditiva': audioMessage,
    };
  }

  AccessibilityDiagnosis toDomain({
    String? imagePath,
    String? userVoicePrompt,
  }) {
    return AccessibilityDiagnosis(
      hasRamp: hasRamp,
      headline: headline,
      obstaclesDescription: obstacles,
      riskLevel: RiskLevel.fromString(riskLevel),
      actionRecommendation: recommendation,
      audioWarningMessage: audioMessage,
      imagePath: imagePath,
      userVoicePrompt: userVoicePrompt,
    );
  }
}
