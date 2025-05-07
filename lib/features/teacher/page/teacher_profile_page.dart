import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth_service.dart';


class TeacherProfilePage extends ConsumerWidget {
  const TeacherProfilePage({super.key});
  
  ProviderListenable get teacherProfileProvider;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(teacherProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (user) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ФИО: ${user.name}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('Email: ${user.email}'),
              const Spacer(),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => ref.read(authServiceProvider).signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Выйти'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

