import 'package:flutter/material.dart';
import 'schedule_screen.dart';
import 'grades_screen.dart';
import 'performance_screen.dart';
import 'activities_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // Контроллер для управления PageView
  late PageController _pageController;

  // Список экранов остается тем же
  final List<Widget> _screens = [
    // Оборачиваем каждый экран в KeepAlive, чтобы сохранять состояние
    // при перелистывании страниц (например, прокрутку списка)
    const KeepAliveWrapper(child: ScheduleScreen()),
    const KeepAliveWrapper(child: GradesScreen()),
    const KeepAliveWrapper(child: PerformanceScreen()),
    const KeepAliveWrapper(child: ActivitiesScreen()),
    KeepAliveWrapper(child: ProfileScreen()),
  ];

  @override
  void initState() {
    super.initState();
    // Инициализируем PageController
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    // Освобождаем ресурсы PageController
    _pageController.dispose();
    super.dispose();
  }

  // Эта функция будет вызываться при нажатии на элемент BottomNavigationBar
  void _onItemTapped(int index) {
    // Плавно анимируем переход к выбранной странице в PageView
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350), // Скорость анимации
      curve: Curves.easeInOut, // Кривая анимации для плавности
    );
    // Обновлять _selectedIndex здесь не нужно,
    // т.к. onPageChanged сделает это после завершения анимации свайпа/перехода.
  }

  // Эта функция будет вызываться при свайпе страниц в PageView
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex =
          index; // Обновляем выделенный элемент в BottomNavigationBar
    });
  }

  @override
  Widget build(BuildContext context) {
    // Используем Scaffold как и раньше
    return Scaffold(
      // Заменяем статическое отображение экрана на PageView
      body: PageView(
        controller: _pageController, // Указываем список экранов (страниц)
        onPageChanged: _onPageChanged, // Связываем PageView с контроллером
        children:
            _screens, // Указываем функцию обратного вызова при смене страницы свайпом
        // physics: const ClampingScrollPhysics(), // Можно настроить физику скролла
      ),
      // BottomNavigationBar остается почти без изменений
      bottomNavigationBar: BottomNavigationBar(
        // Используем стиль из темы (MaterialApp -> theme -> bottomNavigationBarTheme)
        // type: BottomNavigationBarType.fixed, // Тип можно задать в теме
        // selectedItemColor: Colors.blue, // Цвет лучше задать в теме
        currentIndex: _selectedIndex, // Указывает, какой элемент сейчас выбран
        onTap: _onItemTapped, // Функция, вызываемая при нажатии
        items: const [
          // Иконки и метки остаются теми же
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: 'Пары',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade_outlined),
            activeIcon: Icon(Icons.grade),
            label: 'Оценки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Успев.',
          ), // Сократил для экономии места
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Активности',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

// Вспомогательный виджет для сохранения состояния дочернего виджета в PageView
// Это нужно, чтобы при перелистывании страниц не сбрасывалась прокрутка
// или другие элементы состояния на неактивных страницах.
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // Важно вызвать super.build
    return widget.child;
  }

  // Возвращаем true, чтобы сохранить состояние
  @override
  bool get wantKeepAlive => true;
}
