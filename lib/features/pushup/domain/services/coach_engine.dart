import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:motionfit_squat/features/pushup/domain/models/workout_enums.dart';
import 'package:motionfit_squat/features/pushup/domain/services/form_analyzer.dart';

enum CoachMessageType {
  tracking,
  set,
  repCount,
  form,
  encouragement,
  rest,
  completion,
}

class CoachMessage {
  CoachMessage({
    required this.type,
    required this.text,
    required this.deduplicationKey,
    required this.createdAt,
    this.expiresAfter = const Duration(seconds: 4),
    this.repSequence,
    String? id,
  }) : id = id ?? 'coach-${createdAt.microsecondsSinceEpoch}-${_nextId++}';

  static int _nextId = 1;

  final String id;
  final CoachMessageType type;
  final String text;
  final String deduplicationKey;
  final DateTime createdAt;
  final Duration expiresAfter;
  final int? repSequence;

  int get priority => switch (type) {
    CoachMessageType.tracking => 500,
    CoachMessageType.form => 450,
    CoachMessageType.set ||
    CoachMessageType.rest ||
    CoachMessageType.completion => 400,
    CoachMessageType.repCount => 300,
    CoachMessageType.encouragement => 100,
  };

  bool get isExpired => DateTime.now().difference(createdAt) > expiresAfter;
}

abstract interface class CoachVoiceEngine {
  Future<bool> configure({required String locale, required double rate});
  Future<void> speak(
    String text, {
    CoachMessageType type = CoachMessageType.form,
  });
  Future<void> stop();
  Future<void> dispose();
}

