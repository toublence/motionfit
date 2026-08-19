import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/core/ads/bottom_native_ad.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/plank/records/application/records_providers.dart'
    as plank_records;
import 'package:motionfit_squat/features/pushup/records/application/records_providers.dart'
    as pushup_records;
import 'package:motionfit_squat/features/records/application/records_providers.dart'
    as squat_records;
import 'package:motionfit_squat/features/records/presentation/models/growth_workout_record.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/calendar_records_view.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/record_components.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/squat/application/workout_preparation.dart';
import 'package:motionfit_squat/features/squat/presentation/workout_preparation_launcher.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({this.onStartWorkout, super.key});

  final VoidCallback? onStartWorkout;

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('records');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final squatSessions = ref.watch(squat_records.allSessionsProvider);
    final pushupSessions = ref.watch(pushup_records.allSessionsProvider);
    final plankSessions = ref.watch(plank_records.allSessionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordsTitle)),
      bottomNavigationBar: const NativeAdSection(
        placement: NativeAdPlacement.records,
      ),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
          child: switch ((squatSessions, pushupSessions, plankSessions)) {
            (
              AsyncData(value: final squats),
              AsyncData(value: final pushups),
              AsyncData(value: final planks),
            ) =>
              CalendarRecordsView(
                records: [
                  ...squats.map(GrowthWorkoutRecord.fromSquat),
                  ...pushups.map(GrowthWorkoutRecord.fromPushup),
                  ...planks.map(GrowthWorkoutRecord.fromPlank),
                ],
                onRefresh: _refreshSessions,
                onStartWorkout: _startWorkout,
              ),
            (AsyncError(), _, _) ||
            (_, AsyncError(), _) ||
            (_, _, AsyncError()) => RecordErrorState(
              title: l10n.errorGenericTitle,
              body: l10n.recordsLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: _invalidateSessions,
            ),
            _ => RecordLoadingState(label: l10n.recordsLoading),
          },
        ),
      ),
    );
  }

  Future<void> _refreshSessions() async {
    _invalidateSessions();
    ref.invalidate(squat_records.workoutStatisticsProvider);
    ref.invalidate(pushup_records.workoutStatisticsProvider);
    ref.invalidate(plank_records.workoutStatisticsProvider);
    await Future.wait([
      ref.read(squat_records.allSessionsProvider.future),
      ref.read(pushup_records.allSessionsProvider.future),
      ref.read(plank_records.allSessionsProvider.future),
    ]);
  }

  void _invalidateSessions() {
    ref.invalidate(squat_records.allSessionsProvider);
    ref.invalidate(pushup_records.allSessionsProvider);
    ref.invalidate(plank_records.allSessionsProvider);
  }

  Future<void> _startWorkout() async {
    final callback = widget.onStartWorkout;
    if (callback != null) {
      callback();
      return;
    }
    final plan = ref.read(preferencesControllerProvider).lastWorkoutPlan;
    await openWorkoutPreparation(
      context,
      ref,
      WorkoutPreparation.newWorkout(plan),
    );
  }
}
