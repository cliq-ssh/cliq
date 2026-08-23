import 'package:flutter/cupertino.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

enum EntityType {
  connection(LucideIcons.server),
  identity(LucideIcons.users),
  key(LucideIcons.keyRound),
  knownHost(LucideIcons.fingerprint),
  colorSchemes(LucideIcons.palette);

  final IconData icon;
  new(this.icon);
}
