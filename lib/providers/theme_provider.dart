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

  // Dark mode switch-na
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Font size thlakna
  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  // Pronunciation speed thlakna
  void setSpeechRate(double rate) {
    _speechRate = rate;
    notifyListeners();
  }

  // Theme Rawng thlakna
  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }
}
