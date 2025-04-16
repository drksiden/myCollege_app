import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  // Контроллер для управления PageView
  late PageController _pageController;
  // Индекс текущей страницы (0 - Вход, 1 - Регистрация)
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Функция для переключения страниц с анимацией
  void _toggleView(int pageIndex) {
    if (_currentPageIndex == pageIndex) {
      return; // Не переключать, если уже на нужной странице
    }

    setState(() {
      _currentPageIndex = pageIndex;
    });
    _pageController.animateToPage(
      _currentPageIndex,
      duration: const Duration(milliseconds: 400), // Скорость анимации
      curve: Curves.easeInOutExpo, // Кривая анимации
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Используем PageView для эффекта свайпа/сдвига
      // Запрещаем свайп пальцем, управляем программно через _toggleView
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Отключаем свайп пользователя
        onPageChanged: (index) {
          // Обновляем индекс, если страница все же сменилась (на всякий случай)
          // Но по идее, это не должно происходить из-за NeverScrollableScrollPhysics
          if (_currentPageIndex != index) {
            setState(() {
              _currentPageIndex = index;
            });
          }
        },
        children: [
          // Страница Входа (индекс 0)
          LoginScreen(
            onToggleView: () => _toggleView(1),
          ), // Переключает на страницу 1
          // Страница Регистрации (индекс 1)
          RegisterScreen(
            onToggleView: () => _toggleView(0),
          ), // Переключает на страницу 0
        ],
      ),
    );
  }
}
