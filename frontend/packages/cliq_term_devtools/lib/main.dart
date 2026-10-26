import 'package:cliq_term_devtools/widgets/terminal_list.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CliqTermDevToolsExtension());
}

class CliqTermDevToolsExtension extends StatelessWidget {
  const CliqTermDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(child: TerminalList());
  }
}
