import 'dart:convert'; // Для utf8
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart'; // Для SHA256
import 'package:firebase_auth/firebase_auth.dart';
import 'pin_setup_screen.dart'; // Экран установки нового ПИН

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPinController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _errorMessage;
  final int _pinLength = 4; // Должно совпадать с PinSetupScreen

  @override
  void dispose() {
    _currentPinController.dispose();
    super.dispose();
  }

  // Функция хеширования ПИН-кода (должна быть идентична той, что в PinSetupScreen)
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Функция проверки текущего ПИН и перехода к установке нового
  Future<void> _verifyCurrentPin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Ошибка: Пользователь не найден.";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final storedPinHashKey = 'pin_hash_$userId';

    try {
      // Читаем сохраненный хеш
      final storedPinHash = await _storage.read(key: storedPinHashKey);

      if (storedPinHash == null) {
        // Этого не должно произойти, если мы перешли с экрана настроек, где ПИН был включен
        setState(() {
          _isLoading = false;
          _errorMessage = "Ошибка: ПИН-код не найден в хранилище.";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Хешируем введенный ПИН
      final enteredPin = _currentPinController.text;
      final enteredPinHash = _hashPin(enteredPin);

      // Сравниваем хеши
      if (enteredPinHash == storedPinHash) {
        // Успех! Переходим на экран установки нового ПИН-кода
        // Используем pushReplacement, чтобы пользователь не мог вернуться на экран проверки старого ПИН
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PinSetupScreen()),
          );
        }
      } else {
        // Неверный ПИН
        setState(() {
          _isLoading = false;
          _errorMessage = "Неверный текущий ПИН-код.";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.orange,
            ),
          );
        }
        // Можно добавить счетчик попыток и блокировку
      }
    } catch (e) {
      print("Error verifying PIN: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Ошибка проверки ПИН-кода.";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$_errorMessage\n$e"),
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
      appBar: AppBar(title: const Text("Смена ПИН-кода")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.password_outlined, size: 60), // Иконка
                const SizedBox(height: 20),
                Text(
                  "Введите текущий ПИН-код",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _currentPinController,
                  decoration: InputDecoration(
                    labelText: "Текущий ПИН-код",
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: _pinLength,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 10),
                  validator: (value) {
                    if (value == null || value.length != _pinLength) {
                      return 'ПИН должен состоять из $_pinLength цифр';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _verifyCurrentPin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("ПОДТВЕРДИТЬ"),
                  ),
                // Можно добавить кнопку "Забыли ПИН?" (потребует доп. логики восстановления)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
