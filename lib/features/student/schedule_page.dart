// lib/features/student/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/subject_provider.dart';
import '../../models/schedule_entry.dart';
import '../../models/subject.dart';
import '../../widgets/schedule_view.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Расписание')),
      body: const ScheduleView(),
    );
  }
}

class _LessonCard extends ConsumerWidget {
  final ScheduleEntry lesson;
  final Subject? subject;
  const _LessonCard({required this.lesson, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isCurrent = _isCurrentLesson(lesson);
    final teacherNameAsync = ref.watch(teacherNameProvider(lesson.teacherId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape:
          isCurrent
              ? RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.primary, width: 2.0),
                borderRadius: BorderRadius.circular(_borderRadiusValue),
              )
              : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Время
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.startTime,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isCurrent ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.endTime,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isCurrent)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Chip(
                          label: const Text('ИДЕТ'),
                          backgroundColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 10,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(
                          duration: 1200.ms,
                          color: colorScheme.primary.withAlpha(80),
                        ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                width: 1.5,
                height: 50,
                color: colorScheme.outlineVariant.withAlpha(128),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject?.name ?? 'Неизвестный предмет',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(
                      _getLessonType(lesson.type),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: teacherNameAsync.when(
                          data:
                              (name) => Text(
                                name,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          loading: () => const Text('Загрузка...'),
                          error: (e, s) => const Text('Не указан'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lesson.room,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isCurrentLesson(ScheduleEntry lesson) {
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return lesson.dayOfWeek == now.weekday &&
        lesson.startTime.compareTo(currentTime) <= 0 &&
        lesson.endTime.compareTo(currentTime) >= 0;
  }

  String _getLessonType(String type) {
    switch (type) {
      case 'lecture':
        return 'Лекция';
      case 'practice':
        return 'Практика';
      case 'lab':
        return 'Лабораторная';
      default:
        return type;
    }
  }
}

const double _borderRadiusValue = 12.0;
