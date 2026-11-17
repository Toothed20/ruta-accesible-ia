/// Niveles de riesgo de accesibilidad peatonal definidos en el Caso de Estudio.
enum RiskLevel {
  bajo,
  medio,
  alto;

  /// Convierte un texto proveniente del backend de IA a [RiskLevel].
  static RiskLevel fromString(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('alto') ||
        normalized.contains('peligro') ||
        normalized.contains('crítico') ||
        normalized.contains('critico')) {
      return RiskLevel.alto;
    }
    if (normalized.contains('medio') ||
        normalized.contains('moderado') ||
        normalized.contains('precaución') ||
        normalized.contains('precaucion')) {
      return RiskLevel.medio;
    }
    return RiskLevel.bajo;
  }

  /// Etiqueta principal que se muestra en la tarjeta de diagnóstico rápido.
  String get badgeTitle {
    return switch (this) {
      RiskLevel.bajo => 'CAMINO SEGURO',
      RiskLevel.medio => 'RIESGO MEDIO',
      RiskLevel.alto => 'ALTO RIESGO',
    };
  }

  /// Etiqueta corta sobre la foto analizada.
  String get photoBadgeLabel {
    return switch (this) {
      RiskLevel.bajo => 'Lugar analizado (Paso libre)',
      RiskLevel.medio => 'Lugar analizado (Precaución)',
      RiskLevel.alto => 'Lugar analizado',
    };
  }
}

/// Modelo de dominio con los 4 puntos de evaluación de RutaAccesible IA.
class AccessibilityDiagnosis {
  const AccessibilityDiagnosis({
    required this.hasRamp,
    required this.headline,
    required this.obstaclesDescription,
    required this.riskLevel,
    required this.actionRecommendation,
    required this.audioWarningMessage,
    this.imagePath,
    this.userVoicePrompt,
  });

  /// 1. ¿Cuenta con rampa? (Sí / No)
  final bool hasRamp;

  /// Resumen directo en una frase (ej. "La banqueta está rota y es muy peligrosa.")
  final String headline;

  /// 2. Obstáculos detectados explicados con lenguaje claro.
  final String obstaclesDescription;

  /// 3. Nivel de riesgo (Bajo / Medio / Alto).
  final RiskLevel riskLevel;

  /// Recomendación práctica para la tarjeta "¿Qué hacer ahora?".
  final String actionRecommendation;

  /// 4. Mensaje corto de advertencia auditiva (para lectura en voz alta).
  final String audioWarningMessage;

  /// Ruta local de la fotografía capturada o seleccionada (si existe).
  final String? imagePath;

  /// Pregunta o descripción dictada por voz por el usuario (opcional).
  final String? userVoicePrompt;

  /// Etiqueta clara para la tarjeta "¿TIENE RAMPA?".
  String get rampStatusText => hasRamp ? 'SÍ TIENE RAMPA' : 'NO TIENE RAMPA';
}
