// lib/widgets/approval_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth_service.dart';
import '../models/user.dart';
import '../models/approval.dart';
import '../providers/approval_provider.dart';
import 'login_page.dart';
import 'approval_pending_page.dart';
import 'approval_rejected_page.dart';

class ApprovalGate extends ConsumerWidget {
  final Widget child;

  const ApprovalGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Ошибка авторизации', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(authStateProvider),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          ),
      data: (user) {
        if (user == null) {
          return const LoginPage();
        }

        return ref
            .watch(userApprovalProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ошибка проверки статуса',
                            style: textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.refresh(userApprovalProvider),
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    ),
                  ),
              data: (approval) {
                if (user.status == 'active') {
                  return child;
                }

                if (approval == null) {
                  return const ApprovalPendingPage();
                }

                if (!approval.isApproved) {
                  return ApprovalRejectedPage(reason: approval.rejectionReason);
                }

                return child;
              },
            );
      },
    );
  }
}
