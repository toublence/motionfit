import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/widgets/coach_ui.dart';
import 'package:motionfit_squat/features/squat/domain/models/rep_analysis.dart';
import 'package:motionfit_squat/features/squat/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/squat/presentation/rep_review_formatters.dart';

bool hasPlayableWorkoutVideo(String? path) {
  if (path == null || path.isEmpty) return false;
  try {
    return File(path).existsSync();
  } on FileSystemException {
    return false;
  }
}

class RepTimelineSection extends StatefulWidget {
  const RepTimelineSection({
    required this.sessionId,
    required this.analyses,
    required this.videoPath,
    this.showVideoUnavailableMessage = false,
    this.onOpenRep,
    super.key,
  });

  final String sessionId;
  final List<RepAnalysis> analyses;
  final String? videoPath;
  final bool showVideoUnavailableMessage;
  final ValueChanged<RepAnalysis>? onOpenRep;

  @override
  State<RepTimelineSection> createState() => _RepTimelineSectionState();
}

class _RepTimelineSectionState extends State<RepTimelineSection> {
  bool _attentionOnly = false;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.analyses.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final hasVideo = hasPlayableWorkoutVideo(widget.videoPath);
    final attentionCount = widget.analyses
        .where(
          (analysis) => analysis.result == RepAnalysisResult.needsImprovement,
        )
        .length;
    final visible = _attentionOnly
        ? widget.analyses
              .where(
                (analysis) =>
                    analysis.result == RepAnalysisResult.needsImprovement,
              )
              .toList()
        : widget.analyses;
    final bySet = <int, List<RepAnalysis>>{};
    for (final analysis in visible) {
      bySet.putIfAbsent(analysis.setNumber, () => []).add(analysis);
    }
    final setNumbers = bySet.keys.toList()..sort();

    void open(RepAnalysis analysis) {
      final callback = widget.onOpenRep;
      if (callback != null) {
        callback(analysis);
        return;
      }
      context.push(
        '/rep-timeline/${widget.sessionId}/rep/${analysis.repNumber}',
      );
    }

    return Column(
      key: const ValueKey('rep-timeline-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: CoachSectionHeader(title: l10n.repTimelineTitle)),
            Text(
              l10n.unitReps(widget.analyses.length),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_expanded) ...[
          Text(
            '${l10n.unitReps(widget.analyses.length)} · '
            '${l10n.repTimelineImprove} $attentionCount',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _expanded = true;
              _attentionOnly = attentionCount > 0;
            }),
            icon: const Icon(Icons.expand_more_rounded),
            label: Text(
              attentionCount > 0
                  ? '${l10n.repTimelineImprove} $attentionCount'
                  : l10n.repTimelineAll,
            ),
          ),
        ] else ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                key: const ValueKey('rep-timeline-filter-all'),
                label: Text(l10n.repTimelineAll),
                selected: !_attentionOnly,
                onSelected: (_) => setState(() => _attentionOnly = false),
              ),
              ChoiceChip(
                key: const ValueKey('rep-timeline-filter-attention'),
                label: Text('${l10n.repTimelineImprove} $attentionCount'),
                selected: _attentionOnly,
                onSelected: (_) => setState(() => _attentionOnly = true),
              ),
            ],
          ),
          if (!hasVideo && widget.showVideoUnavailableMessage) ...[
            const SizedBox(height: 8),
            Text(
              l10n.repVideoNotSaved,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.tokens.unavailable,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l10n.repTimelineNoImprovement,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (var setIndex = 0; setIndex < setNumbers.length; setIndex++) ...[
            MotionEyebrow(l10n.repSetNumber(setNumbers[setIndex])),
            const SizedBox(height: 5),
            Column(
              children: [
                for (
                  var rowIndex = 0;
                  rowIndex < bySet[setNumbers[setIndex]]!.length;
                  rowIndex++
                ) ...[
                  _RepTimelineRow(
                    analysis: bySet[setNumbers[setIndex]]![rowIndex],
                    hasVideo: hasVideo,
                    onOpen: () => open(bySet[setNumbers[setIndex]]![rowIndex]),
                  ),
                  if (rowIndex < bySet[setNumbers[setIndex]]!.length - 1)
                    const Divider(height: 1, indent: 38),
                ],
              ],
            ),
            if (setIndex != setNumbers.length - 1)
              SizedBox(height: context.tokens.space12),
          ],
        ],
      ],
    );
  }
}

class _RepTimelineRow extends StatelessWidget {
  const _RepTimelineRow({
    required this.analysis,
    required this.hasVideo,
    required this.onOpen,
  });

  final RepAnalysis analysis;
  final bool hasVideo;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final warning = analysis.result == RepAnalysisResult.needsImprovement;
    final unavailable = analysis.result == RepAnalysisResult.notAssessed;
    final color = warning
        ? context.tokens.warning
        : unavailable
        ? context.tokens.unavailable
        : context.tokens.success;
    return Material(
      key: ValueKey('rep-timeline-row-${analysis.repNumber}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(context.tokens.radiusMd),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 8, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  child: Text(
                    analysis.repNumber.toString().padLeft(2, '0'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  warning
                      ? Icons.priority_high_rounded
                      : unavailable
                      ? Icons.remove_rounded
                      : Icons.check_rounded,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    repResultLabel(l10n, analysis),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  key: hasVideo
                      ? ValueKey('rep-timeline-play-${analysis.repNumber}')
                      : null,
                  tooltip: l10n.repNumber(analysis.repNumber),
                  visualDensity: VisualDensity.compact,
                  onPressed: onOpen,
                  icon: Icon(
                    hasVideo
                        ? Icons.play_arrow_rounded
                        : Icons.chevron_right_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
