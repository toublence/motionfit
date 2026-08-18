import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/features/pushup/localization/generated/pushup_localizations.dart';
import 'package:motionfit_squat/features/pushup/providers.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/features/pushup/records/application/records_providers.dart';
import 'package:motionfit_squat/features/pushup/records/presentation/widgets/record_components.dart';
import 'package:motionfit_squat/features/pushup/presentation/widgets/rep_timeline_section.dart';

class RepTimelineScreen extends ConsumerStatefulWidget {
  const RepTimelineScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<RepTimelineScreen> createState() => _RepTimelineScreenState();
}

class _RepTimelineScreenState extends ConsumerState<RepTimelineScreen> {
  bool _analyticsLogged = false;

  @override
  Widget build(BuildContext context) {
    final l10n = PushupLocalizations.of(context);
    final details = ref.watch(sessionDetailsProvider(widget.sessionId));
    final loadedDetails = switch (details) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (!_analyticsLogged && loadedDetails != null) {
      _analyticsLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(analyticsServiceProvider)
            .repTimelineViewed(
              workoutSessionId: loadedDetails.session.analyticsSessionId,
            );
      });
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.repTimelineTitle)),
      body: SafeArea(
        top: false,
        child: ResponsivePage(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 16),
          child: switch (details) {
            AsyncData(value: final value?) =>
              value.repAnalyses.isEmpty
                  ? Center(child: Text(l10n.completeNoFormData))
                  : ListView(
                      children: [
                        RepTimelineSection(
                          sessionId: value.session.id,
                          analyses: value.repAnalyses,
                          videoPath: value.session.videoPath,
                          showVideoUnavailableMessage: true,
                        ),
                      ],
                    ),
            AsyncData() || AsyncError() => RecordErrorState(
              title: l10n.errorGenericTitle,
              body: l10n.recordsLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () =>
                  ref.invalidate(sessionDetailsProvider(widget.sessionId)),
            ),
            _ => RecordLoadingState(label: l10n.recordsLoading),
          },
        ),
      ),
    );
  }
}
