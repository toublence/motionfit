import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';

void main() {
  test('analytics duration buckets use documented boundaries', () {
    expect(
      AnalyticsService.elapsedTimeBucket(const Duration(seconds: 2)),
      'under_3s',
    );
    expect(
      AnalyticsService.elapsedTimeBucket(const Duration(seconds: 3)),
      '3_10s',
    );
    expect(
      AnalyticsService.elapsedTimeBucket(const Duration(seconds: 11)),
      '11_30s',
    );
    expect(
      AnalyticsService.elapsedTimeBucket(const Duration(seconds: 31)),
      'over_30s',
    );
  });

  test('workout telemetry is reduced to non-identifying buckets', () {
    expect(AnalyticsService.repsBucket(0), '0');
    expect(AnalyticsService.repsBucket(5), '1_5');
    expect(AnalyticsService.repsBucket(10), '6_10');
    expect(AnalyticsService.repsBucket(31), '31_plus');
    expect(
      AnalyticsService.durationBucket(const Duration(seconds: 59)),
      'under_1m',
    );
    expect(
      AnalyticsService.trackingLossBucket(const Duration(seconds: 10)),
      'high',
    );
  });

  test('v2 logger rejects legacy names', () {
    final service = _service(_FakeAnalyticsSink());
    expect(() => service.logV2Event('workout_started'), throwsArgumentError);
  });

  test('all custom events use mf2 prefix and schema context', () async {
    final sink = _FakeAnalyticsSink();
    final service = _service(sink);

    service
      ..onboardingStarted(totalSteps: 3)
      ..workoutSetupViewed(plannedSets: 3, plannedRepsPerSet: 10)
      ..workoutStartTapped(
        plannedSets: 3,
        plannedRepsPerSet: 10,
        launchSource: 'workoutTab',
      )
      ..cameraInitializationStarted()
      ..cameraInitializationCompleted()
      ..calibrationStarted()
      ..calibrationCompleted(elapsed: const Duration(seconds: 4))
      ..workoutStarted(plannedSets: 3, plannedRepsPerSet: 10)
      ..firstRepDetected(elapsed: const Duration(seconds: 7))
      ..workoutComplete(reps: 30, sets: 3, durationSeconds: 90)
      ..reminderPermissionResult(result: 'granted')
      ..manualRateTapped(triggerSource: 'settings')
      ..challengeStarted(challengeType: 'sevenDay')
      ..adSkippedByPolicy(
        format: 'interstitial',
        placement: 'summary',
        skipReason: 'frequency_cap',
        workoutCompletionCount: 1,
        onboardingCompleted: true,
      );
    await service.flush();

    expect(sink.events, isNotEmpty);
    for (final event in sink.events) {
      expect(event.name, startsWith('mf2_'));
      expect(event.parameters['analytics_schema'], 2);
      expect(event.parameters['platform'], 'android');
      expect(event.parameters['app_version'], '1.2.6');
      expect(event.parameters['build_number'], '126');
    }
  });

  test('Android and iOS use the same names and platform parameters', () async {
    final androidSink = _FakeAnalyticsSink();
    final iosSink = _FakeAnalyticsSink();
    final android = _service(androidSink);
    final ios = _service(iosSink, platform: TargetPlatform.iOS);

    android.workoutSetupViewed(plannedSets: 2, plannedRepsPerSet: 8);
    ios.workoutSetupViewed(plannedSets: 2, plannedRepsPerSet: 8);
    await Future.wait([android.flush(), ios.flush()]);

    expect(androidSink.events.single.name, iosSink.events.single.name);
    expect(androidSink.events.single.parameters['platform'], 'android');
    expect(iosSink.events.single.parameters['platform'], 'ios');
  });

  test(
    'one session id spans camera, calibration, reps, and completion',
    () async {
      final sink = _FakeAnalyticsSink();
      final service = _service(sink);

      _beginWorkout(service);
      final sessionId = service.currentWorkoutSessionId;
      service
        ..cameraInitializationStarted()
        ..cameraInitializationCompleted()
        ..calibrationStarted()
        ..calibrationCompleted(elapsed: const Duration(seconds: 3))
        ..workoutStarted(plannedSets: 2, plannedRepsPerSet: 5)
        ..firstRepDetected(elapsed: const Duration(seconds: 5))
        ..workoutComplete(reps: 10, sets: 2, durationSeconds: 60);
      await service.flush();

      final workoutEvents = sink.events.where(
        (event) => event.parameters.containsKey('workout_session_id'),
      );
      expect(sessionId, isNotNull);
      expect(
        workoutEvents.map((event) => event.parameters['workout_session_id']),
        everyElement(sessionId),
      );
    },
  );

  test('a new workout creates a new session id', () {
    var sequence = 0;
    final service = _service(
      _FakeAnalyticsSink(),
      sessionIdFactory: () => 'session-${++sequence}',
    );

    _beginWorkout(service);
    final first = service.currentWorkoutSessionId;
    _beginWorkout(service);

    expect(first, 'session-1');
    expect(service.currentWorkoutSessionId, 'session-2');
  });

  test('frame-driven once events fire only once per workout', () async {
    final sink = _FakeAnalyticsSink();
    final service = _service(sink);
    _beginWorkout(service);

    for (var frame = 0; frame < 20; frame++) {
      service
        ..cameraInitializationStarted()
        ..cameraInitializationCompleted()
        ..calibrationStarted()
        ..calibrationCompleted(elapsed: const Duration(seconds: 4))
        ..workoutStarted(plannedSets: 2, plannedRepsPerSet: 5)
        ..firstRepDetected(elapsed: const Duration(seconds: 8));
    }
    await service.flush();

    for (final name in <String>{
      'mf2_camera_init_started',
      'mf2_camera_init_completed',
      'mf2_calibration_started',
      'mf2_calibration_completed',
      'mf2_workout_started',
      'mf2_first_rep_detected',
    }) {
      expect(sink.count(name), 1, reason: name);
    }
  });

  test('workout completion fires once', () async {
    final sink = _FakeAnalyticsSink();
    final service = _service(sink);
    _beginWorkout(service);

    service
      ..workoutComplete(reps: 10, sets: 2, durationSeconds: 60)
      ..workoutComplete(reps: 10, sets: 2, durationSeconds: 60);
    await service.flush();

    expect(sink.count('mf2_workout_completed'), 1);
  });

  test('cancelled and completed cannot both fire', () async {
    final sink = _FakeAnalyticsSink();
    final service = _service(sink);
    _beginWorkout(service);

    service
      ..workoutCancelled(
        cancelStage: 'during_set',
        cancelReason: 'user_exit',
        elapsed: const Duration(seconds: 20),
        detectedReps: 2,
        trackingLoss: Duration.zero,
      )
      ..workoutComplete(reps: 10, sets: 2, durationSeconds: 60);
    await service.flush();

    expect(sink.count('mf2_workout_cancelled'), 1);
    expect(sink.count('mf2_workout_completed'), 0);
  });

  test('failed and completed cannot both fire', () async {
    final sink = _FakeAnalyticsSink();
    final service = _service(sink);
    _beginWorkout(service);

    service
      ..workoutFailed(
        failureStage: 'camera_initialization',
        failureReason: 'unavailable',
        cameraState: 'failed',
        permissionState: 'granted',
        sessionState: 'preparing',
      )
      ..workoutComplete(reps: 10, sets: 2, durationSeconds: 60);
    await service.flush();

    expect(sink.count('mf2_workout_failed'), 1);
    expect(sink.count('mf2_workout_completed'), 0);
  });

  test(
    'camera failure and zero-rep exit do not report workout success',
    () async {
      final sink = _FakeAnalyticsSink();
      final service = _service(sink);
      _beginWorkout(service);

      service
        ..cameraInitializationStarted()
        ..cameraInitializationFailed(
          failureReason: 'unavailable',
          sessionState: 'preparing',
        )
        ..workoutComplete(reps: 0, sets: 0, durationSeconds: 3);
      await service.flush();

      expect(sink.count('mf2_camera_init_failed'), 1);
      expect(sink.count('mf2_workout_started'), 0);
      expect(sink.count('mf2_first_rep_detected'), 0);
      expect(sink.count('mf2_workout_completed'), 0);
    },
  );

  test('v2 workout flow emits no legacy custom workout names', () async {
    final sink = _FakeAnalyticsSink();
    final service = _service(sink);
    _beginWorkout(service);
    service
      ..calibrationCompleted(elapsed: const Duration(seconds: 3))
      ..workoutStarted(plannedSets: 2, plannedRepsPerSet: 5)
      ..firstRepDetected(elapsed: const Duration(seconds: 7))
      ..workoutComplete(reps: 10, sets: 2, durationSeconds: 60);
    await service.flush();

    const legacyNames = <String>{
      'workout_start',
      'workout_started',
      'workout_complete',
      'workout_completed',
      'first_rep_detected',
      'calibration_completed',
    };
    expect(
      sink.events.every((event) => !legacyNames.contains(event.name)),
      isTrue,
    );
    expect(sink.events.every((event) => event.name.startsWith('mf2_')), isTrue);
  });
}

void _beginWorkout(AnalyticsService service) {
  service.workoutStartTapped(
    plannedSets: 2,
    plannedRepsPerSet: 5,
    launchSource: 'workoutTab',
  );
}

AnalyticsService _service(
  _FakeAnalyticsSink sink, {
  TargetPlatform platform = TargetPlatform.android,
  String Function()? sessionIdFactory,
}) => AnalyticsService(
  sink: sink,
  platformOverride: platform,
  appVersion: '1.2.6',
  buildNumber: '126',
  sessionIdFactory: sessionIdFactory ?? () => 'session-id',
);

class _FakeAnalyticsSink implements AnalyticsSink {
  final List<_RecordedEvent> events = <_RecordedEvent>[];

  int count(String name) => events.where((event) => event.name == name).length;

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    events.add(_RecordedEvent(name, Map<String, Object>.of(parameters)));
  }

  @override
  Future<void> logScreenView(String screenName) async {}
}

class _RecordedEvent {
  const _RecordedEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object> parameters;
}
