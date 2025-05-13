import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/schedule_entry.dart';
import 'lesson_card.dart';
import '../providers/teacher_schedule_provider.dart';
import '../providers/journal_providers.dart';
import '../providers/schedule_service.dart';
import 'package:flutter/scheduler.dart';

class ScheduleTabContent extends ConsumerWidget {
  final int dayOfWeek;
  final List<ScheduleEntry> lessons;
  final AnimationController? animationController;
  final void Function(List<ScheduleEntry>) onReorder;

  const ScheduleTabContent({
    super.key,
    required this.dayOfWeek,
    required this.lessons,
    this.animationController,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final AnimationController dummyController = AnimationController.unbounded(
      vsync: const _NoTickerProvider(),
    );
    final AnimationController controller =
        animationController ?? dummyController;

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: () async {
        ref.invalidate(teacherScheduleProvider);
        ref.invalidate(teacherSubjectsAndGroupsProvider);
        await ref.read(teacherScheduleProvider.future);
      },
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return lessons.isEmpty
              ? LayoutBuilder(
                key: const ValueKey('empty'),
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Нет занятий в этот день',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
              : ReorderableListView.builder(
                key: const ValueKey('list'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: lessons.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final newList = List<ScheduleEntry>.from(lessons);
                  final item = newList.removeAt(oldIndex);
                  newList.insert(newIndex, item);
                  onReorder(newList);
                },
                itemBuilder: (context, lessonIndex) {
                  final lesson = lessons[lessonIndex];
                  return LessonCard(key: ValueKey(lesson.id), lesson: lesson);
                },
              );
        },
      ),
    );
  }
}

class _NoTickerProvider implements TickerProvider {
  const _NoTickerProvider();
  @override
  Ticker createTicker(TickerCallback onTick) => throw UnimplementedError();
}
