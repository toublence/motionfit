import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/ads/bottom_native_ad.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/records/application/records_providers.dart';
import 'package:motionfit_squat/features/records/presentation/widgets/record_components.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_analysis.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/domain/services/rep_clip.dart';
import 'package:motionfit_squat/features/squat/presentation/rep_review_formatters.dart';
import 'package:video_player/video_player.dart';

class RepReviewScreen extends ConsumerWidget {
  const RepReviewScreen({
    required this.sessionId,
    required this.repNumber,
    super.key,
  });

  final String sessionId;
  final int repNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final details = ref.watch(sessionDetailsProvider(sessionId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.repTimelineTitle)),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 20),
          child: switch (details) {
            AsyncData(value: final value?) => () {
              final analyses = value.repAnalyses.toList()
                ..sort((a, b) => a.repNumber.compareTo(b.repNumber));
              final index = analyses.indexWhere(
                (analysis) => analysis.repNumber == repNumber,
              );
              if (index < 0) {
                return RecordErrorState(
                  title: l10n.errorGenericTitle,
                  body: l10n.recordsLoadError,
                  retryLabel: l10n.commonBack,
                  onRetry: () => Navigator.pop(context),
                );
              }
              return _RepReviewContent(
                sessionId: sessionId,
                analysis: analyses[index],
                analyses: analyses,
                currentIndex: index,
                videoPath: value.session.videoPath,
                analyticsSessionId: value.session.analyticsSessionId,
              );
            }(),
            AsyncData() || AsyncError() => RecordErrorState(
              title: l10n.errorGenericTitle,
              body: l10n.recordsLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(sessionDetailsProvider(sessionId)),
            ),
            _ => RecordLoadingState(label: l10n.recordsLoading),
          },
        ),
      ),
    );
  }
}

class _RepReviewContent extends ConsumerStatefulWidget {
  const _RepReviewContent({
    required this.sessionId,
    required this.analysis,
    required this.analyses,
    required this.currentIndex,
    required this.videoPath,
    required this.analyticsSessionId,
  });

  final String sessionId;
  final RepAnalysis analysis;
  final List<RepAnalysis> analyses;
  final int currentIndex;
  final String? videoPath;
  final String? analyticsSessionId;

  @override
  ConsumerState<_RepReviewContent> createState() => _RepReviewContentState();
}