class SystemTtsCoachEngine implements CoachVoiceEngine {
  SystemTtsCoachEngine({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;
  double _baseRate = 0.48;
  bool _iosAudioSessionActive = false;

  static const _languageTags = <String, String>{
    'en': 'en-US',
    'ko': 'ko-KR',
    'de': 'de-DE',
    'es': 'es-ES',
    'fr': 'fr-FR',
    'ja': 'ja-JP',
    'ar': 'ar-SA',
  };

  @override
  Future<bool> configure({required String locale, required double rate}) async {
    final normalizedLocale = locale.trim().replaceAll('_', '-');
    if (normalizedLocale.isEmpty) return false;
    final baseLanguage = normalizedLocale.split('-').first.toLowerCase();
    final canonicalLanguage = _languageTags[baseLanguage];
    // Only the 7 app languages are mapped; anything else has no voice.
    if (canonicalLanguage == null) return false;

    final selectedLanguage = await _resolveLanguage(
      normalizedLocale: normalizedLocale,
      baseLanguage: baseLanguage,
      canonicalLanguage: canonicalLanguage,
    );

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final categoryResult = await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        const [IosTextToSpeechAudioCategoryOptions.duckOthers],
        IosTextToSpeechAudioMode.spokenAudio,
      );
      final autoStopResult = await _flutterTts.autoStopSharedSession(false);
      final activationResult = await _flutterTts.setSharedInstance(true);
      _iosAudioSessionActive = activationResult == 1;
      if (categoryResult != 1 || autoStopResult != 1 || activationResult != 1) {
        await _deactivateIosAudioSession();
        return false;
      }
    }

    final languageResult = await _flutterTts.setLanguage(selectedLanguage);
    if (languageResult == 0) {
      await _deactivateIosAudioSession();
      return false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _selectBestIosVoice(
        baseLanguage: baseLanguage,
        selectedLanguage: selectedLanguage,
      );
    }
    _baseRate = rate.clamp(0.2, 0.8).toDouble();
    await _flutterTts.setSpeechRate(_baseRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
    return true;
  }

  Future<void> _selectBestIosVoice({
    required String baseLanguage,
    required String selectedLanguage,
  }) async {
    try {
      final rawVoices = await _flutterTts.getVoices;
      if (rawVoices is! List) return;
      final voices = rawVoices
          .whereType<Map>()
          .map(
            (voice) => voice.map(
              (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
            ),
          )
          .where((voice) {
            final locale = voice['locale']?.toLowerCase() ?? '';
            return locale.split(RegExp('[-_]')).first == baseLanguage;
          })
          .toList();
      if (voices.isEmpty) return;

      int qualityRank(Map<String, String> voice) =>
          switch (voice['quality']?.toLowerCase()) {
            'premium' => 3,
            'enhanced' => 2,
            _ => 1,
          };

      final preferredLocale = selectedLanguage.toLowerCase();
      voices.sort((left, right) {
        final quality = qualityRank(right).compareTo(qualityRank(left));
        if (quality != 0) return quality;
        final leftExact = left['locale']?.toLowerCase() == preferredLocale;
        final rightExact = right['locale']?.toLowerCase() == preferredLocale;
        return (rightExact ? 1 : 0).compareTo(leftExact ? 1 : 0);
      });
      final selected = voices.first;
      final identifier = selected['identifier'];
      if (identifier != null && identifier.isNotEmpty) {
        await _flutterTts.setVoice({'identifier': identifier});
        return;
      }
      final name = selected['name'];
      final locale = selected['locale'];
      if (name != null &&
          name.isNotEmpty &&
          locale != null &&
          locale.isNotEmpty) {
        await _flutterTts.setVoice({'name': name, 'locale': locale});
      }
    } on Object {
      // The language default remains a valid fallback when voice enumeration
      // is unavailable or a downloaded voice was removed by the system.
    }
  }

  /// Picks the best language tag for [baseLanguage] that the device's TTS
  /// engine can actually speak. Prefers a voice already installed on the
  /// device (region-tolerant, e.g. accepts `es-US` when the app is `es`), and
  /// otherwise falls back to the canonical tag so the platform still attempts
  /// the selected language (iOS ships every voice; Android can fetch on demand)
  /// instead of silently dropping voice coaching.
  Future<String> _resolveLanguage({
    required String normalizedLocale,
    required String baseLanguage,
    required String canonicalLanguage,
  }) async {
    String baseOf(String tag) => tag.toLowerCase().split(RegExp('[-_]')).first;

    final available = await _availableLanguages();
    if (available.isNotEmpty) {
      final wanted = normalizedLocale.toLowerCase();
      final canonical = canonicalLanguage.toLowerCase();
      // 1) Exact match on the full locale, then on the canonical region tag.
      for (final preferred in [wanted, canonical]) {
        for (final lang in available) {
          if (lang.toLowerCase() == preferred) return lang;
        }
      }
      // 2) Any installed voice that shares the base language.
      for (final lang in available) {
        if (baseOf(lang) == baseLanguage) return lang;
      }
    }

    // 3) Probe availability directly (covers engines without getLanguages).
    for (final candidate in <String>{
      normalizedLocale,
      baseLanguage,
      canonicalLanguage,
    }) {
      final availability = await _flutterTts.isLanguageAvailable(candidate);
      if (availability == true || availability == 1) return candidate;
    }

    // 4) Best effort: attempt the canonical tag anyway.
    return canonicalLanguage;
  }

  Future<List<String>> _availableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      if (languages is List) {
        return languages
            .map((language) => language?.toString() ?? '')
            .where((language) => language.isNotEmpty)
            .toList(growable: false);
      }
    } on Object {
      // Some engines/platforms don't implement getLanguages; fall back below.
    }
    return const [];
  }

