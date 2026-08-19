import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/permissions/permission_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/squat/application/workout_preparation.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

class CameraPermissionScreen extends ConsumerStatefulWidget {
  const CameraPermissionScreen({required this.preparation, super.key});

  final WorkoutPreparation preparation;

  @override
  ConsumerState<CameraPermissionScreen> createState() =>
      _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends ConsumerState<CameraPermissionScreen>
    with WidgetsBindingObserver {
  late final DateTime _startedAt;
  AppPermissionState? _permissionState;
  bool _requesting = false;
  bool _checkingPermission = false;
  bool _navigating = false;
  bool _allowPop = false;
  AppPermissionState? _loggedPermissionState;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    ref.read(analyticsServiceProvider).screenView('camera_permission_guide');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_refreshPermissionStatus(showDenied: false));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _leavePermissionFlow() {
    if (_navigating || !mounted) return;
    _navigating = true;
    final state = _permissionState;
    ref
        .read(analyticsServiceProvider)
        .workoutCancelled(
          cancelStage: 'before_permission',
          cancelReason:
              state == AppPermissionState.denied ||
                  state == AppPermissionState.permanentlyDenied ||
                  state == AppPermissionState.restricted
              ? 'camera_permission_denied'
              : 'user_exit',
          elapsed: DateTime.now().difference(_startedAt),
          detectedReps: 0,
          trackingLoss: Duration.zero,
        );
    ref.read(workoutLaunchContextProvider.notifier).clear();
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted && state == AppLifecycleState.resumed) {
      unawaited(_refreshPermissionStatus());
    }
  }

  Future<void> _request() async {
    if (_requesting || _navigating || !mounted) return;
    setState(() => _requesting = true);
    try {
      final service = ref.read(permissionServiceProvider);
      final current = await service.cameraStatus();
      if (!mounted || _navigating) return;
      final requested = current != AppPermissionState.granted;
      final result = current == AppPermissionState.granted
          ? current
          : await (() async {
              ref.read(analyticsServiceProvider).cameraPermissionRequested();
              return service.requestCamera();
            })();
      if (!mounted || _navigating) return;
      _recordPermissionResult(result, requested: requested);
      setState(() => _permissionState = result);
      _continueIfGranted(result);
    } on Object {
      if (mounted && !_navigating) {
        ref
            .read(analyticsServiceProvider)
            .cameraPermissionResult(result: 'unknown', requested: true);
        setState(() => _permissionState = AppPermissionState.denied);
      }
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _refreshPermissionStatus({bool showDenied = true}) async {
    if (!mounted || _requesting || _checkingPermission || _navigating) return;
    _checkingPermission = true;
    try {
      final result = await ref.read(permissionServiceProvider).cameraStatus();
      if (!mounted || _navigating) return;
      if (showDenied || result != AppPermissionState.denied) {
        setState(() => _permissionState = result);
      }
      if (result != AppPermissionState.denied || showDenied) {
        _recordPermissionResult(result, requested: false);
      }
      _continueIfGranted(result);
    } on Object {
      // Keep the current state and let the explicit request surface failures.
    } finally {
      _checkingPermission = false;
    }
  }

  void _recordPermissionResult(
    AppPermissionState result, {
    required bool requested,
  }) {
    if (!mounted || _loggedPermissionState == result) return;
    _loggedPermissionState = result;
    ref
        .read(analyticsServiceProvider)
        .cameraPermissionResult(result: result.name, requested: requested);
  }

  void _continueIfGranted(AppPermissionState result) {
    if (result != AppPermissionState.granted || _navigating || !mounted) return;
    _navigating = true;
    final guideSeen = ref.read(preferencesControllerProvider).cameraSetupSeen;
    final persistGuideSeen = guideSeen
        ? null
        : ref
              .read(preferencesControllerProvider.notifier)
              .markCameraSetupSeen();
    unawaited(_finishGrantedNavigation(persistGuideSeen));
  }

  Future<void> _finishGrantedNavigation(Future<void>? persistGuideSeen) async {
    if (persistGuideSeen != null) {
      try {
        await persistGuideSeen;
      } on Object {
        // A persistence failure must not block camera startup.
      }
    }
    if (!mounted) return;
    context.pushReplacement('/prepare/countdown', extra: widget.preparation);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final permanentlyDenied =
        _permissionState == AppPermissionState.permanentlyDenied ||
        _permissionState == AppPermissionState.restricted;
    final screen = Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: context.tokens.spaceXl),
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          SizedBox(height: context.tokens.spaceLg),
                          Text(
                            l10n.permissionCameraTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(height: context.tokens.spaceMd),
                          Text(
                            l10n.permissionCameraBody,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: context.tokens.spaceMd),
                          _CameraRequirement(
                            icon: Icons.accessibility_new_rounded,
                            label: l10n.guideWholeBody,
                          ),
                          const SizedBox(height: 8),
                          _CameraRequirement(
                            icon: Icons.phone_android_rounded,
                            label: l10n.guideStableCamera,
                          ),
                          const SizedBox(height: 8),
                          _CameraRequirement(
                            icon: Icons.shield_outlined,
                            label: l10n.guidePrivacy,
                          ),
                          if (_permissionState ==
                              AppPermissionState.denied) ...[
                            SizedBox(height: context.tokens.spaceMd),
                            Text(
                              l10n.permissionCameraDenied,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          if (permanentlyDenied) ...[
                            SizedBox(height: context.tokens.spaceMd),
                            Text(
                              l10n.permissionCameraPermanentlyDenied,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: context.tokens.spaceXl),
                      child: SizedBox(
                        width: double.infinity,
                        child: permanentlyDenied
                            ? FilledButton.icon(
                                onPressed: () => ref
                                    .read(permissionServiceProvider)
                                    .openSettings(),
                                icon: const Icon(Icons.settings_outlined),
                                label: Text(l10n.permissionOpenSettings),
                              )
                            : FilledButton.icon(
                                onPressed: _requesting ? null : _request,
                                icon: _requesting
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt_outlined),
                                label: Text(l10n.permissionCameraRequest),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leavePermissionFlow();
      },
      child: screen,
    );
  }
}

class _CameraRequirement extends StatelessWidget {
  const _CameraRequirement({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text(label)),
    ],
  );
}
