// lib/features/teacher/pages/grades_page.dart (УЛУЧШЕННАЯ ВЕРСИЯ)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/providers/teacher_goups_provider.dart';
import 'package:flutter_application_1/providers/teacher_subjects_provider.dart'; // Новый импорт
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/group.dart';
import '../../../models/user.dart' as app_user;
import '../../../models/subject.dart';
import '../providers/teacher_providers.dart';
import 'grades_history_page.dart'; // Импорт страницы истории

class GradesPage extends ConsumerStatefulWidget {
  const GradesPage({super.key});

  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {
  Group? selectedGroup;
  app_user.User? selectedStudent;
  Subject? selectedSubject;

  final _gradeController = TextEditingController();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  // Тип оценки
  String gradeType =
      'numeric'; // 'numeric' для числовой оценки, 'pass_fail' для зачет/незачет

  @override
  void dispose() {
    _gradeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // Получение студентов группы
  Future<List<app_user.User>> _getStudentsByGroup(String groupId) async {
    try {
      print('DEBUG: Getting students for group: $groupId');

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('groupId', isEqualTo: groupId)
              .where('role', isEqualTo: 'student')
              .where('status', isEqualTo: 'active')
              .get();

      print('DEBUG: Found ${snapshot.docs.length} students');

      final students =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return app_user.User.fromJson({...data, 'uid': doc.id});
          }).toList();

      students.sort((a, b) {
        final comparison = a.lastName.compareTo(b.lastName);
        if (comparison != 0) return comparison;
        return a.firstName.compareTo(b.firstName);
      });

      return students;
    } catch (e) {
      print('DEBUG: Error getting students: $e');
      return [];
    }
  }

  // Получение предметов преподавателя
  Future<List<Subject>> _getTeacherSubjects(String teacherId) async {
    try {
      print('DEBUG: Getting subjects for teacher: $teacherId');

      // Получаем все документы расписания
      final schedulesSnapshot =
          await FirebaseFirestore.instance.collection('schedules').get();

      // Собираем уникальные ID предметов из расписания преподавателя
      final Set<String> subjectIds = {};

      for (final scheduleDoc in schedulesSnapshot.docs) {
        final scheduleData = scheduleDoc.data();
        final lessons = scheduleData['lessons'] as List<dynamic>? ?? [];

        for (final lesson in lessons) {
          if (lesson['teacherId'] == teacherId) {
            final subjectId = lesson['subjectId']?.toString();
            if (subjectId != null && subjectId.isNotEmpty) {
              subjectIds.add(subjectId);
            }
          }
        }
      }

      print('DEBUG: Found subject IDs: $subjectIds');

      if (subjectIds.isEmpty) {
        return [];
      }

      // Получаем данные предметов
      final subjects = <Subject>[];

      // Firestore ограничивает whereIn до 10 элементов, поэтому делаем батчи
      final subjectIdsList = subjectIds.toList();
      for (int i = 0; i < subjectIdsList.length; i += 10) {
        final batch = subjectIdsList.skip(i).take(10).toList();

        final subjectsSnapshot =
            await FirebaseFirestore.instance
                .collection('subjects')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        for (final subjectDoc in subjectsSnapshot.docs) {
          try {
            final subject = Subject.fromJson({
              ...subjectDoc.data(),
              'id': subjectDoc.id,
            });
            subjects.add(subject);
          } catch (e) {
            print('DEBUG: Error parsing subject ${subjectDoc.id}: $e');
          }
        }
      }

      // Сортируем предметы по названию
      subjects.sort((a, b) => a.name.compareTo(b.name));

      print('DEBUG: Final subjects count: ${subjects.length}');
      return subjects;
    } catch (e) {
      print('DEBUG: Error getting teacher subjects: $e');
      return [];
    }
  }