  @override
  Future<void> speak(
    String text, {
    CoachMessageType type = CoachMessageType.form,
  }) async {
    final rateMultiplier = switch (type) {
      CoachMessageType.repCount => 1.12,
      CoachMessageType.encouragement => 1.08,
      CoachMessageType.set ||
      CoachMessageType.rest ||
      CoachMessageType.completion => 1.04,
      CoachMessageType.tracking => 0.96,
      CoachMessageType.form => 1.0,
    };
    final pitch = switch (type) {
      CoachMessageType.repCount || CoachMessageType.encouragement => 1.08,
      CoachMessageType.set ||
      CoachMessageType.rest ||
      CoachMessageType.completion => 1.04,
      CoachMessageType.tracking => 0.98,
      CoachMessageType.form => 1.0,
    };
    await _flutterTts.setSpeechRate(
      (_baseRate * rateMultiplier).clamp(0.2, 0.8).toDouble(),
    );
    await _flutterTts.setPitch(pitch);
    if (kDebugMode) {
      debugPrint('[MotionFitCoach] speak type=${type.name} text="$text"');
    }
    final result = await _flutterTts.speak(text);
    if (result != 1) {
      throw StateError('The text-to-speech engine rejected the message.');
    }
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _deactivateIosAudioSession();
  }

  Future<void> _deactivateIosAudioSession() async {
    if (_iosAudioSessionActive) {
      _iosAudioSessionActive = false;
      await _flutterTts.setSharedInstance(false);
    }
  }
}

class CoachQueue {
  CoachQueue(
    this._engine, {
    this.defaultCooldown = const Duration(seconds: 4),
    this.onDelivery,
    this.onDebugDelivery,
  });

  final CoachVoiceEngine _engine;
  final Duration defaultCooldown;
  void Function(String event, CoachMessage message)? onDelivery;
  void Function(String event, CoachMessage message, String? reason)?
  onDebugDelivery;
  final List<CoachMessage> _pending = [];
  final Map<String, DateTime> _lastSpoken = {};
  final Map<String, DateTime> _lastPresented = {};
  final Set<int> _formCoachedReps = {};
  final StreamController<String?> _subtitleController =
      StreamController<String?>.broadcast(sync: true);
  bool _speaking = false;
  bool _enabled = true;
  int _cancellationGeneration = 0;
  CoachMessage? _currentMessage;
  Timer? _subtitleTimer;

  Stream<String?> get subtitles => _subtitleController.stream;

  void setEnabled(bool value) {
    _enabled = value;
    if (!value) {
      _cancellationGeneration++;
      for (final message in _pending) {
        onDebugDelivery?.call('cancelled', message, 'ttsDisabled');
      }
      _pending.clear();
      unawaited(_engine.stop().catchError((Object _) {}));
    }
  }

  Future<void> enqueue(CoachMessage message) async {
    if (message.text.trim().isEmpty) {
      onDebugDelivery?.call('cancelled', message, 'emptyMessage');
      return;
    }
    if (message.isExpired) {
      onDebugDelivery?.call('cancelled', message, 'expired');
      return;
    }
    if (message.type == CoachMessageType.form &&
        message.repSequence != null &&
        _formCoachedReps.contains(message.repSequence)) {
      onDebugDelivery?.call('cancelled', message, 'sameIssueRepSuppression');
      return;
    }
    final lastPresented = _lastPresented[message.deduplicationKey];
    if (lastPresented != null &&
        DateTime.now().difference(lastPresented) < defaultCooldown) {
      onDebugDelivery?.call('cancelled', message, 'queueCooldown');
      return;
    }
    _lastPresented[message.deduplicationKey] = DateTime.now();
    _showSubtitle(message.text);
    if (!_enabled) {
      onDebugDelivery?.call('cancelled', message, 'ttsDisabled');
      return;
    }
    final last = _lastSpoken[message.deduplicationKey];
    if (last != null && DateTime.now().difference(last) < defaultCooldown) {
      onDebugDelivery?.call('cancelled', message, 'queueCooldown');
      return;
    }
    _pending.removeWhere((queued) {
      final remove =
          queued.deduplicationKey == message.deduplicationKey ||
          queued.isExpired ||
          (message.type == CoachMessageType.repCount &&
              (queued.type == CoachMessageType.repCount ||
                  queued.type == CoachMessageType.encouragement));
      if (remove) {
        onDebugDelivery?.call(
          'cancelled',
          queued,
          queued.isExpired ? 'expired' : 'higherPriorityMessage',
        );
      }
      return remove;
    });
    _pending.add(message);
    onDelivery?.call('queued', message);
    onDebugDelivery?.call('queued', message, null);
    _pending.sort((a, b) {
      final priority = b.priority.compareTo(a.priority);
      return priority == 0 ? a.createdAt.compareTo(b.createdAt) : priority;
    });
    if (_speaking &&
        message.type == CoachMessageType.repCount &&
        _currentMessage?.type == CoachMessageType.encouragement) {
      _cancellationGeneration++;
      unawaited(_engine.stop().catchError((Object _) {}));
    }
    await _drain();
  }

