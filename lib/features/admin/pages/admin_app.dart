import 'package:flutter/material.dart';
import 'admin_login_page.dart';
import 'admin_home_page.dart';
import '../providers/admin_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Админка | MyCollege',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        home: const _AdminAuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _AdminAuthGate extends ConsumerWidget {
  const _AdminAuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(adminAuthProvider);
    if (isLoggedIn) {
      return const AdminHomePage();
    } else {
      return const AdminLoginPage();
    }
  }
}
