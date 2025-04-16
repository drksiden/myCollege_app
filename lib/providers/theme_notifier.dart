import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  final String key = "themeMode";
  SharedPreferences? _prefs;
  late ThemeMode _themeMode;

  ThemeNotifier() {
    // Устанавливаем системную тему по умолчанию и загружаем сохраненную
    _themeMode = ThemeMode.system;
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;

  // Инициализация SharedPreferences
  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Загрузка сохраненного режима темы
  _loadFromPrefs() async {
    await _initPrefs();
    int? savedThemeModeIndex = _prefs!.getInt(key);

    if (savedThemeModeIndex == null) {
      _themeMode = ThemeMode.system; // По умолчанию системная
    } else {
      _themeMode = ThemeMode.values[savedThemeModeIndex];
    }
    notifyListeners(); // Уведомить слушателей после загрузки
  }

  // Сохранение выбранного режима темы
  _saveToPrefs() async {
    await _initPrefs();
    _prefs!.setInt(key, _themeMode.index);
  }

  // Метод для изменения темы
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return; // Ничего не делаем, если режим тот же

    _themeMode = mode;
    _saveToPrefs();
    notifyListeners(); // Уведомляем виджеты об изменении
  }

  // Удобный метод для переключения (например, для Switch)
  void toggleTheme(bool isDarkMode) {
    setThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  // Определяем, темная ли тема сейчас активна (учитывая системные настройки)
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    } else {
      return _themeMode == ThemeMode.dark;
    }
  }
}
