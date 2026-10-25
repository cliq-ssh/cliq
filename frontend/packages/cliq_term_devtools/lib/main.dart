import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CliqTermDevtoolsExtension());
}

class CliqTermDevtoolsExtension extends StatelessWidget {
  const CliqTermDevtoolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(
      child: Placeholder(), // Build your extension here
    );
  }
}