  Future<void> _drain() async {
    if (_speaking || !_enabled) return;
    _speaking = true;
    try {
      while (_pending.isNotEmpty && _enabled) {
        final message = _pending.removeAt(0);
        if (message.isExpired) {
          onDebugDelivery?.call('cancelled', message, 'expired');
          continue;
        }
        if (message.type == CoachMessageType.form &&
            message.repSequence != null) {
          _formCoachedReps.add(message.repSequence!);
        }
        _lastSpoken[message.deduplicationKey] = DateTime.now();
        _showSubtitle(message.text);
        _currentMessage = message;
        final generation = _cancellationGeneration;
        try {
          onDelivery?.call('speaking', message);
          onDebugDelivery?.call('speaking', message, null);
          await _speakWithRetry(message, generation);
          onDelivery?.call('spoken', message);
          onDebugDelivery?.call('spoken', message, null);
        } on _CoachSpeechCancelled {
          onDelivery?.call('cancelled', message);
          onDebugDelivery?.call('cancelled', message, 'ttsDisabled');
        } on Object catch (error) {
          onDelivery?.call('failed', message);
          onDebugDelivery?.call(
            'failed',
            message,
            error.runtimeType.toString(),
          );
          _cancellationGeneration++;
          _enabled = false;
          _pending.clear();
        } finally {
          if (identical(_currentMessage, message)) _currentMessage = null;
        }
      }
    } finally {
      _currentMessage = null;
      _speaking = false;
    }
  }

  Future<void> _speakWithRetry(CoachMessage message, int generation) async {
    try {
      await _engine.speak(message.text, type: message.type);
      if (!_canContinueSpeaking(message, generation)) {
        throw const _CoachSpeechCancelled();
      }
      return;
    } on _CoachSpeechCancelled {
      rethrow;
    } on Object catch (error) {
      if (!_canContinueSpeaking(message, generation)) {
        throw const _CoachSpeechCancelled();
      }
      onDelivery?.call('retrying', message);
      onDebugDelivery?.call('retrying', message, error.runtimeType.toString());
      await _engine.stop().catchError((Object _) {});
      if (!_canContinueSpeaking(message, generation)) {
        throw const _CoachSpeechCancelled();
      }
      await _engine.speak(message.text, type: message.type);
      if (!_canContinueSpeaking(message, generation)) {
        throw const _CoachSpeechCancelled();
      }
    }
  }

  bool _canContinueSpeaking(CoachMessage message, int generation) =>
      _enabled &&
      generation == _cancellationGeneration &&
      identical(_currentMessage, message);

  void _showSubtitle(String text) {
    _subtitleTimer?.cancel();
    _subtitleController.add(text);
    _subtitleTimer = Timer(const Duration(seconds: 4), () {
      _subtitleController.add(null);
    });
  }

  Future<void> dispose() async {
    _subtitleTimer?.cancel();
    _enabled = false;
    _cancellationGeneration++;
    _pending.clear();
    try {
      await _engine.dispose();
    } finally {
      await _subtitleController.close();
    }
  }
}

class _CoachSpeechCancelled implements Exception {
  const _CoachSpeechCancelled();
}

enum CoachPolicyRejectReason {
  noDetectedIssue,
  globalRepSuppression,
  insufficientConfidence,
  sameIssueRepSuppression,
  insufficientObservations,
}

