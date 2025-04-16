import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Для userId
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Для ПИН/Био
import 'package:local_auth/local_auth.dart'; // Для Био
import '../providers/theme_notifier.dart';
import '../auth/pin_setup_screen.dart'; // Для смены/установки ПИН
import '../auth/change_pin_screen.dart';

class SettingsScreen extends StatefulWidget {
  // Превращаем в StatefulWidget
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  final _userId =
      FirebaseAuth
          .instance
          .currentUser
          ?.uid; // Получаем ID текущего пользователя

  bool _pinEnabled = false;
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;
  bool _isLoadingBioCheck = true; // Флаг загрузки проверки биометрии

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBiometrics();
  }

  // Загрузка текущих настроек ПИН/Био
  Future<void> _loadSettings() async {
    if (_userId == null) return;
    try {
      final pin = await _storage.read(key: 'pin_enabled_$_userId') == 'true';
      final bio = await _storage.read(key: 'bio_enabled_$_userId') == 'true';
      if (mounted) {
        setState(() {
          _pinEnabled = pin;
          _biometricsEnabled = bio;
        });
      }
    } catch (e) {
      print("Error loading settings: $e");
    }
  }

  // Проверка доступности биометрии на устройстве
  Future<void> _checkBiometrics() async {
    bool canCheck = false;
    try {
      canCheck =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (e) {
      print("Error checking biometrics: $e");
      canCheck = false;
    }
    if (mounted) {
      setState(() {
        _biometricsAvailable = canCheck;
        _isLoadingBioCheck = false;
      });
    }
  }

  // Переключение биометрии
  Future<void> _toggleBiometrics(bool enable) async {
    if (_userId == null) return;
    final bioKey = 'bio_enabled_$_userId';

    if (enable) {
      // Пытаемся аутентифицироваться для подтверждения включения
      try {
        bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Включить вход по биометрии',
          options: const AuthenticationOptions(
            stickyAuth: true, // Оставлять запрос видимым
            biometricOnly: true, // Только биометрия (не системный пароль)
          ),
        );
        if (didAuthenticate && mounted) {
          await _storage.write(key: bioKey, value: 'true');
          setState(() => _biometricsEnabled = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Вход по биометрии включен'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось включить биометрию'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        print("Auth error on enabling biometrics: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка биометрии: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Просто отключаем (удаляем ключ)
      await _storage.delete(key: bioKey);
      setState(() => _biometricsEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вход по биометрии отключен')),
        );
      }
    }
  }

  // Удаление ПИН-кода
  Future<void> _removePin() async {
    if (_userId == null) return;
    bool? confirmed = await showDialog<bool>(
      // Диалог подтверждения
      context: context,
      builder:
          (ctx) => AlertDialog(
            /* ... Диалог подтверждения удаления ПИН ... */
            title: const Text('Удалить ПИН-код?'),
            content: const Text(
              'Вы уверены, что хотите удалить ПИН-код? Вам потребуется вводить пароль для входа, пока не установите новый ПИН или не включите биометрию.',
            ),
            actions: [
              /* ... Кнопки Отмена/Удалить ... */
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Удалить',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        await _storage.delete(key: 'pin_hash_$_userId');
        await _storage.delete(key: 'pin_enabled_$_userId');
        setState(() => _pinEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ПИН-код удален'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print("Error removing PIN: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось удалить ПИН-код: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Навигация на экран смены ПИН (требует создания ChangePinScreen)
  void _navigateToChangePin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePinScreen()),
    ).then(
      (_) => _loadSettings(),
    ); // Обновляем состояние настроек после возврата (на всякий случай)
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
        ), // Только вертикальный отступ
        children: [
          // --- Секция Темы ---
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(
              "Оформление",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ), // Подзаголовок секции
          ),
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
          const Divider(height: 20),

          // --- Секция Безопасности ---
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: Text(
              "Безопасность",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          // Управление ПИН-кодом
          ListTile(
            title: const Text('ПИН-код'),
            subtitle: Text(_pinEnabled ? 'Установлен' : 'Не установлен'),
            trailing: Icon(
              _pinEnabled ? Icons.lock_outline : Icons.lock_open_outlined,
            ),
            onTap: () {
              if (_pinEnabled) {
                _navigateToChangePin(); // Переход на смену ПИН
              } else {
                // Переход на установку ПИН
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PinSetupScreen()),
                ).then((_) => _loadSettings()); // Обновляем состояние
              }
            },
          ),
          // Кнопка удаления ПИН (если он установлен)
          if (_pinEnabled)
            ListTile(
              title: Text(
                'Удалить ПИН-код',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onTap: _removePin,
            ),

          // Управление Биометрией
          if (_isLoadingBioCheck) // Показываем загрузку, пока проверяем биометрию
            const ListTile(
              title: Text("Проверка биометрии..."),
              leading: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_biometricsAvailable) // Показываем переключатель, если биометрия доступна
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Вход по биометрии'),
              value: _biometricsEnabled,
              onChanged:
                  (value) => _toggleBiometrics(value), // Вызываем переключение
            )
          else // Показываем сообщение, если биометрия недоступна
            const ListTile(
              leading: Icon(Icons.fingerprint, color: Colors.grey),
              title: Text('Вход по биометрии'),
              subtitle: Text('Биометрия недоступна на этом устройстве'),
            ),

          const Divider(height: 20),
          // --- Другие настройки ---
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
