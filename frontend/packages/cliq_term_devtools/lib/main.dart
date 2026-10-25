import 'package:cliq_term_devtools/widgets/terminal_list.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SomePkgDevToolsExtension());
}

class SomePkgDevToolsExtension extends StatelessWidget {
  const SomePkgDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(child: TerminalList());
  }
}
