import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSize = 16.0;
  double _speechRate = 0.5; // flutter_tts range 0.0 - 1.0 (0.5 = normal)
  Color _primaryColor = const Color(0xFF13263B); // Navy

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  double get speechRate => _speechRate;
  Color get primaryColor => _primaryColor;

  // Colour of the app bars: a darker shade in dark mode
  Color get headerColor => _isDarkMode
      ? Color.lerp(_primaryColor, Colors.black, 0.45)!
      : _primaryColor;

  // Called once at start-up to restore the saved settings
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _speechRate = (prefs.getDouble('speechRate') ?? 0.5)
        .clamp(0.25, 1.0)
        .toDouble();
    final colorValue = prefs.getInt('primaryColor');
    if (colorValue != null) _primaryColor = Color(colorValue);
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setDouble('speechRate', _speechRate);
    await prefs.setInt('primaryColor', _primaryColor.toARGB32());
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _save();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
    _save();
  }

  void setSpeechRate(double rate) {
    _speechRate = rate;
    notifyListeners();
    _save();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
    _save();
  }
}
