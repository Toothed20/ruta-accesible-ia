import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Servicio que administra la lectura en voz alta (TTS) y el dictado por voz (STT).
class VoiceAssistantService {
  VoiceAssistantService()
    : _tts = FlutterTts(),
      _speech = SpeechToText();

  final FlutterTts _tts;
  final SpeechToText _speech;
  bool _ttsInitialized = false;
  bool _speechAvailable = false;

  /// Inicializa el motor de voz en español de México.
  Future<void> initTts({
    required VoidCallback onStart,
    required VoidCallback onComplete,
  }) async {
    if (_ttsInitialized) return;
    try {
      await _tts.setLanguage('es-MX');
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      _tts.setStartHandler(onStart);
      _tts.setCompletionHandler(onComplete);
      _tts.setCancelHandler(onComplete);
      _tts.setErrorHandler((_) => onComplete());

      _ttsInitialized = true;
    } catch (_) {
      // Si el motor de voz no está disponible en el entorno actual, falla de forma silenciosa
    }
  }

  /// Lee un mensaje en voz alta.
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Ignorar si la plataforma no soporta TTS
    }
  }

  /// Detiene inmediatamente cualquier lectura en curso.
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignorar si no estaba hablando
    }
  }

  /// Inicia la escucha por micrófono y envía el texto reconocido en tiempo real.
  Future<bool> startListening({
    required ValueChanged<String> onResult,
    required VoidCallback onStatusDone,
  }) async {
    try {
      await stopSpeaking();
      if (!_speechAvailable) {
        _speechAvailable = await _speech.initialize(
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              onStatusDone();
            }
          },
          onError: (_) => onStatusDone(),
        );
      }

      if (!_speechAvailable) {
        return false;
      }

      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Detiene el micrófono.
  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {
      // Ignorar errores al detener el micrófono
    }
  }
}
