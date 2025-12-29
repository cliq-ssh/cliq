import 'package:flutter/cupertino.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:simple_icons/simple_icons.dart';

enum ConnectionIcon {
  // OS-specific
  linux(SimpleIcons.linux, brandColor: SimpleIconColors.linux),
  debian(SimpleIcons.debian, brandColor: SimpleIconColors.debian),
  fedora(SimpleIcons.fedora, brandColor: SimpleIconColors.fedora),
  arch(SimpleIcons.archlinux, brandColor: SimpleIconColors.archlinux),
  ubuntu(SimpleIcons.ubuntu, brandColor: SimpleIconColors.ubuntu),
  raspberryPi(
    SimpleIcons.raspberrypi,
    brandColor: SimpleIconColors.raspberrypi,
  ),
  android(SimpleIcons.android, brandColor: SimpleIconColors.android),
  centos(SimpleIcons.centos, brandColor: SimpleIconColors.centos),

  // generic icons
  computer(LucideIcons.computer),
  laptop(LucideIcons.laptop),

  unknown(LucideIcons.circleQuestionMark);

  final IconData iconData;
  final Color? brandColor;

  const ConnectionIcon(this.iconData, {this.brandColor});

  static ConnectionIcon fromString(String value) {
    return ConnectionIcon.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ConnectionIcon.unknown,
    );
  }
}
