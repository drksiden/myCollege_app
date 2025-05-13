// lib/features/admin/pages/admin_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth_service.dart';
import '../providers/admin_auth_provider.dart';
import 'admin_dashboard_page.dart';
import 'admin_groups_page.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  int _selectedIndex = 0;

  static const _sectionTitles = [
    'Dashboard',
    'Пользователи',
    'Группы',
    'Предметы',
    'Задания',
    'Настройки',
  ];

  final List<Widget> _pages = const [
    AdminDashboardPage(),
    _StubPage(title: 'Пользователи'),
    AdminGroupsPage(),
    _StubPage(title: 'Предметы'),
    _StubPage(title: 'Задания'),
    _StubPage(title: 'Настройки'),
  ];

  void _onLogout(BuildContext context) async {
    await ref.read(authServiceProvider).signOut();
    ref.read(adminAuthProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final navItems = [
      NavigationRailDestination(
        icon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.people),
        label: Text('Пользователи'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.groups),
        label: Text('Группы'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.book),
        label: Text('Предметы'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.assignment),
        label: Text('Задания'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.settings),
        label: Text('Настройки'),
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(_sectionTitles[_selectedIndex])),
      drawer:
          isWide
              ? null
              : Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Colors.indigo),
                      child: Text(
                        'MyCollege Admin',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    for (int i = 0; i < _sectionTitles.length; i++)
                      ListTile(
                        leading: navItems[i].icon,
                        title: Text(_sectionTitles[i]),
                        selected: _selectedIndex == i,
                        onTap: () {
                          setState(() => _selectedIndex = i);
                          Navigator.pop(context);
                        },
                      ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Выйти'),
                      onTap: () => _onLogout(context),
                    ),
                  ],
                ),
              ),
      body:
          isWide
              ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected:
                        (i) => setState(() => _selectedIndex = i),
                    labelType: NavigationRailLabelType.all,
                    destinations: navItems,
                    leading: const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.indigo,
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: IconButton(
                          icon: const Icon(Icons.logout),
                          tooltip: 'Выйти',
                          onPressed: () => _onLogout(context),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: _pages[_selectedIndex]),
                ],
              )
              : _pages[_selectedIndex],
    );
  }
}

class _StubPage extends StatelessWidget {
  final String title;
  const _StubPage({required this.title});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title (в разработке)',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
