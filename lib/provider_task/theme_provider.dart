import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

/// Clase que maneja el tema claro/oscuro de la app.
class ThemeProvider with ChangeNotifier {
  /// Variable privada que guarda si el tema actual es oscuro.
  bool _isDarkMode = false;

  /// Getter para saber si el tema actual es oscuro (usado por la UI).
  bool get isDarkMode => _isDarkMode;

  /// Constructor: cuando se crea esta clase, carga el tema guardado con Hive.
  ThemeProvider() {
    loadTheme();
  }

  /// Carga el valor del tema desde Hive y notifica a la app para que actualice.
  Future<void> loadTheme() async {
    _isDarkMode = await PreferencesService.getDarkMode(); // lee de Hive
    notifyListeners(); // avisa a los widgets que usen este provider
  }

  /// Cambia entre tema claro y oscuro, guarda el valor en Hive y notifica a la app.
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode; // cambia el valor a su opuesto
    await PreferencesService.setDarkMode(_isDarkMode); // guarda en Hive
    notifyListeners(); // actualiza la interfaz
  }
}
