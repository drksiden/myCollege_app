// lib/features/admin/pages/admin_login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth_service.dart';
import '../providers/admin_auth_provider.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);

    try {
      // 1. Вход через Firebase Auth
      final credential = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;

      // 2. Получение данных пользователя из Firestore
      final user = await authService.currentUser;
      if (!mounted) return;

      if (user != null && user.role == 'admin') {
        // 3. Только если это админ — обновляем провайдер
        ref.read(adminAuthProvider.notifier).state = true;
      } else {
        setState(() {
          _errorMessage = 'Нет доступа: вы не администратор.';
        });
        await authService.signOut();
        if (!mounted) return;
      }
    } on Exception catch (e) {
      if (!mounted) return;
      String message = 'Ошибка входа. Попробуйте ещё раз.';
      final errorStr = e.toString();
      if (errorStr.contains('firebase_auth/invalid-credential')) {
        message = 'Неверный email или пароль.';
      } else if (errorStr.contains('firebase_auth/user-not-found')) {
        message = 'Пользователь с таким email не найден.';
      } else if (errorStr.contains('firebase_auth/wrong-password')) {
        message = 'Неверный пароль.';
      } else if (errorStr.contains('firebase_auth/too-many-requests')) {
        message = 'Слишком много попыток входа. Попробуйте позже.';
      } else if (errorStr.contains('firebase_auth/network-request-failed')) {
        message = 'Проблема с интернет-соединением.';
      }
      setState(() {
        _errorMessage = message;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Градиентный фон
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F8FFF), Color(0xFFB6E0FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Анимированная форма
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  constraints: BoxConstraints(maxWidth: isWide ? 400 : 340),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(247),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Логотип
                        AnimatedScale(
                          scale: 1,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FlutterLogo(size: 56),
                          ),
                        ),
                        Text(
                          'MyCollege Admin',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (v) =>
                                  v != null && v.contains('@')
                                      ? null
                                      : 'Введите корректный email',
                          enabled: !_loading,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Пароль',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator:
                              (v) =>
                                  v != null && v.length >= 6
                                      ? null
                                      : 'Минимум 6 символов',
                          enabled: !_loading,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon:
                                _loading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.login),
                            label: Text(_loading ? 'Вход...' : 'Войти'),
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: theme.textTheme.titleMedium,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
