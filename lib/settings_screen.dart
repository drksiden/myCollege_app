import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем ThemeNotifier
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode(
      context,
    ); // Проверяем текущую активную тему

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Переключатель темы
          SwitchListTile(
            title: const Text('Темная тема'),
            subtitle: Text(
              themeNotifier.themeMode == ThemeMode.system
                  ? 'Авто (как в системе)'
                  : (isDarkMode ? 'Включена' : 'Выключена'),
            ),
            value: isDarkMode, // Текущее состояние переключателя
            onChanged: (value) {
              // При изменении переключателя меняем тему
              // Если сейчас системная, переключаем явно на светлую/темную
              // Если явная, просто инвертируем
              ThemeMode newMode;
              if (themeNotifier.themeMode == ThemeMode.system) {
                newMode = value ? ThemeMode.dark : ThemeMode.light;
              } else {
                newMode = value ? ThemeMode.dark : ThemeMode.light;
              }
              themeNotifier.setThemeMode(newMode);
            },
            secondary: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
          ),
          // Дополнительно: Опция "Следовать системной теме"
          RadioListTile<ThemeMode>(
            title: const Text('Как в системе'),
            value: ThemeMode.system,
            groupValue: themeNotifier.themeMode,
            onChanged: (value) {
              if (value != null) themeNotifier.setThemeMode(value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Только светлая'),
            value: ThemeMode.light,
            groupValue: themeNotifier.themeMode,
            onChanged: (value) {
              if (value != null) themeNotifier.setThemeMode(value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Только темная'),
            value: ThemeMode.dark,
            groupValue: themeNotifier.themeMode,
            onChanged: (value) {
              if (value != null) themeNotifier.setThemeMode(value);
            },
          ),

          // Сюда можно добавить другие настройки в будущем
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('О приложении'),
            onTap: () {
              // TODO: Показать диалог "О приложении"
            },
          ),
        ],
      ),
    );
  }
}
