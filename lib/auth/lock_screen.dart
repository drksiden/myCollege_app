import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Для анимаций

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  // Добавляем TickerProvider
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  String _enteredPin = ""; // Храним введенные цифры
  String? _errorMessage;
  bool _checkingPin = false;
  bool _canUseBiometrics = false;
  bool _isBioEnabledForUser = false;

  // Для анимации тряски точек
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final int _pinLength = 4; // Длина ПИН

  @override
  void initState() {
    super.initState();

    // Настройка анимации тряски
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1)
      .chain(CurveTween(curve: Curves.elasticIn)) // Эффект упругой тряски
      .animate(_shakeController)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    _initialize();
  }

  Future<void> _initialize() async {
    await _checkBiometricSettings();
    // Если биометрия доступна и включена, сразу пытаемся ее вызвать
    if (_isBioEnabledForUser && _canUseBiometrics && mounted) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _checkBiometricSettings() async {
    // ... (код как в предыдущем ответе) ...
    bool canCheck = false;
    bool bioEnabled = false;
    try {
      canCheck =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      if (canCheck && _userId != null) {
        bioEnabled = await _storage.read(key: 'bio_enabled_$_userId') == 'true';
      }
    } catch (e) {
      print("Error checking biometrics availability: $e");
    }
    if (mounted) {
      setState(() {
        _canUseBiometrics = canCheck;
        _isBioEnabledForUser = bioEnabled;
      });
    }
  }

  String _hashPin(String pin) {
    /* ... как в предыдущем ответе ... */
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_canUseBiometrics) return; // Не пытаться, если недоступно
    try {
      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Войдите для доступа к приложению',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (didAuthenticate && mounted) Navigator.pop(context, true);
    } catch (e) {
      print("Biometric Auth Error: $e");
      if (mounted) {
        setState(() => _errorMessage = 'Ошибка биометрии. Попробуйте ПИН-код.');
      }
    }
  }

  Future<void> _verifyPin() async {
    if (_enteredPin.length != _pinLength || _userId == null) return;
    setState(() {
      _checkingPin = true;
      _errorMessage = null;
    });

    final storedPinHash = await _storage.read(key: 'pin_hash_$_userId');
    final enteredPinHash = _hashPin(_enteredPin);

    await Future.delayed(const Duration(milliseconds: 150)); // Краткая задержка

    if (enteredPinHash == storedPinHash) {
      if (mounted) Navigator.pop(context, true);
    } else {
      _shakeController.forward(); // Запускаем анимацию тряски
      HapticFeedback.vibrate();
      if (mounted) {
        setState(() {
          _errorMessage = "Неверный ПИН-код";
          _checkingPin = false;
          _enteredPin = ""; // Очищаем введенный ПИН
        });
      }
    }
  }

  // Обработка нажатия на цифровую кнопку
  void _onNumpadTap(String digit) {
    if (_checkingPin) return; // Не обрабатывать во время проверки
    setState(() {
      _errorMessage = null; // Сбрасываем ошибку при вводе
      if (_enteredPin.length < _pinLength) {
        _enteredPin += digit;
        // Если ввели последнюю цифру, сразу проверяем
        if (_enteredPin.length == _pinLength) {
          _verifyPin();
        }
      }
    });
  }

  // Обработка нажатия Backspace
  void _onBackspaceTap() {
    if (_checkingPin || _enteredPin.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    // _pinController.dispose();
    super.dispose();
  }

  // --- Виджеты UI ---

  // Виджет для отображения точек ПИН-кода
  Widget _buildPinDots() {
    return AnimatedBuilder(
      // Обертка для анимации тряски
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 15, 0), // Величина тряски
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pinLength, (index) {
          bool isActive = index < _enteredPin.length;
          return Animate(
            // Анимация для каждой точки
            effects: [if (isActive) FadeEffect(duration: 150.ms)],
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                border: Border.all(
                  color:
                      isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade400,
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Виджет для цифровой клавиатуры
  Widget _buildNumpad() {
    final buttonStyle = TextButton.styleFrom(
      foregroundColor:
          Theme.of(context).colorScheme.onSurface, // Цвет текста/иконок
      shape: const CircleBorder(), // Круглые кнопки
      padding: const EdgeInsets.all(20), // Размер кнопки
      textStyle: Theme.of(context).textTheme.headlineMedium,
    );
    final emptyButton = SizedBox(
      width: 72,
      height: 72,
    ); // Пустое место для выравнивания

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true, // Чтобы GridView занимал только нужное место
      physics:
          const NeverScrollableScrollPhysics(), // Отключить прокрутку GridView
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        ...List.generate(9, (index) {
          // Кнопки 1-9
          final digit = '${index + 1}';
          return TextButton(
                style: buttonStyle,
                onPressed: () => _onNumpadTap(digit),
                child: Text(digit),
              )
              .animate(delay: (Random().nextDouble() * 100).ms)
              .fadeIn(duration: 200.ms); // Небольшая анимация появления
        }),
        // Пустое место или кнопка биометрии
        if (_canUseBiometrics && _isBioEnabledForUser)
          IconButton(
                icon: const Icon(Icons.fingerprint),
                iconSize: 30,
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                tooltip: "Использовать биометрию",
                onPressed: _authenticateWithBiometrics,
              )
              .animate(delay: (Random().nextDouble() * 100).ms)
              .fadeIn(duration: 200.ms)
        else
          emptyButton, // Пустое место если биометрии нет
        // Кнопка 0
        TextButton(
              style: buttonStyle,
              onPressed: () => _onNumpadTap('0'),
              child: const Text('0'),
            )
            .animate(delay: (Random().nextDouble() * 100).ms)
            .fadeIn(duration: 200.ms),
        // Кнопка Backspace
        IconButton(
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              icon: const Icon(Icons.backspace_outlined),
              iconSize: 28,
              tooltip: "Стереть",
              onPressed: _onBackspaceTap,
            )
            .animate(delay: (Random().nextDouble() * 100).ms)
            .fadeIn(duration: 200.ms),
      ],
    );
  }

  // --- Основной Build Метод ---
  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Запрещаем системную кнопку "назад" пока не разблокировано
      canPop: false, // Нельзя уйти назад системной кнопкой
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween, // Разносим элементы по вертикали
              children: [
                // Верхняя часть: Приветствие/Иконка (Опционально)
                Column(
                  children: [
                    Icon(
                      Icons.lock_person_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Введите ПИН-код',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    // Точки для ПИН-кода
                    _buildPinDots(),
                    // Сообщение об ошибке
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),

                // Нижняя часть: Клавиатура и доп. опции
                Column(
                  children: [
                    _buildNumpad(), // Кастомная клавиатура
                    const SizedBox(height: 20),
                    TextButton(
                      // Кнопка Выйти остается
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pop(
                            context,
                            false,
                          ); // Выходим и сигнализируем об отмене
                        }
                      },
                      child: Text(
                        "Выйти из аккаунта",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
