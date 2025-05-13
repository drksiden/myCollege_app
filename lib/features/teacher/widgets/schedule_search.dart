import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/schedule_entry.dart';

class ScheduleSearch extends ConsumerWidget {
  final List<ScheduleEntry> allLessons;
  final Function(List<ScheduleEntry>) onSearchResults;

  const ScheduleSearch({
    super.key,
    required this.allLessons,
    required this.onSearchResults,
  });

  void _performSearch(String query, List<ScheduleEntry> lessons) {
    if (query.isEmpty) {
      onSearchResults(lessons);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final results =
        lessons.where((lesson) {
          return lesson.subject.toLowerCase().contains(lowercaseQuery) ||
              lesson.classroom?.toLowerCase().contains(lowercaseQuery) ==
                  true ||
              lesson.lessonType?.toLowerCase().contains(lowercaseQuery) == true;
        }).toList();

    onSearchResults(results);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Поиск по предмету, аудитории или типу занятия',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (query) => _performSearch(query, allLessons),
        style: textTheme.bodyLarge,
      ),
    );
  }
}
