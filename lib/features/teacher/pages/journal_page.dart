// lib/features/teacher/pages/journal_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

// Провайдеры
import '../providers/journal_providers.dart';
// Виджеты
import '../widgets/grades_view_widget.dart';
import '../widgets/attendance_view_widget.dart';
import '../widgets/lesson_selector_widget.dart';
// Модели
import '../../../models/user.dart';
import '../../../models/grade.dart';
import '../../../models/attendance_record.dart';
import '../../../models/schedule_entry.dart';

enum JournalView { grades, attendance }

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  // Локальное состояние
  GroupInfo? _selectedGroupInfo; // Храним всю информацию о выбранной группе
  String? _selectedSubject;
  DateTime _selectedDate = DateTime.now();
  JournalView _currentView = JournalView.grades;
  ScheduleEntry? _selectedLesson;

  // Метод для инициализации фильтров при первой загрузке данных
  void _initializeFilters(List<GroupInfo> groups) {
    if (_selectedGroupInfo == null && groups.isNotEmpty) {
      _selectedGroupInfo = groups.first;
      if (_selectedGroupInfo!.subjects.isNotEmpty) {
        _selectedSubject = _selectedGroupInfo!.subjects.first;
      } else {
        _selectedSubject = null;
      }
      // Сразу после инициализации вызываем setState, чтобы UI обновился
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsyncValue = ref.watch(teacherSubjectsAndGroupsProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // --- Блок Фильтров ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: groupsAsyncValue.when(
              loading: () => const Center(child: LinearProgressIndicator()),
              error:
                  (err, st) => Text(
                    'Ошибка загрузки групп: $err',
                    style: TextStyle(color: colorScheme.error),
                  ),
              data: (groups) {
                if (groups.isEmpty) {
                  return const Center(
                    child: Text('Вы не назначены ни на одну группу/предмет'),
                  );
                }

                // Инициализируем фильтры, если они еще не установлены
                _initializeFilters(groups);

                // Обновляем список доступных предметов, если выбрана группа
                final availableSubjects = _selectedGroupInfo?.subjects ?? [];

                // Сброс предмета, если он не доступен для текущей группы или группа не выбрана
                if (_selectedSubject != null &&
                    !availableSubjects.contains(_selectedSubject)) {
                  _selectedSubject =
                      availableSubjects.isNotEmpty
                          ? availableSubjects.first
                          : null;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {}); // Обновляем UI после сброса
                    }
                  });
                }

                return Column(
                  children: [
                    // --- Выбор Группы ---
                    DropdownButtonFormField<GroupInfo>(
                      value: _selectedGroupInfo,
                      // Используем compare по ID для value, т.к. объекты могут пересоздаваться
                      // Но проще сравнивать по ссылке, если список стабилен
                      decoration: const InputDecoration(labelText: 'Группа'),
                      items:
                          groups
                              .map(
                                (info) => DropdownMenuItem(
                                  value:
                                      info, // Значение - сам объект GroupInfo
                                  child: Text(info.name),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null &&
                            value.id != _selectedGroupInfo?.id) {
                          setState(() {
                            _selectedGroupInfo = value;
                            // Обновляем предмет
                            _selectedSubject =
                                value.subjects.isNotEmpty
                                    ? value.subjects.first
                                    : null;
                            _selectedLesson = null;
                          });
                        }
                      },
                      // Отображение выбранного значения
                      selectedItemBuilder:
                          (context) =>
                              groups.map((info) => Text(info.name)).toList(),
                    ),
                    const SizedBox(height: 8),

                    // --- Выбор Предмета ---
                    if (_selectedGroupInfo != null &&
                        availableSubjects.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: const InputDecoration(labelText: 'Предмет'),
                        items:
                            availableSubjects
                                .map(
                                  (subject) => DropdownMenuItem(
                                    value: subject,
                                    child: Text(subject),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null && value != _selectedSubject) {
                            setState(() {
                              _selectedSubject = value;
                              _selectedLesson = null;
                            });
                          }
                        },
                      ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    // --- Выбор Даты/Периода (простой вариант) ---
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Дата: ${DateFormat.yMMMMd('ru').format(_selectedDate)}",
                            style: textTheme.titleSmall,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, size: 20),
                          tooltip: 'Выбрать дату',
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null &&
                                pickedDate != _selectedDate) {
                              setState(() {
                                _selectedDate = pickedDate;
                                _selectedLesson = null;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    // --- Выбор Урока (только для посещаемости) ---
                    if (_currentView == JournalView.attendance &&
                        _selectedGroupInfo != null &&
                        _selectedSubject != null)
                      LessonSelectorWidget(
                        groupId: _selectedGroupInfo!.id,
                        subject: _selectedSubject!,
                        date: _selectedDate,
                        selectedLesson: _selectedLesson,
                        onLessonSelected: (lesson) {
                          setState(() => _selectedLesson = lesson);
                        },
                      ),
                  ],
                );
              },
            ),
          ),

          // --- Переключатель Вида ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SegmentedButton<JournalView>(
              segments: const <ButtonSegment<JournalView>>[
                ButtonSegment<JournalView>(
                  value: JournalView.grades,
                  label: Text('Оценки'),
                  icon: Icon(Icons.grade_outlined),
                ),
                ButtonSegment<JournalView>(
                  value: JournalView.attendance,
                  label: Text('Посещ.'),
                  icon: Icon(Icons.checklist_rtl_outlined),
                ),
              ],
              selected: {_currentView},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _currentView = newSelection.first;
                });
              },
            ),
          ),

          // --- Область для отображения оценок или посещаемости ---
          Expanded(child: _buildJournalView()),
        ],
      ),
    );
  }

  // Метод для отображения контента журнала
  Widget _buildJournalView() {
    // Проверяем, выбраны ли группа и предмет
    if (_selectedGroupInfo == null || _selectedSubject == null) {
      return const Center(child: Text('Выберите группу и предмет'));
    }

    // Получаем ID выбранной группы
    final selectedGroupId = _selectedGroupInfo!.id;

    // В зависимости от выбранного вида, отображаем оценки или посещаемость
    switch (_currentView) {
      case JournalView.grades:
        // Используем Consumer для подписки на провайдеры внутри build метода
        return Consumer(
          builder: (context, ref, child) {
            // Получаем студентов и оценки
            final studentsAsync = ref.watch(
              groupStudentsProvider(selectedGroupId),
            );
            final gradesAsync = ref.watch(
              groupSubjectGradesProvider((
                groupId: selectedGroupId,
                subject: _selectedSubject!,
              )),
            );

            // Обрабатываем состояния loading/error/data для обоих провайдеров
            return studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, st) =>
                      Center(child: Text('Ошибка загрузки студентов: $err')),
              data: (students) {
                if (students.isEmpty) {
                  return const Center(child: Text('В группе нет студентов'));
                }
                return gradesAsync.when(
                  loading:
                      () => const Center(
                        child: CircularProgressIndicator(),
                      ), // Можно показать поверх списка студентов
                  error:
                      (err, st) =>
                          Center(child: Text('Ошибка загрузки оценок: $err')),
                  data: (grades) {
                    return GradesViewWidget(
                      students: students,
                      allGradesForSubject: grades,
                      selectedGroupInfo: _selectedGroupInfo!,
                      selectedSubject: _selectedSubject!,
                      selectedDateForDialog: _selectedDate,
                    );
                  },
                );
              },
            );
          },
        );
      case JournalView.attendance:
        if (_selectedLesson == null) {
          return const Center(
            child: Text('Выберите урок для просмотра посещаемости'),
          );
        }

        return Consumer(
          builder: (context, ref, child) {
            final studentsAsync = ref.watch(
              groupStudentsProvider(selectedGroupId),
            );
            final attendanceAsync = ref.watch(
              attendanceProvider((
                groupId: selectedGroupId,
                date: _selectedDate,
                lessonNumber: _selectedLesson!.lessonNumber,
              )),
            );

            return studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, st) =>
                      Center(child: Text('Ошибка загрузки студентов: $err')),
              data: (students) {
                if (students.isEmpty) {
                  return const Center(child: Text('В группе нет студентов'));
                }
                return attendanceAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, st) => Center(
                        child: Text('Ошибка загрузки посещаемости: $err'),
                      ),
                  data: (attendanceRecords) {
                    // --- Здесь будет UI таблицы посещаемости ---
                    return AttendanceViewWidget(
                      students: students,
                      selectedGroupInfo: _selectedGroupInfo!,
                      selectedSubject: _selectedSubject!,
                      selectedDate: _selectedDate,
                      selectedLessonNumber: _selectedLesson!.lessonNumber,
                    );
                  },
                );
              },
            );
          },
        );
    }
  }
}
