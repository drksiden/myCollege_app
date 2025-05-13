// lib/features/admin/home_screen.dart
import 'package:flutter/material.dart';
import '../../core/auth_service.dart'; // Для кнопки выхода
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Если используется для навигации внутри админки
import 'package:flutter_animate/flutter_animate.dart';

import 'providers/admin_auth_provider.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/admin_groups_page.dart'; // Новая страница для групп

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель админа'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              ref.read(adminAuthProvider.notifier).state = false;
              // GoRouter сам перенаправит на /login после выхода
            },
          ),
        ],
      ),
      body: const Center(child: Text('Добро пожаловать, Админ!')),
    );
  }
}
