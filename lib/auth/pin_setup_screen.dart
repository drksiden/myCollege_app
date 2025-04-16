import 'dart:convert'; // Для utf8
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart'; // Для SHA256
import 'package:firebase_auth/firebase_auth.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _storage = const FlutterSecureStorage(); // Создаем экземпляр хранилища
  bool _isLoading = false;
  final int _pinLength = 4; // Длина ПИН-кода

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  // Функция хеширования ПИН-кода
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin); // Конвертируем ПИН в байты
    final digest = sha256.convert(bytes); // Хешируем с помощью SHA256
    return digest.toString(); // Возвращаем хеш в виде строки
  }

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final pin = _pinController.text;
    final hashedPin = _hashPin(pin); // Хешируем введенный ПИН

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // Обработка ошибки - пользователь не вошел
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ошибка: не удалось получить ID пользователя."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Сохраняем хеш в безопасное хранилище, привязав к ID пользователя
      await _storage.write(key: 'pin_hash_$userId', value: hashedPin);
      // Сохраняем флаг, что ПИН установлен для этого пользователя
      await _storage.write(key: 'pin_enabled_$userId', value: 'true');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ПИН-код успешно установлен!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Закрываем экран настройки
      }
    } catch (e) {
      print("Error saving PIN: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Не удалось сохранить ПИН-код: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Установка ПИН-кода")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Придумайте $_pinLength-значный ПИН-код",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: "ПИН-код",
                    border: OutlineInputBorder(),
                    counterText: "",
                  ), // Убираем счетчик символов
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: _pinLength, // Ограничиваем длину
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 10,
                  ), // Крупные цифры с пробелами
                  validator: (value) {
                    if (value == null || value.length != _pinLength) {
                      return 'ПИН должен состоять из $_pinLength цифр';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPinController,
                  decoration: const InputDecoration(
                    labelText: "Подтвердите ПИН-код",
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: _pinLength,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 10),
                  validator: (value) {
                    if (value != _pinController.text) {
                      return 'ПИН-коды не совпадают';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _savePin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("СОХРАНИТЬ ПИН-КОД"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
