import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.length < 4 || args[1] != '--rep') {
    stderr.writeln(
      'Usage: dart run tool/label_debug_session.dart SESSION.json '
      '--rep N --label GOOD|BORDERLINE|BAD [--issue issueName|none]',
    );
    exitCode = 64;
    return;
  }
  String? option(String name) {
    final index = args.indexOf(name);
    return index >= 0 && index + 1 < args.length ? args[index + 1] : null;
  }

  final file = File(args.first);
  final repNumber = int.parse(option('--rep')!);
  final label = option('--label')?.toUpperCase();
  final issue = option('--issue');
  if (!const {'GOOD', 'BORDERLINE', 'BAD'}.contains(label)) {
    throw ArgumentError('label must be GOOD, BORDERLINE, or BAD');
  }
  final root = jsonDecode(await file.readAsString()) as Map<String, Object?>;
  final reps = (root['repResults'] as List).cast<Map>();
  final rep = reps.cast<Map>().firstWhere(
    (item) => (item['repSequence'] as num).toInt() == repNumber,
    orElse: () => throw StateError('Rep $repNumber was not found.'),
  );
  rep['manualLabel'] = label;
  rep['manualIssue'] = issue == null || issue == 'none' ? null : issue;
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(root),
    flush: true,
  );
  stdout.writeln(
    'Labeled rep $repNumber: $label / ${rep['manualIssue'] ?? 'none'}',
  );
}
