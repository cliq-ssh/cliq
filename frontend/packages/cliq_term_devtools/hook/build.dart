import 'dart:io';

import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    Process.runSync(
      'dart',
      [
        'run',
        'devtools_extensions',
        'build_and_copy',
        '--source=.',
        '--dest=../${input.packageName}/extension/devtools',
      ],
      runInShell: true,
    );
  });
}
