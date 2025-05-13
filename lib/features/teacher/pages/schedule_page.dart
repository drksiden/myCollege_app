// lib/features/teacher/pages/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

// Провайдеры
import '../providers/teacher_schedule_provider.dart';
import '../providers/journal_providers.dart';
import '../providers/schedule_service.dart';

// Виджеты
import '../widgets/schedule_entry_dialog.dart';
import '../widgets/schedule_filters.dart';
import '../widgets/schedule_tab_content.dart';
import '../widgets/schedule_search.dart';

// Модели
import '../../../models/schedule_entry.dart';

class SchedulePage extends ConsumerWidget {
  final TabController tabController;
  final bool isSearching;
  final List<ScheduleEntry> searchResults;
  final String? selectedGroupId;
  final String? selectedSubject;
  final void Function(List<ScheduleEntry>)? onReorderLessons;

  const SchedulePage({
    super.key,
    required this.tabController,
    required this.isSearching,
    required this.searchResults,
    this.selectedGroupId,
    this.selectedSubject,
    this.onReorderLessons,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final asyncGroupsInfo = ref.watch(teacherSubjectsAndGroupsProvider);
    final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];

    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: List.generate(dayNames.length, (index) {
              final dayOfWeek = index + 1;
              return Consumer(
                builder: (context, ref, child) {
                  final scheduleAsync = ref.watch(teacherScheduleProvider);
                  return scheduleAsync.when(
                    data: (scheduleEntries) {
                      final lessons =
                          isSearching
                              ? searchResults
                                  .where(
                                    (entry) => entry.dayOfWeek == dayOfWeek,
                                  )
                                  .toList()
                              : scheduleEntries
                                  .where(
                                    (entry) =>
                                        entry.dayOfWeek == dayOfWeek &&
                                        (selectedGroupId == null ||
                                            entry.groupId == selectedGroupId) &&
                                        (selectedSubject == null ||
                                            entry.subject == selectedSubject),
                                  )
                                  .toList();
                      lessons.sort(
                        (a, b) => a.lessonNumber.compareTo(b.lessonNumber),
                      );
                      if (lessons.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 48,
                                color: colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Нет занятий на этот день',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ScheduleTabContent(
                        dayOfWeek: dayOfWeek,
                        lessons: lessons,
                        onReorder:
                            isSearching ? (_) {} : (onReorderLessons ?? (_) {}),
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ошибка загрузки расписания: $error',
                              ),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      });
                      return const SizedBox();
                    },
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
