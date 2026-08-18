import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/corpus_evaluator.dart';

void main() {
  test(
    'synthetic smoke corpus is deterministic but never 97%-qualified',
    () async {
      final report = await evaluateCorpusManifest(
        'test/fixtures/corpus/synthetic_smoke_manifest.json',
      );
      final expected = jsonDecode(
        await File(
          'test/fixtures/corpus/synthetic_smoke_expected_report.json',
        ).readAsString(),
      );

      expect(report.toJson(), expected);
      expect(report.exactCountAccuracy, 1);
      expect(report.targetMetricsMet, isTrue);
      expect(report.corpusEligible, isFalse);
      expect(report.target97Validated, isFalse);
      expect(report.status, 'INELIGIBLE_CORPUS');
      expect(report.toMarkdown(), contains('97% target validated: NO'));
      expect(
        report.toMarkdown(),
        contains('Synthetic or unlabeled fixtures are smoke tests only'),
      );
    },
  );
}
