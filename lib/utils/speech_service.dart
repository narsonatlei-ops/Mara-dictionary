import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// One text-to-speech engine for the whole app
class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text, double rate) async {
    if (text.isEmpty) return;
    try {
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(rate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('Speech error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
