// Opt-in iOS QA: --target tool/unity_ads_device_test.dart.
// Profile builds additionally require the native UNITY_ADS_QA flag.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motionfit_squat/core/ads/ad_unit_ids.dart';

const _qa = MethodChannel('fit.motionfit.app/unity_ads_qa');
bool _meta = false;
String get _source => _meta ? 'Meta' : 'Unity';
String get _testModeMethod => _meta ? 'metaTestMode' : 'testMode';

Future<void> main() => runMediationQa();

Future<void> runMediationQa({bool meta = false}) async {
  _meta = meta;
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode || defaultTargetPlatform != TargetPlatform.iOS) {
    throw StateError('This QA entry point requires iOS Debug or QA Profile');
  }
  runApp(const MaterialApp(home: _UnityQa()));
}

class _UnityQa extends StatefulWidget {
  const _UnityQa();
  @override
  State<_UnityQa> createState() => _UnityQaState();
}

class _UnityQaState extends State<_UnityQa> {
  final _lines = <String>[];
  bool _ready = false;
  bool _loading = false;
  bool _inspectorClosed = false;
  bool _impressed = false;

  void _record(String line) {
    debugPrint('${_source.toUpperCase()}_QA $line');
    unawaited(_qa.invokeMethod<void>(_meta ? 'recordMeta' : 'record', line));
    if (mounted) setState(() => _lines.add(line));
  }

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => updated.complete(),
        (error) => updated.completeError(StateError(error.message)),
      );
      await updated.future.timeout(const Duration(seconds: 60));
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) _record('consentFormError=${error.message}');
      });
      if (!await ConsentInformation.instance.canRequestAds())
        throw StateError('Consent blocks ads');
      _record('consentAllowed=true');
      if (_meta) {
        await _qa.invokeMethod<bool>('initializeMeta');
        await const MethodChannel(
          'fit.motionfit.app/meta_ads_privacy',
        ).invokeMethod<void>('syncTrackingAuthorization');
      } else {
        final version = await _qa.invokeMethod<String>('initializeUnity');
        _record('unitySdk=$version');
      }
      final status = await MobileAds.instance.initialize();
      for (final entry in status.adapterStatuses.entries) {
        _record(
          'adapter=${entry.key} state=${entry.value.state} description=${entry.value.description}',
        );
      }
      if (await _qa.invokeMethod<bool>(_testModeMethod) != true)
        throw StateError('$_source test mode required');
      _record('${_source.toLowerCase()}TestMode=true');
      // Inspector needs an initial ad request to obtain its device/server configuration.
      final preflight = Completer<void>();
      await InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/4411468910',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _record('googleTestPreflightLoaded=true');
            ad.dispose();
            preflight.complete();
          },
          onAdFailedToLoad: (error) =>
              preflight.completeError(StateError(error.message)),
        ),
      );
      await preflight.future.timeout(const Duration(seconds: 60));
      setState(() => _ready = true);
    } catch (error) {
      _record('FAIL initialization: $error');
    }
  }

  Future<void> _load() async {
    if (!_ready || _loading || !_inspectorClosed) return;
    setState(() {
      _loading = true;
      _impressed = false;
    });
    if (await _qa.invokeMethod<bool>(_testModeMethod) != true) {
      _record('FAIL test mode disabled');
      return;
    }
    final unit = MotionFitAdUnits.releaseUnits(
      TargetPlatform.iOS,
    )['interstitial']!;
    _record('request=$unit');
    await InterstitialAd.load(
      adUnitId: unit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdFailedToLoad: (error) {
          _record('FAIL load: ${error.code} ${error.domain} ${error.message}');
          _record('responseInfo=${error.responseInfo}');
          setState(() => _loading = false);
        },
        onAdLoaded: (ad) {
          final adapter = ad.responseInfo?.mediationAdapterClassName ?? '';
          _record('loadedAdapter=$adapter');
          final name = adapter.toLowerCase();
          if (_meta
              ? !name.contains('meta') && !name.contains('facebook')
              : !name.contains('unity')) {
            ad.dispose();
            _record('FAIL expected $_source source');
            setState(() => _loading = false);
            return;
          }
          ad.fullScreenContentCallback =
              FullScreenContentCallback<InterstitialAd>(
                onAdShowedFullScreenContent: (_) => _record('showed=true'),
                onAdImpression: (_) {
                  _impressed = true;
                  _record('impression=true');
                },
                onAdClicked: (_) => _record('FAIL unexpected creative click'),
                onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  _record('FAIL show: ${error.code} ${error.message}');
                  setState(() => _loading = false);
                },
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _record('dismissed=true');
                  _record(_impressed ? 'PASS' : 'FAIL no impression');
                  setState(() => _loading = false);
                },
              );
          unawaited(ad.show());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('$_source Ads QA')),
    body: Column(
      children: [
        TextButton(
          onPressed: !_ready
              ? null
              : () {
                  MobileAds.instance.openAdInspector((error) {
                    _record('inspectorClosed=${error?.message ?? "OK"}');
                    setState(() => _inspectorClosed = error == null);
                  });
                },
          child: const Text('Open Ad Inspector'),
        ),
        TextButton(
          onPressed: _ready && _inspectorClosed && !_loading ? _load : null,
          child: Text('Load $_source interstitial'),
        ),
        Expanded(child: SingleChildScrollView(child: Text(_lines.join('\n')))),
      ],
    ),
  );
}
