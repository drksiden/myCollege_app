import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherProfilePage extends StatelessWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100),
            const SizedBox(height: 10),
            Text(user?.displayName ?? 'Имя преподавателя', style: const TextStyle(fontSize: 20)),
            Text(user?.email ?? 'email@example.com'),
            const Text('Роль: преподаватель'),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Выйти'),
            )
          ],
        ),
      ),
    );
  }
}
