import 'dart:async';
import 'dart:io';

import 'package:in_app_review/in_app_review.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/diagnostics/crash_reporting_service.dart';
import 'package:motionfit_squat/core/reviews/review_prompt_policy.dart';
import 'package:motionfit_squat/core/reviews/store_listing_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewPromptContext {
  const ReviewPromptContext({
    required this.validWorkoutCount,
    required this.distinctWorkoutDays,
    required this.appVersion,
    required this.installedAt,
    required this.legacyReviewRequested,
    required this.lastRequestAttemptAt,
    required this.lastRequestAppVersion,
  });

  final int validWorkoutCount;
  final int distinctWorkoutDays;
  final String appVersion;
  final DateTime installedAt;
  final bool legacyReviewRequested;
  final DateTime? lastRequestAttemptAt;
  final String? lastRequestAppVersion;
}

abstract interface class ReviewGateway {
  Future<bool> isAvailable();

  Future<void> requestReview();

  Future<bool> openStoreReviewPage();
}

class SystemReviewGateway implements ReviewGateway {
  SystemReviewGateway({InAppReview? inAppReview})
    : _inAppReview = inAppReview ?? InAppReview.instance;

  final InAppReview _inAppReview;

  @override
  Future<bool> isAvailable() => _inAppReview.isAvailable();

  @override
  Future<void> requestReview() => _inAppReview.requestReview();

