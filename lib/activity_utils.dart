import 'package:flutter/material.dart';

// Утилиты для ActivitiesScreen (можно вынести в отдельный activity_utils.dart)
IconData getActivityIcon(String type) {
  switch (type) {
    case 'academic':
      return Icons.school_outlined; // Используем outlined иконки
    case 'event':
      return Icons.celebration_outlined;
    case 'social':
      return Icons.groups_outlined;
    default:
      return Icons.info_outline;
  }
}

Color getActivityColor(BuildContext context, String type) {
  // Используем цвета из темы для лучшей адаптивности
  final colorScheme = Theme.of(context).colorScheme;
  switch (type) {
    case 'academic':
      return colorScheme.primary; // Синий/основной цвет темы
    case 'event':
      return Colors.orange.shade700; // Оранжевый
    case 'social':
      return Colors.green.shade600; // Зеленый
    default:
      return Colors.grey.shade600; // Серый
  }
}
