import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ErrorCard extends StatelessWidget {
  final String text;

  const ErrorCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return FCard(
      style: .delta(
        decoration: .boxDelta(
          color: context.theme.colors.destructive.withValues(alpha: 0.1),
          border: Border.all(
            color: context.theme.colors.destructive.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(LucideIcons.triangleAlert),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
