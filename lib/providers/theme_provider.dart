import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSize = 16.0;
  double _speechRate = 1.0;
  Color _primaryColor = const Color(0xFF1976D2); // A tirah Blue

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  double get speechRate => _speechRate;
  Color get primaryColor => _primaryColor;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void setSpeechRate(double rate) {
    _speechRate = rate;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }
}