class CoachPolicyDecision {
  const CoachPolicyDecision({
    required this.candidateIssue,
    required this.selectedIssue,
    required this.rejectReason,
  });
  final FormIssue? candidateIssue;
  final FormIssue? selectedIssue;
  final CoachPolicyRejectReason? rejectReason;
}

class CoachPolicy {
  final List<FormAnalysisResult> _recent = [];
  final Map<FormIssue, int> _lastCoachedRep = {};
  int? _lastAnyCoachedRep;

  FormIssue? selectIssue(FormAnalysisResult analysis) =>
      evaluate(analysis).selectedIssue;

  CoachPolicyDecision evaluate(FormAnalysisResult analysis) {
    if (_recent.isNotEmpty &&
        _recent.last.repSequence == analysis.repSequence) {
      _recent[_recent.length - 1] = analysis;
    } else {
      _recent.add(analysis);
      if (_recent.length > 3) _recent.removeAt(0);
    }
    final lastAnyCoached = _lastAnyCoachedRep;
    final candidate =
        analysis.primaryIssue ??
        (analysis.detectedIssues.isEmpty
            ? null
            : analysis.detectedIssues.first);
    if (candidate == null) {
      return const CoachPolicyDecision(
        candidateIssue: null,
        selectedIssue: null,
        rejectReason: CoachPolicyRejectReason.noDetectedIssue,
      );
    }
    if (lastAnyCoached != null && analysis.repSequence - lastAnyCoached < 2) {
      return CoachPolicyDecision(
        candidateIssue: candidate,
        selectedIssue: null,
        rejectReason: CoachPolicyRejectReason.globalRepSuppression,
      );
    }

    FormIssue? selected;
    var selectedScore = double.negativeInfinity;
    var confidenceRejected = false;
    var sameIssueRejected = false;
    var observationRejected = false;
    for (final metric in analysis.metrics.values) {
      final issue = metric.issue;
      if (issue == null ||
          metric.status != FormMetricStatus.needsAttention ||
          metric.confidence < 0.70) {
        if (issue != null && metric.confidence < 0.70) {
          confidenceRejected = true;
        }
        continue;
      }
      final lastCoached = _lastCoachedRep[issue];
      if (lastCoached != null && analysis.repSequence - lastCoached < 3) {
        sameIssueRejected = true;
        continue;
      }
      final observations = _recent.where((recent) {
        return recent.metrics.values.any(
          (value) =>
              value.issue == issue &&
              value.status == FormMetricStatus.needsAttention &&
              value.confidence >= 0.70,
        );
      }).length;
      final safetyCritical =
          issue == FormIssue.heelLift ||
          issue == FormIssue.kneeAlignment ||
          issue == FormIssue.excessiveTorsoLean;
      final clearlyObserved =
          metric.confidence >= (safetyCritical ? 0.85 : 0.82) &&
          metric.persistence >= 0.60;
      if (observations < 2 && !clearlyObserved) {
        observationRejected = true;
        continue;
      }

      final safetyWeight = safetyCritical ? 0.35 : 0.0;
      final severity = 1 - ((metric.score ?? 100) / 100);
      final score = observations + safetyWeight + severity * metric.persistence;
      if (score > selectedScore) {
        selected = issue;
        selectedScore = score;
      }
    }
    if (selected != null) {
      _lastCoachedRep[selected] = analysis.repSequence;
      _lastAnyCoachedRep = analysis.repSequence;
    }
    return CoachPolicyDecision(
      candidateIssue: candidate,
      selectedIssue: selected,
      rejectReason: selected != null
          ? null
          : sameIssueRejected
          ? CoachPolicyRejectReason.sameIssueRepSuppression
          : observationRejected
          ? CoachPolicyRejectReason.insufficientObservations
          : confidenceRejected
          ? CoachPolicyRejectReason.insufficientConfidence
          : CoachPolicyRejectReason.insufficientObservations,
    );
  }
}
