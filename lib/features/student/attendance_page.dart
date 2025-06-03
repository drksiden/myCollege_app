import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/attendance.dart';
import '../../../providers/attendance_provider.dart';

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Посещаемость')),
      body: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
        data: (attendance) {
          if (attendance.isEmpty) {
            return Center(
              child: Text(
                'Нет данных о посещаемости',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          // Группируем записи по предметам
          final groupedAttendance = <String, List<Attendance>>{};
          for (final record in attendance) {
            groupedAttendance.putIfAbsent(record.subject, () => []).add(record);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedAttendance.length,
            itemBuilder: (context, index) {
              final subject = groupedAttendance.keys.elementAt(index);
              final records = groupedAttendance[subject]!;

              // Сортируем записи по дате (от новых к старым)
              records.sort((a, b) => b.date.compareTo(a.date));

              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок предмета
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        subject,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    // Список записей посещаемости
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return ListTile(
                          leading: Icon(
                            record.status.getIcon(),
                            color: record.status.getColor(context),
                          ),
                          title: Text(
                            DateFormat('d MMMM y', 'ru_RU').format(record.date),
                            style: textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.status.getDisplayName(),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: record.status.getColor(context),
                                ),
                              ),
                              if (record.comment != null &&
                                  record.comment!.isNotEmpty)
                                Text(
                                  record.comment!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                            record.teacherName ?? 'Неизвестный преподаватель',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
