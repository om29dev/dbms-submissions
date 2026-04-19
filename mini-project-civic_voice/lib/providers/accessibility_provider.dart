import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ColorBlindMode { none, protanopia, deuteranopia, tritanopia }

class AccessibilityProvider with ChangeNotifier {
  static const String _highContrastKey = 'acc_high_contrast';
  static const String _textScaleKey = 'acc_text_scale';
  static const String _colorBlindKey = 'acc_color_blind';

  bool _isHighContrast = false;
  double _textScaleFactor = 1.0;
  ColorBlindMode _colorBlindMode = ColorBlindMode.none;

  bool get isHighContrast => _isHighContrast;
  double get textScaleFactor => _textScaleFactor;
  ColorBlindMode get colorBlindMode => _colorBlindMode;

  AccessibilityProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isHighContrast = prefs.getBool(_highContrastKey) ?? false;
    _textScaleFactor = prefs.getDouble(_textScaleKey) ?? 1.0;
    _colorBlindMode = ColorBlindMode.values[prefs.getInt(_colorBlindKey) ?? 0];
    notifyListeners();
  }

  Future<void> toggleHighContrast(bool value) async {
    _isHighContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, value);
    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    _textScaleFactor = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, value);
    notifyListeners();
  }

  Future<void> setColorBlindMode(ColorBlindMode mode) async {
    _colorBlindMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorBlindKey, mode.index);
    notifyListeners();
  }

  // Returns a ColorFilter based on the selected mode
  ColorFilter? get colorFilter {
    switch (_colorBlindMode) {
      case ColorBlindMode.protanopia:
        // Correction for Protanopia (Red-Blind): Shift Red intensity into Blue channel
        // This helps distinguish Red items (now appearing bluish/purple) from Green/Black.
        return const ColorFilter.matrix([
          1.0, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.7, 0.0, 1.0, 0.0, 0.0, // Inject Red into Blue
          0.0, 0.0, 0.0, 1.0, 0.0,
        ]);
      case ColorBlindMode.deuteranopia:
        // Correction for Deuteranopia (Green-Blind): Shift Green intensity into Blue channel
        // This helps distinguish Green items (now appearing bluish/cyan) from Red/Black.
        return const ColorFilter.matrix([
          1.0, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.7, 1.0, 0.0, 0.0, // Inject Green into Blue
          0.0, 0.0, 0.0, 1.0, 0.0,
        ]);
      case ColorBlindMode.tritanopia:
        // Correction for Tritanopia (Blue-Blind): Shift Blue intensity into Red channel
        // This helps distinguish Blue items (now appearing reddish) from Yellow/Black.
        return const ColorFilter.matrix([
          1.0, 0.0, 0.7, 0.0, 0.0, // Inject Blue into Red
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ]);
      default:
        return null;
    }
  }
}
