import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domain/models/accessibility_diagnosis.dart';
import '../models/diagnosis_api_model.dart';

/// Servicio de red encargado de comunicarse con el backend en Python.
///
/// La dirección del servidor se obtiene por variable de entorno:
/// `--dart-define=BACKEND_API_URL=http://TU_IP:PUERTO/evaluar`
class AccessibilityApiService {
  AccessibilityApiService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// URL del endpoint configurada mediante variable de entorno (sin credenciales en código).
  static const String backendApiUrl = String.fromEnvironment('BACKEND_API_URL');

  /// Indica si ya hay un endpoint real configurado.
  bool get hasConfiguredBackend => backendApiUrl.trim().isNotEmpty;

  /// Envía la imagen y/o consulta por voz al backend en Python.
  Future<DiagnosisApiModel> analyzeInfrastructure({
    String? imagePath,
    String? voicePrompt,
  }) async {
    if (!hasConfiguredBackend) {
      throw StateError(
        'No se ha configurado BACKEND_API_URL en las variables de entorno.',
      );
    }

    final uri = Uri.parse(backendApiUrl.trim());

    if (imagePath != null && File(imagePath).existsSync()) {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagePath),
      );
      if (voicePrompt != null && voicePrompt.trim().isNotEmpty) {
        request.fields['consulta_voz'] = voicePrompt.trim();
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      return _parseResponse(response);
    } else {
      final response = await _client.post(
        uri,
        headers: const {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'consulta_voz': voicePrompt ?? '',
        }),
      );
      return _parseResponse(response);
    }
  }

  DiagnosisApiModel _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final bodyText = utf8.decode(response.bodyBytes).trim();
      try {
        final dynamic decoded = jsonDecode(bodyText);
        if (decoded is Map<String, dynamic>) {
          return DiagnosisApiModel.fromJson(decoded);
        }
      } catch (_) {
        // Si el backend responde texto plano directo de Gemini
      }
      return DiagnosisApiModel.fromRawText(bodyText);
    }
    throw HttpException(
      'Error del servidor (${response.statusCode}): ${response.reasonPhrase}',
    );
  }

  /// Respuestas de demostración fieles a las pantallas diseñadas en Google Stitch v2
  /// para probar los 3 estados mientras se conecta el backend.
  Future<DiagnosisApiModel> fetchDemoDiagnosis({
    required RiskLevel demoRiskLevel,
    String? voicePrompt,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 2400));

    final hasVoiceQuestion =
        voicePrompt != null && voicePrompt.trim().isNotEmpty;

    return switch (demoRiskLevel) {
      RiskLevel.alto => DiagnosisApiModel(
        hasRamp: false,
        headline: 'La banqueta está rota y es muy peligrosa.',
        obstacles: hasVoiceQuestion
            ? 'Respecto a su consulta ("${voicePrompt.trim()}"): Hay un escalón alto, banqueta fracturada y hoyos difíciles de pasar con silla de ruedas o bastón.'
            : 'Hay un escalón alto y el piso tiene hoyos difíciles de pasar con silla de ruedas o bastón.',
        riskLevel: 'Alto',
        recommendation:
            'Cruce por la esquina de enfrente: esa sí tiene rampa plana y segura.',
        audioMessage:
            'Atención: Alto riesgo. La banqueta está rota y es muy peligrosa. No tiene rampa de acceso. Le sugerimos cruzar por la esquina de enfrente que sí cuenta con rampa plana y segura.',
      ),
      RiskLevel.medio => DiagnosisApiModel(
        hasRamp: true,
        headline: 'Banqueta estrecha con desnivel moderado.',
        obstacles: hasVoiceQuestion
            ? 'Respecto a su consulta ("${voicePrompt.trim()}"): El pavimento presenta ligeras irregularidades y la inclinación es continua. Hay paso para silla de ruedas o bastón, pero requiere atención.'
            : 'Avance con precaución. El pavimento presenta ligeras irregularidades y la inclinación es continua. Hay paso para silla de ruedas o bastón, pero requiere atención y velocidad reducida.',
        riskLevel: 'Medio',
        recommendation:
            'Sujétese con ambas manos y avance por el costado derecho donde la acera está más despejada. Si usa silla eléctrica, mantenga velocidad baja.',
        audioMessage:
            'Diagnóstico rápido: Riesgo medio. Banqueta estrecha con desnivel moderado. Sí cuenta con rampa, pero presenta pendiente continua. Avance por el costado derecho a velocidad baja.',
      ),
      RiskLevel.bajo => DiagnosisApiModel(
        hasRamp: true,
        headline: 'Esta banqueta es plana y segura para avanzar.',
        obstacles: hasVoiceQuestion
            ? 'Respecto a su consulta ("${voicePrompt.trim()}"): No hay escalones ni baches. La rampa está despejada y tiene buen espacio para silla de ruedas, andador o bastón.'
            : 'No hay escalones ni baches. La rampa está despejada y tiene buen espacio para silla de ruedas, andador o bastón.',
        riskLevel: 'Bajo',
        recommendation:
            'Puede cruzar con tranquilidad por la rampa señalizada. El paso peatonal se encuentra libre de obstáculos.',
        audioMessage:
            'Diagnóstico rápido: Camino seguro. Esta banqueta es plana y segura para avanzar. Sí tiene rampa despejada y sin baches. Puede cruzar con tranquilidad.',
      ),
    };
  }
}
