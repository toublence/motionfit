import 'package:flutter_test/flutter_test.dart';
import 'package:motionfit_squat/core/reviews/review_prompt_service.dart';

void main() {
  late _FakeReviewGateway gateway;
  late List<(String, DateTime)> attempts;
  final now = DateTime(2026, 8, 4);
  final context = ReviewPromptContext(
    validWorkoutCount: 3,
    distinctWorkoutDays: 2,
    appVersion: '1.0.7',
    installedAt: DateTime(2026, 1, 1),
    legacyReviewRequested: false,
    lastRequestAttemptAt: null,
    lastRequestAppVersion: null,
  );

  ReviewPromptService service() => ReviewPromptService(
    gateway: gateway,
    loadContext: () async => context,
    markAttempted: (version, attemptedAt) async {
      attempts.add((version, attemptedAt));
    },
    navigationDelay: Duration.zero,
    now: () => now,
  );

  setUp(() {
    gateway = _FakeReviewGateway();
    attempts = [];
  });

  test('review is requested only after returning home', () async {
    final subject = service();
    expect(
      await subject.prepareAutomaticRequest(anotherPromptWasPresented: false),
      isTrue,
    );
    expect(gateway.requestCount, 0);

    expect(
      await subject.requestAfterNavigation(
        isHomeVisible: () => true,
        isAppActive: () => true,
        isAnotherPromptVisible: () => false,
        isAdVisible: () => false,
      ),
      isTrue,
    );
    expect(gateway.requestCount, 1);
    expect(attempts, [(context.appVersion, now)]);
  });

  test('review request is idempotent in one app session', () async {
    final subject = service();
    await subject.prepareAutomaticRequest(anotherPromptWasPresented: false);
    await subject.requestAfterNavigation(
      isHomeVisible: () => true,
      isAppActive: () => true,
      isAnotherPromptVisible: () => false,
      isAdVisible: () => false,
    );

    expect(
      await subject.prepareAutomaticRequest(anotherPromptWasPresented: false),
      isFalse,
    );
    expect(gateway.requestCount, 1);
  });

  test('another prompt defers review to a later workout', () async {
    final subject = service();
    expect(
      await subject.prepareAutomaticRequest(anotherPromptWasPresented: true),
      isFalse,
    );
    expect(gateway.requestCount, 0);
  });

  test('review API failure does not throw or block the app', () async {
    gateway.throwOnRequest = true;
    final subject = service();
    await subject.prepareAutomaticRequest(anotherPromptWasPresented: false);

    expect(
      await subject.requestAfterNavigation(
        isHomeVisible: () => true,
        isAppActive: () => true,
        isAnotherPromptVisible: () => false,
        isAdVisible: () => false,
      ),
      isFalse,
    );
    expect(attempts, hasLength(1));
  });

  test('review is not requested while another prompt is visible', () async {
    final subject = service();
    await subject.prepareAutomaticRequest(anotherPromptWasPresented: false);

    expect(
      await subject.requestAfterNavigation(
        isHomeVisible: () => true,
        isAppActive: () => true,
        isAnotherPromptVisible: () => true,
        isAdVisible: () => false,
      ),
      isFalse,
    );
    expect(gateway.requestCount, 0);
    expect(attempts, isEmpty);
  });

  test(
    'manual rate opens the store without changing automatic limits',
    () async {
      final subject = service();

      expect(await subject.openStoreReviewPage(), isTrue);
      expect(gateway.storeOpenCount, 1);
      expect(attempts, isEmpty);
    },
  );
}

class _FakeReviewGateway implements ReviewGateway {
  int requestCount = 0;
  int storeOpenCount = 0;
  bool throwOnRequest = false;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> openStoreReviewPage() async {
    storeOpenCount++;
    return true;
  }

  @override
  Future<void> requestReview() async {
    requestCount++;
    if (throwOnRequest) throw StateError('review unavailable');
  }
}
