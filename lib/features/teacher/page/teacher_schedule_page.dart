
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Для переиспользования _LessonCard

class TeacherSchedulePage extends ConsumerWidget {
  const TeacherSchedulePage({super.key});
  
  ProviderListenable get teacherScheduleProvider {
    // TODO: implement teacherScheduleProvider
    throw UnimplementedError();
  }
  
  ProviderListenable get teacherGroupedScheduleProvider {
    // TODO: implement teacherGroupedScheduleProvider
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedSchedule = ref.watch(teacherGroupedScheduleProvider);
    final asyncSchedule = ref.watch(teacherScheduleProvider);

    final daysOfWeek = [1, 2, 3, 4, 5, 6];
    final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];

    return DefaultTabController(
      length: daysOfWeek.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мои занятия'),
          bottom: TabBar(
            tabs: dayNames.map((d) => Tab(text: d)).toList(),
          ),
        ),
        body: asyncSchedule.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Ошибка загрузки: $e')),
          data: (_) => TabBarView(
            children: daysOfWeek.map((day) {
              final lessons = groupedSchedule[day] ?? [];
              if (lessons.isEmpty) {
                return const Center(child: Text('Нет занятий'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lessons.length,
                itemBuilder: (_, i) => _LessonCard(lesson: lessons[i]),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  Widget _LessonCard({required lesson}) {  throw UnimplementedError();}
}