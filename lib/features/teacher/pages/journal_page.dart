// lib/features/teacher/pages/journal_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

// Провайдеры
import '../providers/journal_providers.dart';
// Модели
import '../../../models/user.dart';
import '../../../models/grade.dart';
import '../../../models/attendance_record.dart';

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
  int? _selectedLessonNumber; // Для выбора урока при просмотре посещаемости

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
                            _selectedLessonNumber =
                                null; // Сбрасываем урок при смене группы
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
                              _selectedLessonNumber = null; // Сбрасываем урок
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
                            "Дата: ${MaterialLocalizations.of(context).formatShortDate(_selectedDate)}",
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(
                                2020,
                              ), // Примерная начальная дата
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ), // Примерная конечная дата
                            );
                            if (pickedDate != null &&
                                pickedDate != _selectedDate) {
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
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

            // TODO: Отобразить таблицу/список оценок на основе studentsAsync и gradesAsync
            // Обрабатываем состояния loading/error/data для обоих провайдеров
            return studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, st) =>
                      Center(child: Text('Ошибка загрузки студентов: $err')),
              data: (students) {
                if (students.isEmpty)
                  return const Center(child: Text('В группе нет студентов'));
                return gradesAsync.when(
                  loading:
                      () => const Center(
                        child: CircularProgressIndicator(),
                      ), // Можно показать поверх списка студентов
                  error:
                      (err, st) =>
                          Center(child: Text('Ошибка загрузки оценок: $err')),
                  data: (grades) {
                    // --- Здесь будет UI таблицы оценок ---
                    return _buildGradesTable(students, grades);
                  },
                );
              },
            );
          },
        );
      case JournalView.attendance:
        // TODO: Реализовать UI для выбора урока (lessonNumber)
        // TODO: Использовать attendanceProvider(groupId, date, lessonNumber)
        return Consumer(
          builder: (context, ref, child) {
            final studentsAsync = ref.watch(
              groupStudentsProvider(selectedGroupId),
            );
            // --- Заглушка для выбора урока ---
            if (_selectedLessonNumber == null) {
              // TODO: Показать Dropdown или другой UI для выбора урока на _selectedDate
              // На основе ref.watch(teacherScheduleProvider) отфильтровать по дню недели даты,
              // groupId и subject, чтобы получить список пар (lessonNumber)
              return const Center(
                child: Text('Выберите урок для просмотра посещаемости'),
              );
            }
            // -------------------------------

            final attendanceAsync = ref.watch(
              attendanceProvider((
                groupId: selectedGroupId,
                date: _selectedDate,
                lessonNumber: _selectedLessonNumber!,
              )),
            );

            return studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, st) =>
                      Center(child: Text('Ошибка загрузки студентов: $err')),
              data: (students) {
                if (students.isEmpty)
                  return const Center(child: Text('В группе нет студентов'));
                return attendanceAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, st) => Center(
                        child: Text('Ошибка загрузки посещаемости: $err'),
                      ),
                  data: (attendanceRecords) {
                    // --- Здесь будет UI таблицы посещаемости ---
                    return _buildAttendanceList(students, attendanceRecords);
                  },
                );
              },
            );
          },
        );
    }
  }

  // --- Заглушки для методов построения UI таблиц ---
  Widget _buildGradesTable(List<User> students, List<Grade> grades) {
    // TODO: Реализовать UI (DataTable, ListView, ...)
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        // TODO: Найти оценки для этого студента
        return ListTile(
          title: Text(student.fullName),
          // subtitle: Text("Здесь будут оценки..."),
          trailing: IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: () {
              /* TODO: Открыть диалог добавления оценки */
            },
          ),
        );
      },
    );
    // return Center(child: Text('UI для таблицы оценок (студентов: ${students.length}, оценок: ${grades.length})'));
  }

  Widget _buildGradesList(
    List<User> students,
    List<Grade> allGradesForSubject,
  ) {
    // Группируем оценки по studentId для быстрого доступа
    final gradesByStudent = groupBy<Grade, String>(
      allGradesForSubject,
      (g) => g.studentId,
    );

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80), // Отступ снизу для FAB
      itemCount: students.length,
      separatorBuilder:
          (context, index) => const Divider(height: 1), // Разделитель
      itemBuilder: (context, index) {
        final student = students[index];
        final studentGrades =
            gradesByStudent[student.id] ?? []; // Оценки этого студента

        return ListTile(
          title: Text(
            student.fullName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle:
              studentGrades.isEmpty
                  ? Text(
                    'Нет оценок',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  )
                  : SizedBox(
                    height:
                        45, // Фиксированная высота для горизонтального списка
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children:
                            studentGrades
                                .map(
                                  (grade) => Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: InkWell(
                                      onTap: () {
                                        _showAddEditGradeDialog(
                                          student,
                                          grade,
                                        ); // Редактирование
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Chip(
                                        label: Text(
                                          grade.grade,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: grade.getColor(context),
                                          ),
                                        ),
                                        // Можно добавить дату или тип оценки
                                        // label: Text("${grade.grade} (${DateFormat.Md('ru').format(grade.date)})"),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        backgroundColor: grade
                                            .getColor(context)
                                            .withOpacity(0.1),
                                        side: BorderSide(
                                          color: grade
                                              .getColor(context)
                                              .withOpacity(0.3),
                                        ),
                                        visualDensity:
                                            VisualDensity
                                                .compact, // Делаем чип компактнее
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
          trailing: IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Добавить оценку',
            onPressed: () {
              _showAddEditGradeDialog(student); // Добавление новой оценки
            },
          ),
        );
      },
    );
  }

  Future<void> _showAddEditGradeDialog(
    User student, [
    Grade? existingGrade,
  ]) async {
    if (_selectedGroupInfo == null || _selectedSubject == null) return;

    final _formKey = GlobalKey<FormState>();
    final gradeController = TextEditingController(
      text: existingGrade?.grade ?? '',
    );
    final commentController = TextEditingController(
      text: existingGrade?.comment ?? '',
    );
    String? selectedGradeType =
        existingGrade?.gradeType; // TODO: Использовать реальный список типов
    DateTime selectedDate = existingGrade?.date ?? _selectedDate; // Дата оценки

    final List<String> gradeTypes = [
      'Обычная',
      'Контрольная',
      'Экзамен',
      'Домашняя работа',
      'Зачет',
    ]; // Пример

    Grade? result = await showDialog<Grade>(
      context: context,
      barrierDismissible: false, // Не закрывать по тапу снаружи
      builder: (context) {
        // Используем StatefulBuilder, чтобы управлять состоянием даты внутри диалога
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingGrade == null
                    ? 'Новая оценка: ${student.shortName}'
                    : 'Редакт. оценки: ${student.shortName}',
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  // На случай маленьких экранов
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: gradeController,
                        decoration: const InputDecoration(
                          labelText: 'Оценка (5, 4, Зч, Нз)',
                        ),
                        validator:
                            (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Введите оценку'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedGradeType,
                        decoration: const InputDecoration(
                          labelText: 'Тип оценки',
                        ),
                        items:
                            gradeTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setDialogState(
                              () => selectedGradeType = value,
                            ), // Обновляем состояние диалога
                        validator:
                            (value) => (value == null) ? 'Выберите тип' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          labelText: 'Комментарий (необязательно)',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      // --- Выбор даты оценки ---
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Дата: ${DateFormat.yMd('ru').format(selectedDate)}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (picked != null && picked != selectedDate) {
                            // Используем setDialogState для обновления даты ВНУТРИ диалога
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                      ),
                      // -------------------------
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Создаем объект Grade для возврата
                      final grade = Grade(
                        studentId: student.id,
                        studentName: student.shortName,
                        groupId: _selectedGroupInfo!.id,
                        subject: _selectedSubject!,
                        grade: gradeController.text.trim(),
                        gradeType: selectedGradeType,
                        comment: commentController.text.trim(),
                        date: selectedDate,
                        // teacherId и teacherName будут добавлены в сервисе
                        teacherId: '',
                        teacherName: '',
                        // gradeId: existingGrade?.id, // Передаем ID для обновления? (Зависит от логики сервиса)
                      );
                      Navigator.of(
                        context,
                      ).pop(grade); // Возвращаем созданную/обновленную оценку
                    }
                  },
                  child: Text(existingGrade == null ? 'Добавить' : 'Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );

    // Если пользователь сохранил оценку (result != null)
    if (result != null) {
      final journalService = ref.read(journalServiceProvider);
      try {
        // TODO: Доработать addOrUpdateGrade в JournalService для обработки обновления
        await journalService.addOrUpdateGrade(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Оценка сохранена'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка сохранения оценки: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildAttendanceList(
    List<User> students,
    List<AttendanceRecord> records,
  ) {
    // TODO: Реализовать UI (ListView, DataTable, ...)
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        // Находим запись о посещаемости для этого студента
        final record = records.firstWhereOrNull(
          (r) => r.studentId == student.id,
        );
        final status =
            record?.status ??
            AttendanceStatus.absentInvalid; // По умолчанию - пропуск
        final statusDisplay = record?.statusDisplay ?? 'Н'; // 'Н' - Неявка
        final statusColor =
            record?.statusColor(context) ?? Theme.of(context).colorScheme.error;
        final statusIcon = record?.statusIcon ?? Icons.cancel_outlined;

        return ListTile(
          title: Text(student.fullName),
          trailing: InkWell(
            // Делаем статус кликабельным
            onTap: () {
              // TODO: Показать диалог/меню для изменения статуса
              _showAttendanceStatusDialog(student, record);
            },
            child: Chip(
              label: Text(
                statusDisplay,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              avatar: Icon(statusIcon, color: statusColor, size: 16),
              backgroundColor: statusColor.withOpacity(0.15),
              padding: EdgeInsets.symmetric(horizontal: 8),
              side: BorderSide.none,
            ),
          ),
        );
      },
    );
    // return Center(child: Text('UI для списка посещаемости (студентов: ${students.length}, записей: ${records.length})'));
  }

  // --- Диалог изменения статуса посещаемости (Пример) ---
  Future<void> _showAttendanceStatusDialog(
    User student,
    AttendanceRecord? currentRecord,
  ) async {
    if (_selectedGroupInfo == null ||
        _selectedSubject == null ||
        _selectedLessonNumber == null)
      return;

    final journalService = ref.read(journalServiceProvider);
    final statuses = AttendanceStatus.values; // Все возможные статусы

    AttendanceStatus? selectedStatus = await showDialog<AttendanceStatus>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Статус: ${student.shortName}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                statuses.map((status) {
                  final tempRecord = AttendanceRecord(
                    // Создаем временный объект для получения иконки/цвета
                    studentId: '',
                    groupId: '',
                    date: DateTime.now(),
                    lessonNumber: 0,
                    subject: '',
                    status: status,
                    recordedByTeacherId: '',
                    timestamp: DateTime.now(),
                  );
                  return RadioListTile<AttendanceStatus>(
                    title: Text(
                      status.toString().split('.').last,
                    ), // Упрощенное название статуса
                    secondary: Icon(
                      tempRecord.statusIcon,
                      color: tempRecord.statusColor(context),
                    ),
                    value: status,
                    groupValue:
                        currentRecord?.status, // Текущий выбранный статус
                    onChanged: (value) => Navigator.of(context).pop(value),
                  );
                }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Отмена'),
            ),
          ],
        );
      },
    );

    if (selectedStatus != null) {
      // Создаем или обновляем запись о посещаемости
      final recordToSave = AttendanceRecord(
        studentId: student.id,
        studentName: student.shortName, // Можно fullName
        groupId: _selectedGroupInfo!.id,
        date: _selectedDate,
        lessonNumber: _selectedLessonNumber!,
        subject: _selectedSubject!,
        status: selectedStatus,
        // reason: ..., // Можно добавить поле для причины
        recordedByTeacherId: '', // Будет установлено в JournalService
        timestamp: DateTime.now(), // Будет установлено в JournalService
        // id: currentRecord?.id, // Передаем id, если обновляем? (Зависит от логики сервиса)
      );
      try {
        await journalService.addOrUpdateAttendanceRecord(recordToSave);
        // Провайдеры обновятся автоматически (если инвалидация настроена или стримы)
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка обновления статуса: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
