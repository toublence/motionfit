import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/body_progress/application/body_progress_capture_controller.dart';
import 'package:motionfit_squat/features/body_progress/application/body_progress_providers.dart';
import 'package:motionfit_squat/features/body_progress/presentation/widgets/body_progress_image.dart';
import 'package:motionfit_squat/features/body_progress/presentation/widgets/body_progress_widgets.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

class BodyProgressCaptureScreen extends ConsumerStatefulWidget {
  const BodyProgressCaptureScreen({super.key});

  @override
  ConsumerState<BodyProgressCaptureScreen> createState() =>
      _BodyProgressCaptureScreenState();
}

class _BodyProgressCaptureScreenState
    extends ConsumerState<BodyProgressCaptureScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(analyticsServiceProvider).screenView('body_progress_capture');
      ref
          .read(bodyProgressCaptureControllerProvider.notifier)
          .open(ref.read(selectedBodyViewProvider));
    });
  }

  @override
  void dispose() {
    // The controller keeps the camera until it is told to release it, so the
    // stop request is issued before this route goes away.
    ref.read(bodyProgressCaptureControllerProvider.notifier).close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(bodyProgressCaptureControllerProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.bodyProgressCaptureTitle),
        actions: [
          if (state.isPreviewLive)
            IconButton(
              tooltip: l10n.bodyProgressSwitchCamera,
              onPressed: () => ref
                  .read(bodyProgressCaptureControllerProvider.notifier)
                  .switchCamera(),
              icon: const Icon(Icons.flip_camera_ios_rounded),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: _Viewfinder(state: state)),
            _Controls(state: state, onCapture: _capture),
          ],
        ),
      ),
    );
  }

  Future<void> _capture() async {
    final l10n = AppLocalizations.of(context);
    final preferences = ref.read(preferencesControllerProvider);
    if (preferences.hapticsEnabled) await HapticFeedback.mediumImpact();
    final saved = await ref
        .read(bodyProgressCaptureControllerProvider.notifier)
        .capture();
    if (!mounted) return;
    final state = ref.read(bodyProgressCaptureControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? l10n.bodyProgressSaved
              : _errorMessage(l10n, state.errorCode),
        ),
      ),
    );
  }
}

String _errorMessage(AppLocalizations l10n, String? code) => switch (code) {
  'camera_busy' => l10n.bodyProgressCameraBusy,
  'permission_denied' => l10n.bodyProgressPermissionBody,
  _ => l10n.bodyProgressCameraError,
};

class _Viewfinder extends ConsumerWidget {
  const _Viewfinder({required this.state});

  final BodyProgressCaptureState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (state.status == BodyProgressCaptureStatus.permissionDenied ||
        state.status == BodyProgressCaptureStatus.permissionPermanentlyDenied) {
      return _PermissionNotice(state: state);
    }
    if (state.status == BodyProgressCaptureStatus.failed) {
      return _FailureNotice(state: state);
    }
    if (!state.isPreviewLive) {
      return Center(
        child: Semantics(
          label: l10n.bodyProgressCaptureTitle,
          child: const CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          Transform.flip(
            flipX: state.mirrorInFlutter,
            child: _UprightPreview(
              textureId: state.textureId!,
              rotationDegrees: state.rotationDegrees,
              handlesCropAndRotation: state.handlesCropAndRotation,
              sourceWidth: state.previewWidth,
              sourceHeight: state.previewHeight,
            ),
          ),
          if (state.ghostPhoto != null && state.ghostOpacity > 0)
            IgnorePointer(
              child: BodyProgressImage(
                photo: state.ghostPhoto!,
                opacity: state.ghostOpacity,
              ),
            ),
          if (state.guidesVisible) const IgnorePointer(child: _FramingGuides()),
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: _Hint(hasGhost: state.ghostPhoto != null),
          ),
        ],
      ),
    );
  }
}

