import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/repositories/accessibility_repository.dart';
import '../../../../data/services/voice_assistant_service.dart';
import '../../../../domain/models/accessibility_diagnosis.dart';

/// Etapas del flujo principal de RutaAccesible IA.
enum ScanStep {
  home,
  analyzing,
  result,
}

/// ViewModel principal que gestiona el estado de captura, análisis con IA y voz.
class ScanViewModel extends ChangeNotifier {
  ScanViewModel({
    required this._repository,
    required this._voiceService,
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker() {
    _initVoice();
  }

  final AccessibilityRepository _repository;
  final VoiceAssistantService _voiceService;
  final ImagePicker _imagePicker;

  ScanStep _currentStep = ScanStep.home;
  ScanStep get currentStep => _currentStep;

  String? _selectedImagePath;
  String? get selectedImagePath => _selectedImagePath;

  String _voicePrompt = '';
  String get voicePrompt => _voicePrompt;

  bool _autoVoiceEnabled = true;
  bool get autoVoiceEnabled => _autoVoiceEnabled;

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  bool _isListeningMic = false;
  bool get isListeningMic => _isListeningMic;

  RiskLevel _demoScenario = RiskLevel.alto;
  RiskLevel get demoScenario => _demoScenario;

  AccessibilityDiagnosis? _diagnosis;
  AccessibilityDiagnosis? get diagnosis => _diagnosis;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _activeRequestId = 0;

  bool get hasLiveBackend => _repository.hasLiveBackend;

  Future<void> _initVoice() async {
    await _voiceService.initTts(
      onStart: () {
        _isSpeaking = true;
        notifyListeners();
      },
      onComplete: () {
        _isSpeaking = false;
        notifyListeners();
      },
    );
  }

  /// Cambia el escenario de demostración (Bajo, Medio o Alto) para pruebas sin backend.
  void setDemoScenario(RiskLevel level) {
    if (_demoScenario == level) return;
    _demoScenario = level;
    notifyListeners();
  }

  /// Activa o desactiva la lectura automática en voz alta.
  Future<void> toggleAutoVoice() async {
    _autoVoiceEnabled = !_autoVoiceEnabled;
    notifyListeners();

    if (!_autoVoiceEnabled) {
      await _voiceService.stopSpeaking();
    } else {
      await _voiceService.speak(
        'Asistencia por voz activada. Apunte al frente y toque Revisar Camino.',
      );
    }
  }

  /// Toma una fotografía con la cámara del teléfono Android y analiza el camino.
  Future<void> captureWithCameraAndAnalyze() async {
    _errorMessage = null;
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (photo == null) {
        return; // El usuario canceló la cámara
      }
      _selectedImagePath = photo.path;
      await startAnalysis();
    } catch (_) {
      // Si la cámara no está disponible o se prueba rápido, ejecutamos el análisis con vista previa
      await startAnalysis();
    }
  }

  /// Selecciona una fotografía de la galería del teléfono y la analiza.
  Future<void> pickFromGalleryAndAnalyze() async {
    _errorMessage = null;
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (image == null) {
        return; // El usuario cerró la galería sin elegir foto
      }
      _selectedImagePath = image.path;
      await startAnalysis();
    } catch (_) {
      _errorMessage = 'No se pudo abrir la galería de imágenes.';
      notifyListeners();
    }
  }

  /// Ejecuta el flujo de análisis pasando por la pantalla "Analizando el camino con IA...".
  Future<void> startAnalysis({String? customVoicePrompt}) async {
    if (customVoicePrompt != null) {
      _voicePrompt = customVoicePrompt.trim();
    }

    final int requestId = ++_activeRequestId;
    _errorMessage = null;
    _currentStep = ScanStep.analyzing;
    notifyListeners();

    if (_autoVoiceEnabled) {
      await _voiceService.speak(
        'Analizando el camino con inteligencia artificial. Espere unos segundos.',
      );
    }

    try {
      final result = await _repository.evaluatePath(
        demoScenario: _demoScenario,
        imagePath: _selectedImagePath,
        voicePrompt: _voicePrompt.isEmpty ? null : _voicePrompt,
      );

      // Verificar que el usuario no haya cancelado el análisis mientras esperaba
      if (requestId != _activeRequestId || _currentStep != ScanStep.analyzing) {
        return;
      }

      _diagnosis = result;
      _currentStep = ScanStep.result;
      notifyListeners();

      if (_autoVoiceEnabled) {
        await _voiceService.speak(result.audioWarningMessage);
      }
    } catch (e) {
      if (requestId != _activeRequestId) return;
      _errorMessage =
          'No se pudo conectar con el servidor de análisis. Verifique la conexión o pruebe el modo demostración.';
      _currentStep = ScanStep.home;
      notifyListeners();
    }
  }

  /// Cancela el análisis en curso y regresa a la pantalla inicial.
  Future<void> cancelAnalysis() async {
    _activeRequestId++;
    await _voiceService.stopSpeaking();
    _currentStep = ScanStep.home;
    notifyListeners();
  }

  /// Regresa a la pantalla de escaneo para evaluar otro lugar.
  Future<void> resetToHome() async {
    _activeRequestId++;
    await _voiceService.stopSpeaking();
    _currentStep = ScanStep.home;
    _voicePrompt = '';
    _errorMessage = null;
    notifyListeners();
  }

  /// Reproduce o detiene la lectura en voz alta del diagnóstico en la pantalla de resultados.
  Future<void> toggleSpeakDiagnosis() async {
    final currentDiagnosis = _diagnosis;
    if (currentDiagnosis == null) return;

    if (_isSpeaking) {
      await _voiceService.stopSpeaking();
      _isSpeaking = false;
      notifyListeners();
    } else {
      await _voiceService.speak(currentDiagnosis.audioWarningMessage);
    }
  }

  /// Actualiza manualmente el texto de consulta por voz/teclado.
  void updateVoicePrompt(String value) {
    _voicePrompt = value;
    notifyListeners();
  }

  /// Inicia o detiene el dictado por micrófono.
  Future<bool> toggleMicListening({
    required ValueChanged<String> onWordsRecognized,
  }) async {
    if (_isListeningMic) {
      await _voiceService.stopListening();
      _isListeningMic = false;
      notifyListeners();
      return true;
    }

    final started = await _voiceService.startListening(
      onResult: (words) {
        _voicePrompt = words;
        onWordsRecognized(words);
        notifyListeners();
      },
      onStatusDone: () {
        _isListeningMic = false;
        notifyListeners();
      },
    );

    _isListeningMic = started;
    notifyListeners();
    return started;
  }

  Future<void> stopMicListening() async {
    if (_isListeningMic) {
      await _voiceService.stopListening();
      _isListeningMic = false;
      notifyListeners();
    }
  }
}
