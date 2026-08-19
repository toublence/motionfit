import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/app/theme/motionfit_color_theme.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';
import 'package:motionfit_squat/core/widgets/responsive_page.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/core/reviews/review_prompt_provider.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';
import 'package:motionfit_squat/features/settings/application/reminder_controller.dart';
import 'package:motionfit_squat/features/settings/domain/user_preferences.dart';
import 'package:motionfit_squat/features/settings/domain/reminder_schedule.dart';
import 'package:motionfit_squat/features/settings/domain/theme_preferences.dart';
import 'package:motionfit_squat/features/settings/presentation/reminder_screen.dart';
import 'package:motionfit_squat/features/squat/domain/services/coach_engine.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _systemLocaleValue = 'system';
  static final _privacyPolicyUri = Uri.parse(
    'https://motionfit.fit/privacy-policy',
  );

  SystemTtsCoachEngine? _voiceEngine;
  double? _draftRate;
  bool _isTestingVoice = false;
  bool _openingStoreReview = false;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).screenView('settings');
  }

  @override
  void dispose() {
    final engine = _voiceEngine;
    if (engine != null) unawaited(engine.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final preferences = ref.watch(preferencesControllerProvider);
    final controller = ref.read(preferencesControllerProvider.notifier);
    final reminders = ref.watch(reminderControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsTitle)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsivePage(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SettingsGroup(
                  title: localizations.settingsSectionGeneral,
                  children: [
                    ListTile(
                      minTileHeight: 72,
                      leading: const Icon(Icons.language_rounded),
                      title: Text(localizations.settingsLanguage),
                      subtitle: Text(
                        _languageName(localizations, preferences.locale),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showLanguagePicker(preferences),
                    ),
                    ListTile(
                      minTileHeight: 72,
                      leading: const Icon(Icons.contrast_rounded),
                      title: Text(localizations.settingsDisplayTheme),
                      subtitle: Text(
                        _displayThemeLabel(
                          localizations,
                          preferences.displayTheme,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showDisplayThemePicker(preferences),
                    ),
                    ListTile(
                      minTileHeight: 72,
                      leading: const Icon(Icons.palette_outlined),
                      title: Text(localizations.settingsColorTheme),
                      subtitle: Text(
                        _colorThemeLabel(localizations, preferences.colorTheme),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showColorThemePicker(preferences),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SettingsGroup(
                  title: localizations.settingsSectionCoaching,
                  children: [
                    ListTile(
                      minTileHeight: 72,
                      leading: const Icon(Icons.record_voice_over_outlined),
                      title: Text(localizations.voiceCoachingEnabled),
                      subtitle: Text(
                        preferences.voiceCoachingEnabled
                            ? localizations.commonOn
                            : localizations.commonOff,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _showVoiceSettings,
                    ),
                    ListTile(
                      minTileHeight: 72,
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: Text(localizations.reminderTitle),
                      subtitle: Text(
                        _reminderSummary(localizations, reminders),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _openReminders,
                    ),
                    RepVideoReviewSettingsTile(
                      value: preferences.repVideoReviewEnabled,
                      onChanged: (value) => unawaited(
                        _updatePreference(
                          () => controller.setRepVideoReview(value),
                        ),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      minTileHeight: 72,
                      secondary: const Icon(Icons.vibration_outlined),
                      title: Text(localizations.settingsHaptics),
                      value: preferences.hapticsEnabled,
                      onChanged: (value) => unawaited(
                        _updatePreference(() => controller.setHaptics(value)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SettingsGroup(
                  title: localizations.settingsSectionAbout,
                  children: [
                    ListTile(
                      minTileHeight: 68,
                      leading: const Icon(Icons.star_rate_rounded),
                      title: Text(localizations.settingsRateApp),
                      subtitle: Text(localizations.settingsRateAppSubtitle),
                      trailing: const Icon(Icons.open_in_new_rounded),
                      enabled: !_openingStoreReview,
                      onTap: _openingStoreReview ? null : _openStoreReview,
                    ),
                    ListTile(
                      minTileHeight: 72,
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: Text(localizations.appInfoPrivacyPolicy),
                      subtitle: const Text('motionfit.fit/privacy-policy'),
                      trailing: const Icon(Icons.open_in_new_rounded),
                      onTap: _openPrivacyPolicy,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _reminderSummary(
    AppLocalizations l10n,
    AsyncValue<List<ReminderSchedule>> value,
  ) => switch (value) {
    AsyncData(:final value) => () {
      final enabled = value.where((item) => item.enabled).toList();
      if (enabled.isEmpty) return l10n.reminderNoneScheduled;
      final days = enabled
          .map((item) => _weekdayShort(l10n, item.weekday))
          .join(' · ');
      final time = TimeOfDay(
        hour: enabled.first.hour,
        minute: enabled.first.minute,
      ).format(context);
      return '$days  $time';
    }(),
    _ => l10n.commonLoading,
  };

  String _weekdayShort(AppLocalizations l10n, int day) => switch (day) {
    DateTime.monday => l10n.weekdayMondayShort,
    DateTime.tuesday => l10n.weekdayTuesdayShort,
    DateTime.wednesday => l10n.weekdayWednesdayShort,
    DateTime.thursday => l10n.weekdayThursdayShort,
    DateTime.friday => l10n.weekdayFridayShort,
    DateTime.saturday => l10n.weekdaySaturdayShort,
    _ => l10n.weekdaySundayShort,
  };

  Future<void> _showDisplayThemePicker(UserPreferences preferences) async {
    final selected = await showModalBottomSheet<MotionFitDisplayTheme>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: RadioGroup<MotionFitDisplayTheme>(
            groupValue: preferences.displayTheme,
            onChanged: (value) {
              if (value != null) Navigator.pop(sheetContext, value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final theme in MotionFitDisplayTheme.values)
                  RadioListTile<MotionFitDisplayTheme>.adaptive(
                    value: theme,
                    title: Text(_displayThemeLabel(l10n, theme)),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    await _updatePreference(
      () => ref
          .read(preferencesControllerProvider.notifier)
          .setDisplayTheme(selected),
    );
  }

  Future<void> _showColorThemePicker(UserPreferences preferences) async {
    final selected = await showModalBottomSheet<MotionFitColorTheme>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.settingsColorTheme,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final theme in MotionFitColorTheme.values)
                      _ColorThemeTile(
                        theme: theme,
                        label: _colorThemeLabel(l10n, theme),
                        selected: theme == preferences.colorTheme,
                        onTap: () => Navigator.pop(sheetContext, theme),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    await _updatePreference(
      () => ref
          .read(preferencesControllerProvider.notifier)
          .setColorTheme(selected),
    );
  }

  void _showVoiceSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Consumer(
          builder: (context, sheetRef, _) {
            final l10n = AppLocalizations.of(context);
            final preferences = sheetRef.watch(preferencesControllerProvider);
            final controller = sheetRef.read(
              preferencesControllerProvider.notifier,
            );
            final enabled = preferences.voiceCoachingEnabled;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.settingsSectionCoaching,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            title: Text(l10n.voiceCoachingEnabled),
                            value: enabled,
                            onChanged: (value) =>
                                unawaited(controller.setVoiceCoaching(value)),
                          ),
                          const Divider(height: 1),
                          SwitchListTile.adaptive(
                            title: Text(l10n.voiceRepCountEnabled),
                            value: preferences.repCountVoiceEnabled,
                            onChanged: enabled
                                ? (value) => unawaited(
                                    controller.setRepCountVoice(value),
                                  )
                                : null,
                          ),
                          SwitchListTile.adaptive(
                            title: Text(l10n.voiceFormEnabled),
                            value: preferences.formVoiceEnabled,
                            onChanged: enabled
                                ? (value) =>
                                      unawaited(controller.setFormVoice(value))
                                : null,
                          ),
                          SwitchListTile.adaptive(
                            title: Text(l10n.voiceEncouragementEnabled),
                            value: preferences.encouragementVoiceEnabled,
                            onChanged: enabled
                                ? (value) => unawaited(
                                    controller.setEncouragementVoice(value),
                                  )
                                : null,
                          ),
                          _SpeechRateTile(
                            title: l10n.voiceRate,
                            rateLabel: _rateLabel(
                              l10n,
                              _draftRate ?? preferences.ttsRate,
                            ),
                            slowLabel: l10n.voiceRateSlow,
                            normalLabel: l10n.voiceRateNormal,
                            fastLabel: l10n.voiceRateFast,
                            value: _draftRate ?? preferences.ttsRate,
                            enabled: enabled,
                            onChanged: (value) =>
                                setSheetState(() => _draftRate = value),
                            onChangeEnd: (value) {
                              setSheetState(() => _draftRate = null);
                              unawaited(controller.setTtsRate(value));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isTestingVoice
                          ? null
                          : () async {
                              setSheetState(() => _isTestingVoice = true);
                              await _testVoice(preferences);
                              if (sheetContext.mounted) {
                                setSheetState(() => _isTestingVoice = false);
                              }
                            },
                      icon: const Icon(Icons.volume_up_outlined),
                      label: Text(l10n.voiceTest),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker(UserPreferences preferences) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final localizations = AppLocalizations.of(sheetContext);
        final localeValues = <String>[
          _systemLocaleValue,
          ...UserPreferences.supportedLocales,
        ];
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
            ),
            child: RadioGroup<String>(
              groupValue: preferences.locale ?? _systemLocaleValue,
              onChanged: (value) {
                if (value != null) Navigator.of(sheetContext).pop(value);
              },
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: localeValues.length,
                itemBuilder: (context, index) {
                  final value = localeValues[index];
                  return RadioListTile<String>.adaptive(
                    value: value,
                    title: Text(
                      _languageName(
                        localizations,
                        value == _systemLocaleValue ? null : value,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    final message = AppLocalizations.of(context).languageChanged;
    await _updatePreference(
      () => ref
          .read(preferencesControllerProvider.notifier)
          .setLocale(selected == _systemLocaleValue ? null : selected),
      successMessage: message,
    );
  }

  Future<void> _updatePreference(
    Future<void> Function() update, {
    String? successMessage,
  }) async {
    try {
      await update();
      if (mounted && successMessage != null) _showMessage(successMessage);
    } on Object {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).errorGenericBody);
    }
  }

  Future<void> _testVoice(UserPreferences preferences) async {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    setState(() => _isTestingVoice = true);
    try {
      final engine = _voiceEngine ??= SystemTtsCoachEngine();
      await engine.stop();
      final available = await engine.configure(
        locale: locale,
        rate: preferences.ttsRate,
      );
      if (!available) {
        if (mounted) _showMessage(localizations.voiceUnavailable);
        return;
      }
      await engine.speak(localizations.voiceTestPhrase);
    } on Object {
      if (mounted) _showMessage(localizations.errorTtsVoiceMissing);
    } finally {
      if (mounted) setState(() => _isTestingVoice = false);
    }
  }

  void _openReminders() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ReminderScreen()));
  }

  Future<void> _openPrivacyPolicy() async {
    if (await launchUrl(
      _privacyPolicyUri,
      mode: LaunchMode.externalApplication,
    )) {
      return;
    }
    if (mounted) {
      _showMessage(AppLocalizations.of(context).errorGenericBody);
    }
  }

  Future<void> _openStoreReview() async {
    if (_openingStoreReview) return;
    setState(() => _openingStoreReview = true);
    final opened = await ref
        .read(reviewPromptServiceProvider)
        .openStoreReviewPage();
    if (!mounted) return;
    setState(() => _openingStoreReview = false);
    if (!opened) {
      _showMessage(AppLocalizations.of(context).settingsRateAppError);
    }
  }

  String _languageName(AppLocalizations localizations, String? locale) =>
      switch (locale) {
        null => localizations.languageSystem,
        'en' => localizations.languageEnglish,
        'ko' => localizations.languageKorean,
        'de' => localizations.languageGerman,
        'es' => localizations.languageSpanish,
        'fr' => localizations.languageFrench,
        'ja' => localizations.languageJapanese,
        'ar' => localizations.languageArabic,
        'zh' => localizations.languageChineseSimplified,
        'zh_Hant' => localizations.languageChineseTraditional,
        _ => localizations.languageSystem,
      };

  String _rateLabel(AppLocalizations localizations, double rate) {
    if (rate < 0.4) return localizations.voiceRateSlow;
    if (rate > 0.6) return localizations.voiceRateFast;
    return localizations.voiceRateNormal;
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              const Divider(height: 1, indent: 56),
          ],
        ],
      ),
    ],
  );
}

class RepVideoReviewSettingsTile extends StatelessWidget {
  const RepVideoReviewSettingsTile({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SwitchListTile.adaptive(
      key: const ValueKey('settings-rep-video-review-toggle'),
      minTileHeight: 84,
      secondary: const Icon(Icons.video_camera_back_outlined),
      title: Text(l10n.repVideoReviewTitle),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.repVideoReviewDescription),
          const SizedBox(height: 3),
          Text(
            l10n.repVideoLocalOnly,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SpeechRateTile extends StatelessWidget {
  const _SpeechRateTile({
    required this.title,
    required this.rateLabel,
    required this.slowLabel,
    required this.normalLabel,
    required this.fastLabel,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String title;
  final String rateLabel;
  final String slowLabel;
  final String normalLabel;
  final String fastLabel;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        context.tokens.spaceMd,
        context.tokens.spaceMd,
        context.tokens.spaceMd,
        context.tokens.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: context.tokens.spaceXs),
          Text(rateLabel),
          Slider(
            value: value,
            min: 0.2,
            max: 0.8,
            divisions: 6,
            label: rateLabel,
            semanticFormatterCallback: (_) => rateLabel,
            onChanged: enabled ? onChanged : null,
            onChangeEnd: enabled ? onChangeEnd : null,
          ),
          Row(
            children: [
              Expanded(child: Text(slowLabel, style: labelStyle)),
              Expanded(
                child: Text(
                  normalLabel,
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ),
              Expanded(
                child: Text(
                  fastLabel,
                  textAlign: TextAlign.end,
                  style: labelStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _displayThemeLabel(AppLocalizations l10n, MotionFitDisplayTheme theme) =>
    switch (theme) {
      MotionFitDisplayTheme.light => l10n.themeLight,
      MotionFitDisplayTheme.dark => l10n.themePureBlack,
      MotionFitDisplayTheme.system => l10n.themeSystem,
    };

String _colorThemeLabel(AppLocalizations l10n, MotionFitColorTheme theme) =>
    switch (theme) {
      MotionFitColorTheme.byeokcheong => l10n.colorThemeByeokcheong,
      MotionFitColorTheme.chuhyang => l10n.colorThemeChuhyang,
      MotionFitColorTheme.jangdan => l10n.colorThemeJangdan,
      MotionFitColorTheme.cheonghyeon => l10n.colorThemeCheonghyeon,
      MotionFitColorTheme.haenghwang => l10n.colorThemeHaenghwang,
      MotionFitColorTheme.chunyu => l10n.colorThemeChunyu,
      MotionFitColorTheme.seolbaek => l10n.colorThemeSeolbaek,
      MotionFitColorTheme.byeokja => l10n.colorThemeByeokja,
      MotionFitColorTheme.chwiram => l10n.colorThemeChwiram,
    };

class _ColorThemeTile extends StatelessWidget {
  const _ColorThemeTile({
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final MotionFitColorTheme theme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final displayColor = theme.palette.displayColor;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: displayColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colors.onSurface : colors.outlineVariant,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        color: displayColor.computeLuminance() > .55
                            ? Colors.black
                            : Colors.white,
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