class _RepReviewContentState extends ConsumerState<_RepReviewContent> {
  VideoPlayerController? _videoController;
  RepClipPlaybackController? _clipController;
  RepClipWindow? _window;
  bool _initializing = false;
  bool _videoUnavailable = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeVideo());
  }

  Future<void> _initializeVideo() async {
    final path = widget.videoPath;
    if (_initializing || path == null || !File(path).existsSync()) {
      if (mounted) setState(() => _videoUnavailable = true);
      return;
    }
    _initializing = true;
    final controller = VideoPlayerController.file(File(path));
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      final window = RepClipWindow.forRep(
        repStart: widget.analysis.startTime,
        repEnd: widget.analysis.endTime,
        videoDuration: controller.value.duration,
      );
      final playback = RepClipPlaybackController(
        player: _VideoPlayerAdapter(controller),
        window: window,
        onPlay: () {
          ref
              .read(analyticsServiceProvider)
              .repClipPlayed(
                workoutSessionId: widget.analyticsSessionId,
                repNumber: widget.analysis.repNumber,
                issueType: widget.analysis.primaryIssue?.name ?? 'none',
              );
        },
      );
      controller.addListener(_refreshPlaybackState);
      setState(() {
        _videoController = controller;
        _clipController = playback;
        _window = window;
      });
      await playback.play();
    } on Object {
      await controller.dispose();
      if (mounted) setState(() => _videoUnavailable = true);
    } finally {
      _initializing = false;
    }
  }

  void _refreshPlaybackState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _clipController?.dispose();
    _videoController?.removeListener(_refreshPlaybackState);
    unawaited(_videoController?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _videoController;
    final window = _window;
    return ListView(
      children: [
        Row(
          children: [
            MotionEyebrow(
              l10n.repTimelineTitle,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Spacer(),
            Text(
              '${l10n.repNumber(widget.analysis.repNumber)}  ·  '
              '${widget.currentIndex + 1}/${widget.analyses.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Stack(
          children: [
            AspectRatio(
              aspectRatio: controller?.value.aspectRatio == 0
                  ? 3 / 4
                  : controller?.value.aspectRatio ?? 3 / 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(context.tokens.radiusMd),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.tokens.radiusMd),
                  child: controller != null && controller.value.isInitialized
                      ? VideoPlayer(controller)
                      : Center(
                          child: _videoUnavailable
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.videocam_off_outlined,
                                      color: Colors.white70,
                                      size: 42,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.repVideoNotSaved,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                )
                              : const CircularProgressIndicator(),
                        ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 12,
              start: 12,
              child: CoachStatusPill(
                label: repResultLabel(l10n, widget.analysis),
                tone: _tone(widget.analysis.result),
                icon: switch (widget.analysis.result) {
                  RepAnalysisResult.needsImprovement =>
                    Icons.priority_high_rounded,
                  RepAnalysisResult.notAssessed => Icons.remove_rounded,
                  _ => Icons.check_rounded,
                },
              ),
            ),
          ],
        ),
        if (controller != null && window != null) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: _clipProgress(controller, window)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatRepTimestamp(window.start)),
              Text(formatRepTimestamp(window.end)),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () => unawaited(_clipController?.replay()),
              icon: const Icon(Icons.replay_rounded),
              label: Text(l10n.repReplay),
            ),
          ),
        ],
        const NativeAdSection(placement: NativeAdPlacement.repReview),
        const SizedBox(height: 24),
        MotionEyebrow(l10n.repWhatHappened),
        const SizedBox(height: 8),
        Text(
          widget.analysis.primaryIssue == null
              ? repResultLabel(l10n, widget.analysis)
              : repIssueLabel(l10n, widget.analysis.primaryIssue),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: coachToneColor(context, _tone(widget.analysis.result)),
          ),
        ),
        if (widget.analysis.needsImprovement) ...[
          const SizedBox(height: 24),
          MotionEyebrow(l10n.repHowToImprove),
          const SizedBox(height: 8),
          Text(
            repFeedback(l10n, widget.analysis),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
        if (_strengths(l10n, widget.analysis).isNotEmpty) ...[
          const SizedBox(height: 24),
          MotionEyebrow(l10n.repWhatWentWell),
          const SizedBox(height: 8),
          for (final strength in _strengths(l10n, widget.analysis))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 17,
                    color: context.tokens.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(strength)),
                ],
              ),
            ),
        ],
        const SizedBox(height: 26),
        const MotionRule(),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                key: const ValueKey('rep-review-previous'),
                onPressed: widget.currentIndex > 0
                    ? () => _open(widget.analyses[widget.currentIndex - 1])
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
                label: Text(l10n.repPrevious),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton.icon(
                key: const ValueKey('rep-review-next'),
                onPressed: widget.currentIndex < widget.analyses.length - 1
                    ? () => _open(widget.analyses[widget.currentIndex + 1])
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
                label: Text(l10n.repNext),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _open(RepAnalysis analysis) {
    context.pushReplacement(
      '/rep-timeline/${widget.sessionId}/rep/${analysis.repNumber}',
    );
  }

  CoachStatusTone _tone(RepAnalysisResult result) => switch (result) {
    RepAnalysisResult.good ||
    RepAnalysisResult.improved => CoachStatusTone.positive,
    RepAnalysisResult.needsImprovement => CoachStatusTone.attention,
    RepAnalysisResult.notAssessed => CoachStatusTone.unavailable,
  };

  List<String> _strengths(AppLocalizations l10n, RepAnalysis analysis) => [
    if (analysis.depthQuality == RepQuality.good) l10n.formIssueDepth,
    if (analysis.upperBodyQuality == RepQuality.good) l10n.formIssueTorsoLean,
    if (analysis.kneeAlignmentQuality == RepQuality.good)
      l10n.formIssueKneeAlignment,
  ];

  double _clipProgress(VideoPlayerController controller, RepClipWindow window) {
    if (window.duration <= Duration.zero) return 1;
    final elapsed = controller.value.position - window.start;
    return (elapsed.inMilliseconds / window.duration.inMilliseconds)
        .clamp(0, 1)
        .toDouble();
  }
}

class _VideoPlayerAdapter implements RepClipPlayer {
  const _VideoPlayerAdapter(this.controller);

  final VideoPlayerController controller;

  @override
  bool get isPlaying => controller.value.isPlaying;

  @override
  Duration get position => controller.value.position;

  @override
  void addListener(VoidCallback listener) => controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      controller.removeListener(listener);

  @override
  Future<void> pause() => controller.pause();

  @override
  Future<void> play() => controller.play();

  @override
  Future<void> seekTo(Duration position) => controller.seekTo(position);
}
