import 'package:cliq/shared/utils/constants.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:forui/forui.dart';

class ErrorCard extends StatelessWidget {
  final String text;

  const new({super.key, required this.text});

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
      child: Padding(
        padding: const .all(12),
        child: Text(
          text,
          style: context.theme.typography.body.xs.copyWith(
            fontFamily: Constants.secondaryFont,
          ),
        ),
      ),
    );
  }
}
