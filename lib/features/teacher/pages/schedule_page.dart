import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/teacher_providers.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(classSessionsProvider);

    return Scaffold(
      
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(child: Text('Нет занятий.'));
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              return ListTile(
                title: Text(s.subject),
                subtitle: Text('Группа: ${s.groupId}'),
                trailing: Text('${s.date.day}.${s.date.month}.${s.date.year}'),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('Ошибка загрузки')),
      ),
    );
  }
}
