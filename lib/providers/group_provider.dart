// lib/providers/group_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/group.dart';

// Модель группы
class Group {
  final String id;
  final String name;
  final String specialization;
  final int year;
  final String? curatorId;
  final String? description;
  final List<String>? studentIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? curatorName;

  const Group({
    required this.id,
    required this.name,
    required this.specialization,
    required this.year,
    this.curatorId,
    this.description,
    this.studentIds,
    this.createdAt,
    this.updatedAt,
    this.curatorName,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      year: json['year'] ?? 1,
      curatorId: json['curatorId'],
      description: json['description'],
      studentIds: (json['studentIds'] as List<dynamic>?)?.cast<String>(),
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? (json['updatedAt'] as Timestamp).toDate()
              : null,
      curatorName: json['curatorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialization': specialization,
      'year': year,
      'curatorId': curatorId,
      'description': description,
      'studentIds': studentIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'curatorName': curatorName,
    };
  }
}

// Тестовые данные для групп
final _mockGroups = [
  Group(
    id: 'group_1',
    name: 'П2Г',
    specialization: 'Программирование',
    year: 2,
    description: 'Группа программистов 2 курса',
    curatorId: 'teacher_1',
    curatorName: 'Петров П.П.',
    studentIds: ['student_1', 'student_2'],
  ),
  Group(
    id: 'group_2',
    name: 'П1Г',
    specialization: 'Программирование',
    year: 1,
    description: 'Группа программистов 1 курса',
    curatorId: 'teacher_2',
    curatorName: 'Сидорова С.С.',
    studentIds: ['student_3', 'student_4'],
  ),
  Group(
    id: 'group_3',
    name: 'В2Г',
    specialization: 'Веб-разработка',
    year: 2,
    description: 'Группа веб-разработчиков 2 курса',
    curatorId: 'teacher_3',
    curatorName: 'Козлов К.К.',
    studentIds: ['student_5', 'student_6'],
  ),
  Group(
    id: 'group_4',
    name: 'В1Г',
    specialization: 'Веб-разработка',
    year: 1,
    description: 'Группа веб-разработчиков 1 курса',
    curatorId: 'teacher_4',
    curatorName: 'Иванова И.И.',
    studentIds: ['student_7', 'student_8'],
  ),
];

// Провайдер для получения всех групп
final groupsProvider = FutureProvider<List<Group>>((ref) async {
  // В реальном приложении здесь будет запрос к Firestore
  // Сейчас возвращаем тестовые данные
  await Future.delayed(const Duration(seconds: 1)); // Имитация задержки сети
  return _mockGroups;
});

// Провайдер для получения группы по ID
final groupByIdProvider = FutureProvider.family<Group?, String>((
  ref,
  groupId,
) async {
  final groups = await ref.watch(groupsProvider.future);
  return groups.firstWhere((group) => group.id == groupId);
});

// Провайдер для получения всех групп из Firestore
final allGroupsProvider = StreamProvider<List<Group>>((ref) {
  return FirebaseFirestore.instance
      .collection('groups')
      .orderBy('name')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            return Group.fromJson({...doc.data(), 'id': doc.id});
          } catch (e) {
            debugPrint('Error parsing group ${doc.id}: $e');
            return Group(
              id: doc.id,
              name: 'Ошибка загрузки',
              specialization: 'Неизвестно',
              year: 1,
            );
          }
        }).toList();
      });
});

// Провайдер для получения количества студентов в группе
final groupStudentCountProvider = FutureProvider.family<int, String>((
  ref,
  groupId,
) async {
  if (groupId.isEmpty) return 0;

  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('groupId', isEqualTo: groupId)
            .where('role', isEqualTo: 'student')
            .get();

    return snapshot.docs.length;
  } catch (e) {
    debugPrint('Error counting students in group $groupId: $e');
    return 0;
  }
});

// Тестовые данные для групп
final _mockGroupsNames = {
  'П2Г': 'Программирование 2 курс, группа Г',
  'П1А': 'Программирование 1 курс, группа А',
  'П1Б': 'Программирование 1 курс, группа Б',
  'П3В': 'Программирование 3 курс, группа В',
};

// Провайдер для получения названия группы по ID
final groupNameProvider = FutureProvider.family<String, String>((
  ref,
  groupId,
) async {
  if (groupId.isEmpty) return 'Группа не указана';

  try {
    final groupDoc =
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .get();

    if (!groupDoc.exists) {
      return 'Группа не найдена';
    }

    final data = groupDoc.data()!;
    final name = data['name'] as String? ?? '';
    final year = data['year'] as int? ?? 0;
    final specialization = data['specialization'] as String? ?? '';

    return '$specialization $year курс, группа $name';
  } catch (e) {
    debugPrint('Error getting group name for $groupId: $e');
    return 'Ошибка загрузки группы';
  }
});