  // Валидация оценки
  String? _validateGrade(String? value) {
    if (gradeType == 'pass_fail') {
      return null; // Для зачет/незачет валидация не нужна
    }

    if (value == null || value.trim().isEmpty) {
      return 'Введите оценку';
    }

    final grade = int.tryParse(value.trim());
    if (grade == null) {
      return 'Оценка должна быть числом';
    }

    if (grade < 0 || grade > 100) {
      return 'Оценка должна быть от 0 до 100';
    }

    return null;
  }

  // Сохранение оценки
  Future<void> _saveGrade() async {
    if (gradeType == 'numeric' && !_formKey.currentState!.validate()) return;

    if (selectedGroup == null ||
        selectedStudent == null ||
        selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Выберите группу, студента и предмет'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final teacherName = ref.read(teacherNameProvider);
      final comment = _commentController.text.trim();

      Map<String, dynamic> gradeData = {
        'studentId': selectedStudent!.uid,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'groupId': selectedGroup!.id,
        'subject': selectedSubject!.name,
        'subjectId': selectedSubject!.id,
        'gradeType': gradeType,
        'comment': comment.isEmpty ? null : comment,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (gradeType == 'numeric') {
        final grade = int.parse(_gradeController.text.trim());
        gradeData['score'] = grade;
        gradeData['gradeSystem'] = '100';
      } else {
        // Для зачет/незачет используем 1 для зачета, 0 для незачета
        final passed =
            _gradeController.text.trim().toLowerCase() == 'зачет' ||
            _gradeController.text.trim().toLowerCase() == 'pass' ||
            _gradeController.text.trim() == '1';
        gradeData['score'] = passed ? 1 : 0;
        gradeData['gradeSystem'] = 'pass_fail';
        gradeData['passed'] = passed;
      }

      await FirebaseFirestore.instance.collection('grades').add(gradeData);

      if (mounted) {
        final gradeText =
            gradeType == 'numeric'
                ? _gradeController.text.trim()
                : (gradeData['passed'] == true ? 'Зачет' : 'Незачет');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Оценка "$gradeText" поставлена студенту ${selectedStudent!.fullName}',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Сбрасываем форму частично
        setState(() {
          selectedStudent = null;
          _gradeController.clear();
          _commentController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выставить оценку'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'История оценок',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GradesHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Тип оценки
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Тип оценки',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Числовая оценка'),
                              subtitle: const Text('0-100 баллов'),
                              value: 'numeric',
                              groupValue: gradeType,
                              onChanged: (value) {
                                setState(() {
                                  gradeType = value!;
                                  _gradeController.clear();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Зачет/Незачет'),
                              subtitle: const Text('Зачтено/Не зачтено'),
                              value: 'pass_fail',
                              groupValue: gradeType,
                              onChanged: (value) {
                                setState(() {
                                  gradeType = value!;
                                  _gradeController.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Выбор группы
              Consumer(
                builder: (context, ref, child) {
                  final teacherGroupsAsync = ref.watch(
                    teacherGroupsProvider(teacherId),
                  );

                  return teacherGroupsAsync.when(
                    loading:
                        () => const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    error:
                        (error, stack) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.error,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ошибка загрузки групп',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                                Text(
                                  error.toString(),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                    data: (groups) {
                      if (groups.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: colorScheme.primary,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Нет назначенных групп',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const Text(
                                  'У вас нет групп в расписании. Обратитесь к администратору.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return _buildDropdownCard(
                        title: 'Группа',
                        value: selectedGroup?.fullName,
                        hint: 'Выберите группу',
                        icon: Icons.group,
                        items:
                            groups
                                .map(
                                  (group) => DropdownMenuItem<Group>(
                                    value: group,
                                    child: Text(
                                      group.fullName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (Group? value) {
                          setState(() {
                            selectedGroup = value;
                            selectedStudent = null;
                            selectedSubject = null;
                          });
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Выбор студента
              if (selectedGroup != null)
                FutureBuilder<List<app_user.User>>(
                  future: _getStudentsByGroup(selectedGroup!.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colorScheme.error,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ошибка загрузки студентов',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final students = snapshot.data ?? [];

                    if (students.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.primary,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Нет студентов',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                              Text(
                                'В группе "${selectedGroup!.name}" нет активных студентов',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return _buildDropdownCard(
                      title: 'Студент',
                      value: selectedStudent?.fullName,
                      hint: 'Выберите студента',
                      icon: Icons.person,
                      items:
                          students
                              .map(
                                (student) => DropdownMenuItem<app_user.User>(
                                  value: student,
                                  child: Text(
                                    student.fullName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (app_user.User? value) {
                        setState(() {
                          selectedStudent = value;
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),

              // Выбор предмета
              if (selectedGroup != null)
                Consumer(
                  builder: (context, ref, child) {
                    final teacherSubjectsAsync = ref.watch(
                      teacherSubjectsProvider(teacherId),
                    );

                    return teacherSubjectsAsync.when(
                      loading:
                          () => const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                      error:
                          (error, stack) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: colorScheme.error,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ошибка загрузки предметов',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                  Text(
                                    error.toString(),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      data: (subjects) {
                        if (subjects.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: colorScheme.primary,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Нет предметов',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const Text(
                                    'У вас нет предметов в расписании',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return _buildDropdownCard(
                          title: 'Предмет',
                          value: selectedSubject?.name,
                          hint: 'Выберите предмет',
                          icon: Icons.book,
                          items:
                              subjects
                                  .map(
                                    (subject) => DropdownMenuItem<Subject>(
                                      value: subject,
                                      child: Text(
                                        subject.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (Subject? value) {
                            setState(() {
                              selectedSubject = value;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),

              // Ввод оценки и комментария
              if (selectedStudent != null && selectedSubject != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Оценка и комментарий',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Поле ввода оценки
                        if (gradeType == 'numeric') ...[
                          TextFormField(
                            controller: _gradeController,
                            decoration: InputDecoration(
                              labelText: 'Оценка',
                              hintText: 'Введите от 0 до 100',
                              prefixIcon: Icon(
                                Icons.grade,
                                color: colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixText: '/100',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: _validateGrade,
                            autofocus: true,
                          ),
                        ] else ...[
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Результат',
                              prefixIcon: Icon(
                                Icons.grade,
                                color: colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            value:
                                _gradeController.text.isEmpty
                                    ? null
                                    : _gradeController.text,
                            items: const [
                              DropdownMenuItem(
                                value: 'зачет',
                                child: Text('Зачет'),
                              ),
                              DropdownMenuItem(
                                value: 'незачет',
                                child: Text('Незачет'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _gradeController.text = value ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Выберите результат';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Поле комментария
                        TextFormField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            labelText: 'Комментарий (необязательно)',
                            hintText: 'Добавьте комментарий к оценке...',
                            prefixIcon: Icon(
                              Icons.comment,
                              color: colorScheme.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 3,
                          maxLength: 200,
                        ),
                        const SizedBox(height: 24),

                        // Кнопка сохранения
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _saveGrade,
                            icon:
                                isLoading
                                    ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.onPrimary,
                                      ),
                                    )
                                    : Icon(
                                      Icons.save,
                                      color: colorScheme.onPrimary,
                                    ),
                            label: Text(
                              'Поставить оценку',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Информационная карточка
                Card(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Студент: ${selectedStudent!.fullName}',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Предмет: ${selectedSubject!.name}'),
                              Text('Группа: ${selectedGroup!.name}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCard<T>({
    required String title,
    required String? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<T>(
              value:
                  null, // Всегда null, чтобы показывать выбранное значение в hint
              hint: Text(value ?? hint),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              isExpanded: true,
              dropdownColor: colorScheme.surface,
              style: TextStyle(color: colorScheme.onSurface),
              items: items,
              onChanged: onChanged,
              menuMaxHeight: 300, // Ограничиваем высоту выпадающего меню
            ),
          ],
        ),
      ),
    );
  }
}
