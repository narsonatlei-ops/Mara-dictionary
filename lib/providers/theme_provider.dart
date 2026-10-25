import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/synonym_service.dart';

class ThemeProvider with ChangeNotifier {
  static const _defaultColor = Color(0xFF13263B); // Navy

  bool _isDarkMode = false;
  double _fontSize = 16.0;
  double _speechRate = 0.5; // flutter_tts range 0.0 - 1.0 (0.5 = normal)
  Color _primaryColor = _defaultColor;
  bool _autoSpeak = false; // speak the word when it is opened on Home
  bool _fetchOnline = true; // get synonyms and antonyms from the internet
  bool _searchContains = false; // false = starts with, true = contains

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  double get speechRate => _speechRate;
  Color get primaryColor => _primaryColor;
  bool get autoSpeak => _autoSpeak;
  bool get fetchOnline => _fetchOnline;
  bool get searchContains => _searchContains;

  // Colour of the app bars: a darker shade in dark mode
  Color get headerColor => _isDarkMode
      ? Color.lerp(_primaryColor, Colors.black, 0.45)!
      : _primaryColor;

  // Called once at start-up to restore the saved settings
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontSize = (prefs.getDouble('fontSize') ?? 16.0)
        .clamp(12.0, 24.0)
        .toDouble();
    _speechRate = (prefs.getDouble('speechRate') ?? 0.5)
        .clamp(0.25, 1.0)
        .toDouble();
    final colorValue = prefs.getInt('primaryColor');
    if (colorValue != null) _primaryColor = Color(colorValue);
    _autoSpeak = prefs.getBool('autoSpeak') ?? false;
    _fetchOnline = prefs.getBool('fetchOnline') ?? true;
    _searchContains = prefs.getBool('searchContains') ?? false;

    SynonymService.enabled = _fetchOnline;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setDouble('speechRate', _speechRate);
    await prefs.setInt('primaryColor', _primaryColor.toARGB32());
    await prefs.setBool('autoSpeak', _autoSpeak);
    await prefs.setBool('fetchOnline', _fetchOnline);
    await prefs.setBool('searchContains', _searchContains);
  }

  // Every setter tells the screens to rebuild and keeps the value
  void _changed() {
    notifyListeners();
    _save();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _changed();
  }

  void setFontSize(double size) {
    _fontSize = size;
    _changed();
  }

  void setSpeechRate(double rate) {
    _speechRate = rate;
    _changed();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    _changed();
  }

  void setAutoSpeak(bool value) {
    _autoSpeak = value;
    _changed();
  }

  void setFetchOnline(bool value) {
    _fetchOnline = value;
    SynonymService.enabled = value;
    _changed();
  }

  void setSearchContains(bool value) {
    _searchContains = value;
    _changed();
  }

  // Settings only: favorites and history are not touched
  void resetToDefaults() {
    _isDarkMode = false;
    _fontSize = 16.0;
    _speechRate = 0.5;
    _primaryColor = _defaultColor;
    _autoSpeak = false;
    _fetchOnline = true;
    _searchContains = false;
    SynonymService.enabled = true;
    _changed();
  }
}
