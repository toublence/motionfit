// Real production ad service + Google demo ads. No workout data/Firebase writes.
// Trace: app data container tmp/ios-ads-regression.jsonl.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motionfit_squat/core/ads/ad_sdk.dart';
import 'package:motionfit_squat/core/ads/ad_service.dart';
import 'package:motionfit_squat/core/ads/ad_slot.dart';
import 'package:motionfit_squat/core/analytics/analytics_service.dart';
import 'package:motionfit_squat/core/providers.dart';

class AdsRegressionQa extends StatefulWidget {
  const AdsRegressionQa({super.key});
  @override
  State<AdsRegressionQa> createState() => _AdsRegressionQaState();
}

class _AdsRegressionQaState extends State<AdsRegressionQa>
    with WidgetsBindingObserver {
  late final AdService _ads;
  late final _Trace _trace;
  final _lines = <String>[];
  bool _ready = false;
  int _bannerGeneration = 0;

  @override
  void initState() {
    super.initState();
    if (kReleaseMode || defaultTargetPlatform != TargetPlatform.iOS) {
      throw StateError('QA requires iOS Debug or Profile');
    }
    _trace = _Trace((line) {
      if (mounted) setState(() => _lines.add(line));
    });
    _ads = AdService(analytics: AnalyticsService(sink: _trace));
    WidgetsBinding.instance.addObserver(this);
    _ads.updatePolicyContext(
      onboardingCompleted: true,
      completedWorkoutCount: 2,
    );
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    final ready = await _ads.initialize();
    _trace.record('qa_initialized', {'ready': ready});
    if (mounted) setState(() => _ready = ready);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _ads.setForeground(
      state == AppLifecycleState.resumed,
      visible:
          state == AppLifecycleState.resumed ||
          state == AppLifecycleState.inactive,
    );
    _trace.record('qa_lifecycle', {
      'state': state.name,
      'visible': _ads.visible,
      'loads_allowed': _ads.loadsAllowed,
      'full_screen_showing': _ads.fullScreenShowing,
    });
  }

  Future<void> _showInterstitial() async {
    final shown = await _ads.showInterstitialIfAvailable(
      lastInterstitialShownAt: null,
      completedWorkoutCount: 2,
    );
    _trace.record('qa_interstitial_complete', {'shown': shown});
  }

  void _appOpen(int count) {
    _ads.beginAppOpenOpportunity(
      trigger: 'device_qa',
      appEntryCount: count,
      lastFullScreenShownAt: null,
      isOpportunityValid: () => mounted && _ads.foreground,
      onShown: (_) => _trace.record('qa_app_open_shown', {}),
    );
  }

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [adServiceProvider.overrideWithValue(_ads)],
    child: Scaffold(
      appBar: AppBar(title: const Text('Production Ad Service QA')),
      body: Column(
        children: [
          TextButton(
            onPressed: !_ready ? null : _showInterstitial,
            child: const Text('Show interstitial'),
          ),
          TextButton(
            onPressed: !_ready ? null : () {
              setState(() => _bannerGeneration++);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) unawaited(_showInterstitial());
              });
            },
            child: const Text('Show interstitial + reload banner'),
          ),
          TextButton(
            onPressed: !_ready ? null : () => _appOpen(0),
            child: const Text('Prime app-open'),
          ),
          TextButton(
            onPressed: !_ready ? null : () => _appOpen(3),
            child: const Text('Show app-open'),
          ),
          const AdSlot(format: AdFormat.native, placement: 'device_qa_native'),
          Expanded(
            child: SingleChildScrollView(child: Text(_lines.join('\n'))),
          ),
          AdSlot(
            key: ValueKey(_bannerGeneration),
            format: AdFormat.banner,
            placement: 'device_qa_banner',
          ),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ads.dispose();
    super.dispose();
  }
}

class _Trace implements AnalyticsSink {
  _Trace(this.onLine) {
    file.writeAsStringSync('');
  }
  final void Function(String) onLine;
  final file = File('${Directory.systemTemp.path}/ios-ads-regression.jsonl');
  void record(String event, Map<String, Object> parameters) {
    final line = jsonEncode({
      'at': DateTime.now().toUtc().toIso8601String(),
      'event': event,
      'parameters': parameters,
    });
    file.writeAsStringSync('$line\n', mode: FileMode.append, flush: true);
    debugPrint('IOS_ADS_QA $line');
    onLine(line);
  }

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async =>
      record(name, parameters);
  @override
  Future<void> logScreenView(String screenName) async {}
}
