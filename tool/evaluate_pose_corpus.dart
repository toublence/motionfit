import 'dart:io';

import 'src/corpus_evaluator.dart';

Future<void> main(List<String> arguments) async {
  final options = _parseArguments(arguments);
  if (options == null) {
    stderr.writeln(
      'Usage: dart run tool/evaluate_pose_corpus.dart '
      '--manifest <path> [--format json|markdown] [--output <path>]',
    );
    exitCode = 64;
    return;
  }

  try {
    final report = await evaluateCorpusManifest(options.manifest);
    final rendered = options.format == 'markdown'
        ? report.toMarkdown()
        : '${report.toPrettyJson()}\n';
    if (options.output == null) {
      stdout.write(rendered);
    } else {
      await File(options.output!).writeAsString(rendered, flush: true);
    }
    if (!report.target97Validated) exitCode = 2;
  } on Object catch (error) {
    stderr.writeln('Corpus evaluation failed: $error');
    exitCode = 65;
  }
}

_Options? _parseArguments(List<String> arguments) {
  String? manifest;
  String? output;
  var format = 'json';
  for (var index = 0; index < arguments.length; index++) {
    final argument = arguments[index];
    if (argument == '--manifest' && index + 1 < arguments.length) {
      manifest = arguments[++index];
    } else if (argument == '--output' && index + 1 < arguments.length) {
      output = arguments[++index];
    } else if (argument == '--format' && index + 1 < arguments.length) {
      format = arguments[++index];
    } else {
      return null;
    }
  }
  if (manifest == null || !{'json', 'markdown'}.contains(format)) return null;
  return _Options(manifest: manifest, output: output, format: format);
}

class _Options {
  const _Options({
    required this.manifest,
    required this.output,
    required this.format,
  });

  final String manifest;
  final String? output;
  final String format;
}
