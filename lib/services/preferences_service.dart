import 'package:hive/hive.dart';

/// Servicio que maneja la lectura y escritura de preferencias usando Hive.
class PreferencesService {
  /// Nombre de la caja (archivo de almacenamiento local en Hive).
  static const String _boxName = 'preferences_box';

  /// Clave donde se guarda el valor del tema (claro u oscuro).
  static const String _themeKey = 'isDarkMode';

  /// Guarda el valor de tema (true = oscuro, false = claro) en Hive.
  static Future<void> setDarkMode(bool isDark) async {
    final box = await Hive.openBox(_boxName); // abre o crea la caja
    await box.put(_themeKey, isDark); // guarda el valor con la clave 'isDarkMode'
  }

  /// Lee el valor del tema desde Hive. Si no hay nada guardado, regresa `false`.
  static Future<bool> getDarkMode() async {
    final box = await Hive.openBox(_boxName); // abre la caja
    return box.get(_themeKey, defaultValue: false); // lee el valor guardado
  }
}
