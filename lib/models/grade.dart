// lib/models/grade.dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'grade.freezed.dart';
part 'grade.g.dart';

// Конвертер для Firestore Timestamp <-> DateTime
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
class Grade with _$Grade {
  const factory Grade({
    // ID можно не хранить, т.к. это ID документа Firestore
    // String? gradeId,
    required String studentId,
    String? studentName, // Имя студента (денормализовано)
    String? groupId, // ID группы (денормализовано)
    required String subject, // Предмет
    required String
    grade, // Оценка (как строка, чтобы поддерживать '5', 'A', 'Зачет')
    String? gradeType, // Тип оценки: "Экзамен", "Контрольная", и т.д.
    String? comment, // Комментарий преподавателя
    // Используем DateTime и конвертер для поля даты
    @TimestampConverter() required DateTime date,
    String? teacherId, // ID преподавателя
    String? teacherName, // Имя преподавателя (денормализовано)
  }) = _Grade;

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);
}

// Вспомогательный extension для получения числового значения оценки (если возможно)
extension GradeValue on Grade {
  double? get numericGrade {
    // Пытаемся преобразовать строку в число
    // Поддерживаем оценки по 5-балльной или 100-балльной системе
    // Можно добавить логику для буквенных оценок (A=5, B=4 и т.д.)
    final numValue = double.tryParse(
      grade.replaceAll(',', '.'),
    ); // Заменяем запятую на точку, если нужно

    // Проверяем стандартные текстовые оценки
    if (numValue == null) {
      if (grade.toLowerCase() == 'зачет' || grade.toLowerCase() == 'зач') {
        return 1.0; // Условно 1 для зачета (для расчета типа "сдал/не сдал")
      }
      if (grade.toLowerCase() == 'незачет' || grade.toLowerCase() == 'незач') {
        return 0.0; // Условно 0 для незачета
      }
      // Добавь другие преобразования (A, B, C...) если нужно
    }
    return numValue;
  }

  // Цвет для оценки (пример)
  Color getColor(BuildContext context) {
    final numeric = numericGrade;
    if (numeric == null)
      return Colors.grey.shade600; // Для нечисловых/неизвестных

    // Примерная логика для 5-балльной системы (можно адаптировать)
    // Либо использовать процентную систему, если оценки до 100
    final colorScheme = Theme.of(context).colorScheme;
    if (numeric >= 4.5) return Colors.green.shade600; // Отлично
    if (numeric >= 3.5) return Colors.orange.shade700; // Хорошо
    if (numeric >= 2.5) return colorScheme.primary; // Удовл.
    return colorScheme.error; // Неудовл. / Незачет
  }
}
