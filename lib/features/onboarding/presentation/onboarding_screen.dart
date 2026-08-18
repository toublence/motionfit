import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motionfit_squat/app/localization/generated/app_localizations.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/providers.dart';
import 'package:motionfit_squat/features/settings/application/preferences_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _totalSteps = 3;
  final _controller = PageController();
  late final DateTime _startedAt;
  int _index = 0;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_startOnboardingSession());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final copy = _copyFor(
      locale.languageCode == 'zh' && locale.scriptCode == 'Hant'
          ? 'zh_Hant'
          : locale.languageCode,
    );
    final pages = [
      (Icons.sports_gymnastics_rounded, copy.countTitle, copy.countBody),
      (Icons.accessibility_new_rounded, copy.setupTitle, copy.setupBody),
      (Icons.insights_rounded, copy.controlTitle, copy.controlBody),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.appName, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return _OnboardingPage(
                      icon: page.$1,
                      showAppIcon: index == 0,
                      title: page.$2,
                      body: page.$3,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: index == _index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == _index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _finishing ? null : _continue,
                child: _finishing
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _index == pages.length - 1
                            ? copy.finish
                            : l10n.commonContinue,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startOnboardingSession() async {
    final preferences = ref.read(preferencesControllerProvider);
    final analytics = ref.read(analyticsServiceProvider);
    analytics.screenView('onboarding');
    final previousStartedAt = preferences.onboardingStartedAt;
    if (!preferences.onboardingCompleted && previousStartedAt != null) {
      analytics.onboardingAbandoned(
        stepIndex: preferences.onboardingLastStep,
        totalSteps: _totalSteps,
        elapsed: _startedAt.difference(previousStartedAt),
        exitReason: 'app_closed',
      );
    }
    analytics
      ..onboardingStarted(totalSteps: _totalSteps)
      ..onboardingStepViewed(
        stepIndex: 0,
        stepName: AnalyticsService.onboardingStepName(0),
        totalSteps: _totalSteps,
        elapsed: Duration.zero,
      );
    try {
      await ref
          .read(preferencesControllerProvider.notifier)
          .markOnboardingStarted(_startedAt);
    } on Object {
      // Analytics persistence must never block onboarding.
    }
  }

  void _onPageChanged(int value) {
    setState(() => _index = value);
    final analytics = ref.read(analyticsServiceProvider);
    analytics.onboardingStepViewed(
      stepIndex: value,
      stepName: AnalyticsService.onboardingStepName(value),
      totalSteps: _totalSteps,
      elapsed: DateTime.now().difference(_startedAt),
    );
    unawaited(
      ref
          .read(preferencesControllerProvider.notifier)
          .markOnboardingStep(value)
          .catchError((Object _) {}),
    );
  }

  Future<void> _continue() async {
    ref
        .read(analyticsServiceProvider)
        .onboardingNextTapped(
          stepIndex: _index,
          stepName: AnalyticsService.onboardingStepName(_index),
          totalSteps: _totalSteps,
          elapsed: DateTime.now().difference(_startedAt),
        );
    if (_index < 2) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    setState(() => _finishing = true);
    try {
      await ref
          .read(preferencesControllerProvider.notifier)
          .completeOnboarding();
      if (!mounted) return;
      ref
          .read(analyticsServiceProvider)
          .onboardingComplete(
            totalSteps: _totalSteps,
            elapsed: DateTime.now().difference(_startedAt),
          );
      await ref
          .read(privacyConsentServiceProvider)
          .requestTrackingAuthorization();
      if (mounted) {
        context.go('/squat');
      }
    } on Object {
      if (!mounted) return;
      setState(() => _finishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorGenericBody)),
      );
    }
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.showAppIcon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final bool showAppIcon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight > 24
              ? constraints.maxHeight - 24
              : 0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: showAppIcon
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'assets/branding/motionfit_app_icon.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          icon,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
                const SizedBox(height: 32),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

typedef _OnboardingCopy = ({
  String countTitle,
  String countBody,
  String setupTitle,
  String setupBody,
  String controlTitle,
  String controlBody,
  String finish,
});

_OnboardingCopy _copyFor(String language) => switch (language) {
  'ko' => (
    countTitle: '카메라가 횟수를 자동으로 세요',
    countBody: '휴대폰을 세워 두고 스쿼트하면 횟수가 자동으로 기록돼요.',
    setupTitle: '자세가 흐트러지면 바로 코칭해요',
    setupBody: '동작을 기기 안에서 분석해 필요한 자세 안내를 실시간으로 알려드려요.',
    controlTitle: '기록과 챌린지로 꾸준히 이어가요',
    controlBody: '운동 기록을 확인하고 나에게 맞는 챌린지로 다음 운동을 이어갈 수 있어요.',
    finish: '시작하기',
  ),
  'de' => (
    countTitle: 'Die Kamera zählt automatisch',
    countBody:
        'Stelle dein Smartphone auf und deine Kniebeugen werden automatisch erfasst.',
    setupTitle: 'Direktes Feedback zu deiner Haltung',
    setupBody:
        'Die Bewegung wird auf dem Gerät analysiert und du erhältst Hinweise in Echtzeit.',
    controlTitle: 'Mit Verlauf und Challenges dranbleiben',
    controlBody:
        'Sieh dir deine Trainings an und starte eine passende Challenge für dein nächstes Ziel.',
    finish: 'Loslegen',
  ),
  'es' => (
    countTitle: 'La cámara cuenta automáticamente',
    countBody:
        'Coloca el teléfono y tus sentadillas se registrarán de forma automática.',
    setupTitle: 'Consejos de postura en tiempo real',
    setupBody:
        'El movimiento se analiza en el dispositivo para darte indicaciones al instante.',
    controlTitle: 'Continúa con registros y retos',
    controlBody:
        'Consulta tus entrenamientos y elige un reto para mantener la constancia.',
    finish: 'Comenzar',
  ),
  'fr' => (
    countTitle: 'La caméra compte automatiquement',
    countBody:
        'Posez votre téléphone et vos squats sont enregistrés automatiquement.',
    setupTitle: 'Des conseils de posture en direct',
    setupBody:
        'Le mouvement est analysé sur l’appareil pour vous guider en temps réel.',
    controlTitle: 'Progressez avec l’historique et les défis',
    controlBody:
        'Consultez vos séances et choisissez un défi pour garder le rythme.',
    finish: 'Commencer',
  ),
  'ja' => (
    countTitle: 'カメラが回数を自動でカウント',
    countBody: 'スマートフォンを置いてスクワットするだけで、自動的に記録されます。',
    setupTitle: 'フォームをリアルタイムでコーチング',
    setupBody: '動きを端末内で解析し、必要なアドバイスをすぐに届けます。',
    controlTitle: '記録とチャレンジで継続',
    controlBody: '履歴を確認し、自分に合ったチャレンジで次の運動につなげられます。',
    finish: 'はじめる',
  ),
  'ar' => (
    countTitle: 'تعدّ الكاميرا التكرارات تلقائيًا',
    countBody: 'ضع هاتفك وابدأ تمارين القرفصاء ليتم تسجيلها تلقائيًا.',
    setupTitle: 'إرشادات فورية لتحسين الوضعية',
    setupBody: 'يُحلل جهازك الحركة ويقدم لك الإرشادات اللازمة في الوقت الفعلي.',
    controlTitle: 'استمر عبر السجل والتحديات',
    controlBody: 'راجع تمارينك واختر تحديًا مناسبًا للحفاظ على الاستمرارية.',
    finish: 'ابدأ',
  ),
  'zh' => (
    countTitle: '摄像头自动计数',
    countBody: '放好手机开始深蹲，次数会自动记录。',
    setupTitle: '实时提供动作指导',
    setupBody: '动作在设备端进行分析，并实时提供所需的姿势建议。',
    controlTitle: '通过记录和挑战坚持锻炼',
    controlBody: '查看锻炼记录，选择适合自己的挑战，继续完成下一个目标。',
    finish: '开始使用',
  ),
  'zh_Hant' => (
    countTitle: '相機自動計數',
    countBody: '放好手機開始深蹲，次數會自動記錄。',
    setupTitle: '即時提供動作指導',
    setupBody: '動作在裝置端進行分析，並即時提供所需的姿勢建議。',
    controlTitle: '透過記錄和挑戰持續鍛鍊',
    controlBody: '查看鍛鍊記錄，選擇適合自己的挑戰，繼續完成下一個目標。',
    finish: '開始使用',
  ),
  _ => (
    countTitle: 'The camera counts automatically',
    countBody:
        'Set down your phone and your squats are recorded automatically.',
    setupTitle: 'Get real-time form coaching',
    setupBody:
        'Motion is analyzed on your device so useful guidance appears right when you need it.',
    controlTitle: 'Stay consistent with records and challenges',
    controlBody:
        'Review your workouts and choose a challenge that keeps you moving.',
    finish: 'Get started',
  ),
};
