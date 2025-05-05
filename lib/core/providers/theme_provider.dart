// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ключ для сохранения темы
const String _themePrefsKey = 'appThemeMode';

// 1. Определяем StateNotifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // Получаем ссылку на Reader для доступа к SharedPreferences в будущем (если нужно)
  // Либо передаем SharedPreferences через конструктор
  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    // Загружаем сохраненную тему при инициализации
    _loadTheme();
  }

  final SharedPreferences _prefs;

  // Загрузка темы
  void _loadTheme() {
    final savedThemeIndex = _prefs.getInt(_themePrefsKey);
    if (savedThemeIndex != null && savedThemeIndex < ThemeMode.values.length) {
      state = ThemeMode.values[savedThemeIndex];
    } else {
      state = ThemeMode.system; // По умолчанию системная
    }
  }

  // Установка и сохранение новой темы
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return; // Ничего не делаем, если режим тот же
    state = mode;
    await _prefs.setInt(_themePrefsKey, mode.index);
  }

  // Удобный метод для Switch (если нужен будет)
  Future<void> toggleTheme(bool isDarkMode) async {
    await setThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  // Метод для определения текущей яркости (учитывая системную)
  Brightness getCurrentBrightness(BuildContext context) {
    switch (state) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        // Используем MediaQuery.platformBrightnessOf вместо deprecated platformBrightness
        return MediaQuery.platformBrightnessOf(context);
    }
  }

  // Удобный getter для проверки, активна ли темная тема
  bool isDarkMode(BuildContext context) =>
      getCurrentBrightness(context) == Brightness.dark;
}

// 2. Определяем Provider
// Используем FutureProvider для асинхронной инициализации SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

// Провайдер для нашего ThemeNotifier
// Он зависит от sharedPreferencesProvider
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  // Следим за FutureProvider, получаем SharedPreferences когда они готовы
  final prefs = ref
      .watch(sharedPreferencesProvider)
      .maybeWhen(
        data: (value) => value, // Если данные готовы, используем их
        orElse:
            () =>
                null, // Иначе null (в этом случае Notifier не создастся пока prefs не готовы)
      );

  // Важно: Создаем Notifier только когда SharedPreferences готовы
  if (prefs != null) {
    return ThemeNotifier(prefs);
  }
  // Пока SharedPreferences грузятся, можно вернуть "заглушку" или обработать иначе,
  // но зависимость от FutureProvider гарантирует, что Notifier создастся после загрузки.
  // На практике, т.к. SharedPreferences грузятся быстро, это состояние почти незаметно.
  // Для избежания ошибки во время загрузки, можно сделать так:
  // Возвращаем временный Notifier с пустыми SharedPreferences, пока грузятся реальные.
  // Но лучше полагаться на механизм зависимостей Riverpod.
  // Пока что для простоты вернем временное состояние, хотя это не идеально:
  throw Exception(
    'SharedPreferences not loaded yet for ThemeNotifier',
  ); // Или покажи заглушку
  // return ThemeNotifier(InMemorySharedPreferences()); // Как вариант
});

// Опционально: Класс для имитации SharedPreferences, пока грузятся реальные
// class InMemorySharedPreferences implements SharedPreferences { ... }
