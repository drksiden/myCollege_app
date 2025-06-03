import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/attendance.dart';
import 'providers/attendance_provider.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  String _selectedSubject = 'Все';

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(attendanceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Посещаемость'),
        actions: [
          if (_selectedSubject != 'Все')
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: 'Сбросить фильтр',
              onPressed: () => setState(() => _selectedSubject = 'Все'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Фильтр по предметам
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: InputDecoration(
                labelText: 'Предмет',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              items:
                  ref.watch(uniqueSubjectsProvider).map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
              onChanged: (String? value) {
                if (value != null) setState(() => _selectedSubject = value);
              },
            ),
          ),
          // Список посещаемости
          Expanded(
            child: attendanceAsync.when(
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

                // Фильтруем по выбранному предмету
                final filteredAttendance =
                    _selectedSubject == 'Все'
                        ? attendance
                        : attendance
                            .where((a) => a.subject == _selectedSubject)
                            .toList();

                if (filteredAttendance.isEmpty) {
                  return Center(
                    child: Text(
                      'Нет данных о посещаемости по предмету "$_selectedSubject"',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                // Группируем записи по предметам
                final groupedAttendance = <String, List<Attendance>>{};
                for (final record in filteredAttendance) {
                  groupedAttendance
                      .putIfAbsent(record.subject, () => [])
                      .add(record);
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
                              return _AttendanceListTile(record: record);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceListTile extends StatefulWidget {
  final Attendance record;
  const _AttendanceListTile({required this.record});

  @override
  State<_AttendanceListTile> createState() => _AttendanceListTileState();
}

class _AttendanceListTileState extends State<_AttendanceListTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.record.getIcon(),
                    color: widget.record.getColor(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            'd MMMM y',
                            'ru_RU',
                          ).format(widget.record.date),
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.record.getDisplayName(),
                          style: textTheme.bodyMedium?.copyWith(
                            color: widget.record.getColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Преподаватель: ${widget.record.teacher}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (widget.record.reason != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Причина: ${widget.record.reason}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.record.comment != null &&
                    widget.record.comment!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.record.comment!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
