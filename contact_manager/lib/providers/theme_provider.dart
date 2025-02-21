import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Color _appBarColor = Colors.blue; // 🔥 Couleur par défaut

  Color get appBarColor => _appBarColor;

  ThemeProvider() {
    _loadTheme(); // Charger la couleur enregistrée au démarrage
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt('appBarColor');
    if (colorValue != null) {
      _appBarColor = Color(colorValue);
      notifyListeners();
    }
  }

  Future<void> setAppBarColor(Color color) async {
    _appBarColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'appBarColor', color.value); // 🔥 Sauvegarde de la couleur
  }
}
