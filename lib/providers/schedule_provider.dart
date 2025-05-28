import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_entry.dart';
import '../services/schedule_service.dart';
import '../core/auth_service.dart';

final scheduleServiceProvider = Provider((ref) => ScheduleService());

final scheduleProvider = StreamProvider.autoDispose<List<ScheduleEntry>>((ref) {
  print('DEBUG: ScheduleProvider: Starting to fetch schedule');
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  final scheduleService = ref.watch(scheduleServiceProvider);

  if (user == null || user.groupId == null) {
    print('DEBUG: ScheduleProvider: No user or groupId found');
    return Stream.value([]);
  }

  print('DEBUG: ScheduleProvider: Fetching schedule for group ${user.groupId}');
  return scheduleService.getScheduleByGroup(user.groupId!);
});
