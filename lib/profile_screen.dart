import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Пока заглушечные данные, позже заменим на реальные из БД
  final String name = 'Нурдаулет Сабырбекулы';
  final String studentId = '202500123';
  final String age = '20';
  final String course = '3 курс';
  final String specialty = 'Информатика';
  final String group = 'ИТ-321';
  final String profileImageUrl = ''; // сюда позже подставим ссылку

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Фото профиля
            CircleAvatar(
              radius: 60,
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 16),

            // Имя
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),
            const Divider(),

            // Информация
            _buildInfoRow('Студент ID', studentId),
            _buildInfoRow('Возраст', age),
            _buildInfoRow('Курс', course),
            _buildInfoRow('Группа', group),
            _buildInfoRow('Специальность', specialty),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
