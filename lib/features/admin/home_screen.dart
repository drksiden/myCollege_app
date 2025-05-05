// lib/features/student/home_screen.dart
import 'package:flutter/material.dart';
import '../../core/auth_service.dart'; // Для кнопки выхода
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              // GoRouter сам перенаправит на /login после выхода
            },
          ),
        ],
      ),
      body: const Center(child: Text('Добро пожаловать, Админ!')),
    );
  }
}