  @override
  Future<bool> openStoreReviewPage() async {
    if (Platform.isIOS) {
      return launchUrl(
        Uri.parse(
          'https://apps.apple.com/app/id${StoreListingConfig.iosAppStoreId}'
          '?action=write-review',
        ),
        mode: LaunchMode.externalApplication,
      );
    }
    if (Platform.isAndroid) {
      final packageName = (await PackageInfo.fromPlatform()).packageName;
      final marketUri = Uri.parse('market://details?id=$packageName');
      try {
        if (await launchUrl(marketUri, mode: LaunchMode.externalApplication)) {
          return true;
        }
      } on Object {
        // Devices without Play Store fall back to the web listing.
      }
      return launchUrl(
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName'),
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }
}

class ReviewPromptService {
  ReviewPromptService({
    required ReviewGateway gateway,
    required Future<ReviewPromptContext> Function() loadContext,
    required Future<void> Function(String version, DateTime attemptedAt)
    markAttempted,
    AnalyticsService? analytics,
    CrashReportingService? crashReporting,
    bool automaticRequestsEnabled = true,
    Duration navigationDelay = const Duration(milliseconds: 1500),
    DateTime Function()? now,
  }) : _gateway = gateway,
       _loadContext = loadContext,
       _markAttempted = markAttempted,
       _analytics = analytics,
       _crashReporting = crashReporting,
       _automaticRequestsEnabled = automaticRequestsEnabled,
       _navigationDelay = navigationDelay,
       _now = now ?? DateTime.now;

  final ReviewGateway _gateway;
  final Future<ReviewPromptContext> Function() _loadContext;
  final Future<void> Function(String version, DateTime attemptedAt)
  _markAttempted;
  final AnalyticsService? _analytics;
  final CrashReportingService? _crashReporting;
  final bool _automaticRequestsEnabled;
  final Duration _navigationDelay;
  final DateTime Function() _now;

  bool _pending = false;
  bool _requestInProgress = false;
  bool _requestedInCurrentSession = false;
  bool _openingStore = false;
  ReviewPromptContext? _pendingContext;

  bool get hasPendingAutomaticRequest => _pending;

  Future<bool> prepareAutomaticRequest({
    required bool anotherPromptWasPresented,
  }) async {
    if (!_automaticRequestsEnabled) return false;
    if (_pending || _requestInProgress || _requestedInCurrentSession) {
      _logSkipped('same_session_requested');
      return false;
    }
    if (anotherPromptWasPresented) {
      _logSkipped('notification_prompt_shown');
      return false;
    }

    try {
      final context = await _loadContext();
      final now = _now();
      final decision = ReviewPromptPolicy.evaluate(
        validWorkoutCount: context.validWorkoutCount,
        distinctWorkoutDays: context.distinctWorkoutDays,
        appVersion: context.appVersion,
        legacyReviewRequested: context.legacyReviewRequested,
        lastRequestAppVersion: context.lastRequestAppVersion,
        lastRequestAttemptAt: context.lastRequestAttemptAt,
        now: now,
      );
      if (decision == ReviewEligibilityDecision.legacyRequestNeedsMigration) {
        await _markAttempted(context.appVersion, now);
        _logSkipped('already_requested_this_version', context: context);
        return false;
      }
      if (decision != ReviewEligibilityDecision.eligible) {
        _logSkipped(_skipReason(decision), context: context);
        return false;
      }

      final triggerSource = context.validWorkoutCount == 3
          ? 'third_valid_workout'
          : 'later_valid_workout';
      _analytics?.reviewEligibilityMet(
        validWorkoutCount: context.validWorkoutCount,
        distinctWorkoutDays: context.distinctWorkoutDays,
        triggerSource: triggerSource,
        daysSinceInstall: now.difference(context.installedAt).inDays,
        daysSinceLastRequest: _daysSinceLastRequest(context, now),
      );
      _analytics?.reviewRequestScheduled(
        validWorkoutCount: context.validWorkoutCount,
        distinctWorkoutDays: context.distinctWorkoutDays,
        triggerSource: triggerSource,
        daysSinceInstall: now.difference(context.installedAt).inDays,
        daysSinceLastRequest: _daysSinceLastRequest(context, now),
      );
      _pendingContext = context;
      _pending = true;
      return true;
    } on Object catch (error, stackTrace) {
      _recordNonFatal(error, stackTrace, 'review_eligibility_evaluation');
      return false;
    }
  }

  Future<bool> requestAfterNavigation({
    required bool Function() isHomeVisible,
    required bool Function() isAppActive,
    required bool Function() isAnotherPromptVisible,
    required bool Function() isAdVisible,
  }) async {
    if (!_pending || _requestInProgress || _requestedInCurrentSession) {
      return false;
    }
    await Future<void>.delayed(_navigationDelay);
    if (!_pending) return false;
    if (!isAppActive()) return _cancelPending('app_not_active');
    if (!isHomeVisible()) return _cancelPending('navigation_in_progress');
    if (isAnotherPromptVisible()) {
      return _cancelPending('another_prompt_visible');
    }
    if (isAdVisible()) return _cancelPending('ad_visible');

    final context = _pendingContext;
    if (context == null) return _cancelPending('unknown');
    _requestInProgress = true;
    try {
      if (!await _gateway.isAvailable()) {
        return _cancelPending('review_api_unavailable', context: context);
      }
      final attemptedAt = _now();
      await _markAttempted(context.appVersion, attemptedAt);
      _pending = false;
      _pendingContext = null;
      _requestedInCurrentSession = true;
      final triggerSource = context.validWorkoutCount == 3
          ? 'third_valid_workout'
          : 'later_valid_workout';
      _analytics?.reviewPromptRequested(
        validWorkoutCount: context.validWorkoutCount,
        distinctWorkoutDays: context.distinctWorkoutDays,
        triggerSource: triggerSource,
        daysSinceInstall: attemptedAt.difference(context.installedAt).inDays,
        daysSinceLastRequest: _daysSinceLastRequest(context, attemptedAt),
      );
      await _gateway.requestReview();
      _analytics?.reviewRequestCompleted(
        validWorkoutCount: context.validWorkoutCount,
        distinctWorkoutDays: context.distinctWorkoutDays,
        triggerSource: triggerSource,
        daysSinceInstall: attemptedAt.difference(context.installedAt).inDays,
        daysSinceLastRequest: _daysSinceLastRequest(context, attemptedAt),
      );
      return true;
    } on Object catch (error, stackTrace) {
      _pending = false;
      _pendingContext = null;
      _recordNonFatal(error, stackTrace, 'in_app_review_request');
      return false;
    } finally {
      _requestInProgress = false;
    }
  }

  Future<bool> openStoreReviewPage() async {
    if (_openingStore) return false;
    _openingStore = true;
    _analytics?.manualRateTapped(triggerSource: 'manual_settings');
    try {
      final opened = await _gateway.openStoreReviewPage();
      if (opened) {
        _analytics?.storeReviewPageOpened(triggerSource: 'manual_settings');
      } else {
        _analytics?.storeReviewPageFailed(
          triggerSource: 'manual_settings',
          failureReason: 'store_unavailable',
        );
      }
      return opened;
    } on Object catch (error, stackTrace) {
      _analytics?.storeReviewPageFailed(
        triggerSource: 'manual_settings',
        failureReason: 'open_failed',
      );
      _recordNonFatal(error, stackTrace, 'store_review_page_open');
      return false;
    } finally {
      _openingStore = false;
    }
  }

  bool _cancelPending(String reason, {ReviewPromptContext? context}) {
    _logSkipped(reason, context: context ?? _pendingContext);
    _pending = false;
    _pendingContext = null;
    return false;
  }

  void _logSkipped(String reason, {ReviewPromptContext? context}) {
    final value = context;
    final now = _now();
    _analytics?.reviewRequestSkipped(
      validWorkoutCount: value?.validWorkoutCount ?? 0,
      distinctWorkoutDays: value?.distinctWorkoutDays ?? 0,
      triggerSource: 'post_workout_home',
      skipReason: reason,
      daysSinceInstall: value == null
          ? 0
          : now.difference(value.installedAt).inDays,
      daysSinceLastRequest: value == null
          ? null
          : _daysSinceLastRequest(value, now),
    );
  }

  int? _daysSinceLastRequest(ReviewPromptContext context, DateTime now) =>
      context.lastRequestAttemptAt == null
      ? null
      : now.difference(context.lastRequestAttemptAt!).inDays;

  String _skipReason(ReviewEligibilityDecision decision) => switch (decision) {
    ReviewEligibilityDecision.notEnoughValidWorkouts =>
      'minimum_workouts_not_reached',
    ReviewEligibilityDecision.notEnoughWorkoutDays =>
      'insufficient_distinct_days',
    ReviewEligibilityDecision.alreadyRequestedThisVersion =>
      'already_requested_this_version',
    ReviewEligibilityDecision.cooldownNotElapsed => 'cooldown_not_elapsed',
    ReviewEligibilityDecision.legacyRequestNeedsMigration =>
      'already_requested_this_version',
    ReviewEligibilityDecision.eligible => 'unknown',
  };

  void _recordNonFatal(Object error, StackTrace stackTrace, String reason) {
    final crashReporting = _crashReporting;
    if (crashReporting == null) return;
    unawaited(crashReporting.recordNonFatal(error, stackTrace, reason: reason));
  }
}
