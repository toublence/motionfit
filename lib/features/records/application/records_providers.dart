import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/records/domain/retention_metrics.dart';
import 'package:motionfit_squat/features/records/domain/workout_session_details.dart';
import 'package:motionfit_squat/features/records/domain/workout_statistics.dart';

final allSessionsProvider = FutureProvider<List<WorkoutSessionDetails>>((ref) {
  return ref.watch(workoutRepositoryProvider).loadSessions();
});

final recoverableSessionProvider = FutureProvider<WorkoutSessionDetails?>((
  ref,
) {
  return ref.watch(workoutRepositoryProvider).loadRecoverableSession();
});

final todaySessionsProvider = FutureProvider<List<WorkoutSessionDetails>>((
  ref,
) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return ref
      .watch(workoutRepositoryProvider)
      .loadSessions(from: start, to: start.add(const Duration(days: 1)));
});

final retentionMetricsProvider = FutureProvider<RetentionMetrics>((ref) async {
  final sessions = await ref.watch(allSessionsProvider.future);
  return RetentionMetrics.fromSessions(sessions);
});

final selectedRecordDateProvider =
    NotifierProvider<SelectedRecordDate, DateTime>(SelectedRecordDate.new);

class SelectedRecordDate extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void select(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

final selectedDateSessionsProvider =
    FutureProvider<List<WorkoutSessionDetails>>((ref) {
      final date = ref.watch(selectedRecordDateProvider);
      return ref
          .watch(workoutRepositoryProvider)
          .loadSessions(from: date, to: date.add(const Duration(days: 1)));
    });

class StatisticsPeriod {
  const StatisticsPeriod(this.from, this.to);
  final DateTime? from;
  final DateTime? to;
}

final statisticsPeriodProvider =
    NotifierProvider<StatisticsPeriodController, StatisticsPeriod>(
      StatisticsPeriodController.new,
    );

class StatisticsPeriodController extends Notifier<StatisticsPeriod> {
  @override
  StatisticsPeriod build() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return StatisticsPeriod(
      tomorrow.subtract(const Duration(days: 7)),
      tomorrow,
    );
  }

  void setPeriod(DateTime? from, DateTime? to) {
    state = StatisticsPeriod(from, to);
  }
}

final workoutStatisticsProvider = FutureProvider<WorkoutStatistics>((ref) {
  final period = ref.watch(statisticsPeriodProvider);
  return ref
      .watch(workoutRepositoryProvider)
      .loadStatistics(from: period.from, to: period.to);
});

final sessionDetailsProvider =
    FutureProvider.family<WorkoutSessionDetails?, String>((ref, id) {
      return ref.watch(workoutRepositoryProvider).loadSession(id);
    });
