// lib/widgets/status_notification_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth_service.dart';

/// Виджет для отображения уведомлений о статусе пользователя
/// Можно использовать в AppBar или как баннер сверху экрана
class StatusNotificationBanner extends ConsumerWidget {
  final bool compact;
  final bool showActions;

  const StatusNotificationBanner({
    super.key,
    this.compact = true,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        switch (user.status) {
          case 'pending_approval':
            return _buildPendingBanner(context);
          case 'rejected':
            return _buildRejectedBanner(context, ref);
          case 'suspended':
            return _buildSuspendedBanner(context, ref);
          case 'active':
          default:
            return const SizedBox.shrink();
        }
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPendingBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_empty,
            color: Colors.orange.shade700,
            size: compact ? 20 : 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ожидание подтверждения',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ваша заявка находится на рассмотрении администратором',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showActions)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.orange.shade700,
                size: 20,
              ),
              tooltip: 'Обновить статус',
              onPressed: () {
                // Обновляем состояние пользователя
                // ref.refresh(authStateProvider);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRejectedBanner(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.red.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: Colors.red.shade700,
            size: compact ? 20 : 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Заявка отклонена',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Обратитесь к администратору для получения информации',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
                  ),
                ],
              ],
            ),
          ),
          if (showActions)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.red.shade700, size: 20),
              tooltip: 'Выйти',
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSuspendedBanner(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.block,
            color: Colors.orange.shade700,
            size: compact ? 20 : 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Аккаунт заблокирован',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Обратитесь к администратору для восстановления доступа',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showActions)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.orange.shade700, size: 20),
              tooltip: 'Выйти',
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
              },
            ),
        ],
      ),
    );
  }
}

/// Небольшой индикатор статуса для использования в углу экрана
class StatusIndicator extends ConsumerWidget {
  const StatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null || user.status == 'active') {
          return const SizedBox.shrink();
        }

        Color color;
        IconData icon;
        String tooltip;

        switch (user.status) {
          case 'pending_approval':
            color = Colors.orange;
            icon = Icons.hourglass_empty;
            tooltip = 'Ожидание подтверждения';
            break;
          case 'rejected':
            color = Colors.red;
            icon = Icons.cancel;
            tooltip = 'Заявка отклонена';
            break;
          case 'suspended':
            color = Colors.orange;
            icon = Icons.block;
            tooltip = 'Аккаунт заблокирован';
            break;
          default:
            return const SizedBox.shrink();
        }

        return Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