/// Draws the camera texture the right way up.
///
/// Flutter's Android `SurfaceProducer` does not always apply CameraX rotation
/// metadata, so the texture is turned here instead. This matches what the
/// workout preview already does; keeping the two in step avoids a repeat of the
/// sideways preview.
class _UprightPreview extends StatelessWidget {
  const _UprightPreview({
    required this.textureId,
    required this.rotationDegrees,
    required this.handlesCropAndRotation,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  final int textureId;
  final int rotationDegrees;
  final bool handlesCropAndRotation;
  final int sourceWidth;
  final int sourceHeight;

  @override
  Widget build(BuildContext context) {
    final normalizedRotation = ((rotationDegrees % 360) + 360) % 360;
    final quarterTurns = normalizedRotation ~/ 90;
    final hasSourceSize = sourceWidth > 0 && sourceHeight > 0;
    // A quarter turn swaps the buffer's width and height.
    final rawWidth = !handlesCropAndRotation && quarterTurns.isOdd
        ? sourceHeight
        : sourceWidth;
    final rawHeight = !handlesCropAndRotation && quarterTurns.isOdd
        ? sourceWidth
        : sourceHeight;
    Widget preview = hasSourceSize
        ? SizedBox(
            width: rawWidth.toDouble(),
            height: rawHeight.toDouble(),
            child: Texture(textureId: textureId),
          )
        : Texture(textureId: textureId);
    if (!handlesCropAndRotation) {
      preview = RotatedBox(quarterTurns: quarterTurns, child: preview);
    }
    if (!hasSourceSize) return ClipRect(child: preview);
    return ClipRect(child: FittedBox(fit: BoxFit.cover, child: preview));
  }
}

/// Centre line and a body box so each photo is framed the same way.
class _FramingGuides extends StatelessWidget {
  const _FramingGuides();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GuidePainter(), size: Size.infinite);
}

class _GuidePainter extends CustomPainter {
  static const _lineColor = Color(0x66FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final centerX = size.width / 2;
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);
    // Horizon marks for shoulder and hip height so the subject can keep the
    // same standing distance from the camera between sessions.
    for (final fraction in const [0.3, 0.55]) {
      final y = size.height * fraction;
      canvas.drawLine(
        Offset(size.width * 0.12, y),
        Offset(size.width * 0.28, y),
        paint,
      );
      canvas.drawLine(
        Offset(size.width * 0.72, y),
        Offset(size.width * 0.88, y),
        paint,
      );
    }
    final body = Rect.fromLTWH(
      size.width * 0.16,
      size.height * 0.06,
      size.width * 0.68,
      size.height * 0.88,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(20)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GuidePainter oldDelegate) => false;
}

class _Hint extends StatelessWidget {
  const _Hint({required this.hasGhost});

  final bool hasGhost;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      color: context.tokens.cameraOverlay,
      padding: EdgeInsets.symmetric(
        horizontal: context.tokens.spaceMd,
        vertical: context.tokens.space12,
      ),
      child: Text(
        hasGhost
            ? l10n.bodyProgressCaptureHintGhost
            : l10n.bodyProgressCaptureHintFirst,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _PermissionNotice extends ConsumerWidget {
  const _PermissionNotice({required this.state});

  final BodyProgressCaptureState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final permanent =
        state.status == BodyProgressCaptureStatus.permissionPermanentlyDenied;
    return _CenteredNotice(
      icon: Icons.no_photography_rounded,
      title: l10n.bodyProgressPermissionTitle,
      body: l10n.bodyProgressPermissionBody,
      actionLabel: permanent
          ? l10n.permissionOpenSettings
          : l10n.permissionCameraRequest,
      onAction: () {
        final notifier = ref.read(
          bodyProgressCaptureControllerProvider.notifier,
        );
        if (permanent) {
          notifier.openSystemSettings();
        } else {
          notifier.retry();
        }
      },
    );
  }
}

class _FailureNotice extends ConsumerWidget {
  const _FailureNotice({required this.state});

  final BodyProgressCaptureState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return _CenteredNotice(
      icon: Icons.videocam_off_rounded,
      title: l10n.errorGenericTitle,
      body: _errorMessage(l10n, state.errorCode),
      actionLabel: l10n.commonRetry,
      onAction: () =>
          ref.read(bodyProgressCaptureControllerProvider.notifier).retry(),
    );
  }
}

class _CenteredNotice extends StatelessWidget {
  const _CenteredNotice({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(context.tokens.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.white70),
          SizedBox(height: context.tokens.space12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          SizedBox(height: context.tokens.spaceSm),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          SizedBox(height: context.tokens.spaceLg),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    ),
  );
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.state, required this.onCapture});

  final BodyProgressCaptureState state;
  final Future<void> Function() onCapture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(bodyProgressCaptureControllerProvider.notifier);
    return Container(
      color: Colors.black,
      padding: EdgeInsets.fromLTRB(
        context.tokens.spaceMd,
        context.tokens.space12,
        context.tokens.spaceMd,
        context.tokens.spaceMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(brightness: Brightness.dark),
            ),
            child: BodyViewSelector(
              selected: state.bodyView,
              onSelected: notifier.selectBodyView,
            ),
          ),
          if (state.ghostPhoto != null) ...[
            SizedBox(height: context.tokens.spaceSm),
            Row(
              children: [
                const Icon(
                  Icons.opacity_rounded,
                  size: 18,
                  color: Colors.white70,
                ),
                Expanded(
                  child: Slider(
                    value: state.ghostOpacity,
                    max: 0.9,
                    label: l10n.bodyProgressGhostOverlay,
                    onChanged: notifier.setGhostOpacity,
                  ),
                ),
                IconButton(
                  tooltip: l10n.bodyProgressGuides,
                  onPressed: notifier.toggleGuides,
                  icon: Icon(
                    state.guidesVisible
                        ? Icons.grid_on_rounded
                        : Icons.grid_off_rounded,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: context.tokens.spaceSm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.canCapture ? onCapture : null,
              icon: const Icon(Icons.camera_rounded),
              label: Text(l10n.bodyProgressShutter),
            ),
          ),
        ],
      ),
    );
  }
}
