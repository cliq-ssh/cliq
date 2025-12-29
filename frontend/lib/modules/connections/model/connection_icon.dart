import 'package:flutter/cupertino.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

enum ConnectionIcon {
  unknown(LucideIcons.circleQuestionMark),

  // OS-specific
  windows(LucideIcons.circleQuestionMark),
  darwin(LucideIcons.circleQuestionMark),
  debian(LucideIcons.circleQuestionMark),
  fedora(LucideIcons.circleQuestionMark),
  arch(LucideIcons.circleQuestionMark),
  ubuntu(LucideIcons.circleQuestionMark),

  // generic lucide icons
  computer(LucideIcons.computer),
  laptop(LucideIcons.laptop);

  final IconData iconData;
  const ConnectionIcon(this.iconData);
}
