import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/schedule_entry.dart';
import '../providers/schedule_provider.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(teacherScheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Расписание')),
      body: scheduleAsync.when(
        data: (schedule) {
          if (schedule.isEmpty) {
            return const Center(child: Text('Нет занятий'));
          }

          // Группируем занятия по дням недели
          final groupedSchedule = <int, List<ScheduleEntry>>{};
          for (final entry in schedule) {
            (groupedSchedule[entry.dayOfWeek] ??= []).add(entry);
          }

          // Сортируем дни недели
          final sortedDays = groupedSchedule.keys.toList()..sort();

          return ListView.builder(
            itemCount: sortedDays.length,
            itemBuilder: (context, index) {
              final day = sortedDays[index];
              final daySchedule = groupedSchedule[day]!;
              daySchedule.sort((a, b) => a.startTime.compareTo(b.startTime));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _getDayName(day),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ...daySchedule.map(
                    (entry) => _buildScheduleEntry(context, entry),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ошибка загрузки расписания'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(teacherScheduleProvider),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildScheduleEntry(BuildContext context, ScheduleEntry entry) {
    final isCurrent = entry.isCurrentLesson();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      color: isCurrent ? colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(
          entry.subjectId,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${entry.startTime} - ${entry.endTime}'),
            Text('${entry.type} • ${entry.room}'),
          ],
        ),
        trailing:
            isCurrent
                ? const Icon(Icons.access_time, color: Colors.green)
                : null,
      ),
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Понедельник';
      case 2:
        return 'Вторник';
      case 3:
        return 'Среда';
      case 4:
        return 'Четверг';
      case 5:
        return 'Пятница';
      case 6:
        return 'Суббота';
      default:
        return 'Неизвестный день';
    }
  }
}
