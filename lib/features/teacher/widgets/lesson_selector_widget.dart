import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/schedule_entry.dart';
import '../providers/journal_providers.dart';

class LessonSelectorWidget extends ConsumerWidget {
  final String groupId;
  final String subject;
  final DateTime date;
  final ScheduleEntry? selectedLesson;
  final ValueChanged<ScheduleEntry> onLessonSelected;

  const LessonSelectorWidget({
    super.key,
    required this.groupId,
    required this.subject,
    required this.date,
    required this.selectedLesson,
    required this.onLessonSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsyncValue = ref.watch(
      teacherLessonsForDayProvider((
        groupId: groupId,
        subject: subject,
        date: date,
      )),
    );

    return lessonsAsyncValue.when(
      loading:
          () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(),
          ),
      error:
          (err, st) => Text(
            'Ошибка загрузки уроков: $err',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      data: (lessons) {
        if (lessons.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Нет уроков по этому предмету на выбранную дату.'),
          );
        }

        // Если выбранный урок больше не существует в новом списке, выбираем первый
        if (selectedLesson != null &&
            !lessons.any(
              (l) => l.lessonNumber == selectedLesson!.lessonNumber,
            )) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onLessonSelected(lessons.first);
          });
        }

        // Если урок не выбран, а список не пуст, выбираем первый
        if (selectedLesson == null && lessons.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onLessonSelected(lessons.first);
          });
        }

        return DropdownButtonFormField<ScheduleEntry>(
          value: selectedLesson,
          decoration: const InputDecoration(labelText: 'Урок'),
          items:
              lessons.map((lesson) {
                return DropdownMenuItem(
                  value: lesson,
                  child: Text(
                    '${lesson.lessonNumber}. ${lesson.startTime}-${lesson.endTime} (${lesson.lessonType ?? 'Урок'})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null &&
                value.lessonNumber != selectedLesson?.lessonNumber) {
              onLessonSelected(value);
            }
          },
          selectedItemBuilder:
              (context) =>
                  lessons
                      .map((l) => Text('${l.lessonNumber}. (${l.startTime})'))
                      .toList(),
        );
      },
    );
  }
}
