import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ShortcutActionInfo {
  final LogicalKeyboardKey mainKey;
  final Set<LogicalKeyboardKey> modifiers;

  ShortcutActionInfo({required this.mainKey, this.modifiers = const {}})
    : assert(
        modifiers.every(
          (mod) =>
              mod == LogicalKeyboardKey.shift ||
              mod == LogicalKeyboardKey.control ||
              mod == LogicalKeyboardKey.alt ||
              mod == LogicalKeyboardKey.meta,
        ),
        'Modifiers can only be shift, control, alt, or meta',
      );
}

class _KeyDisplayInfo {
  final String? label;
  final IconData? icon;
  final double widthModifier;

  _KeyDisplayInfo({this.label, this.icon, this.widthModifier = 1})
    : assert(
        label != null || icon != null,
        'Either label or icon must be provided',
      );
}

class ShortcutInfo extends StatelessWidget {
  final ShortcutActionInfo shortcut;
  final double size;

  const ShortcutInfo({super.key, required this.shortcut, this.size = 20});

  static final Map<LogicalKeyboardKey, _KeyDisplayInfo> _defaultKeyMap = {
    .shift: _KeyDisplayInfo(icon: LucideIcons.arrowBigUp),
    .control: _KeyDisplayInfo(icon: LucideIcons.chevronUp),
    .alt: _KeyDisplayInfo(label: 'ALT', widthModifier: 1.6),
    .enter: _KeyDisplayInfo(icon: LucideIcons.cornerDownLeft),
    .backspace: _KeyDisplayInfo(icon: LucideIcons.delete),
    .delete: _KeyDisplayInfo(icon: LucideIcons.delete),
  };

  static final Map<LogicalKeyboardKey, _KeyDisplayInfo> _macOSKeyMap = {
    .alt: _KeyDisplayInfo(icon: LucideIcons.option),
    .meta: _KeyDisplayInfo(icon: LucideIcons.command),
  };

  static final Map<LogicalKeyboardKey, _KeyDisplayInfo> _windowsKeyMap = {
    .control: _KeyDisplayInfo(label: 'CTRL', widthModifier: 1.8),
    .meta: _KeyDisplayInfo(label: 'WIN', widthModifier: 1.6),
  };

  static final Map<LogicalKeyboardKey, _KeyDisplayInfo> _linuxKeyMap = {
    .meta: _KeyDisplayInfo(label: 'SUPER', widthModifier: 2.4),
  };

  @override
  Widget build(BuildContext context) {
    const double padding = 4;

    _KeyDisplayInfo getKeyDisplayInfo(LogicalKeyboardKey key) {
      _KeyDisplayInfo? info;
      if (Platform.isMacOS) {
        info = _macOSKeyMap[key];
      } else if (Platform.isWindows) {
        info = _windowsKeyMap[key];
      } else if (Platform.isLinux) {
        info = _linuxKeyMap[key];
      }
      return info ??
          _defaultKeyMap[key] ??
          _KeyDisplayInfo(label: key.keyLabel.toUpperCase());
    }

    buildKey(LogicalKeyboardKey key) {
      final info = getKeyDisplayInfo(key);
      return Container(
        width: size * info.widthModifier,
        height: size,
        padding: .all(padding),
        decoration: BoxDecoration(
          color: context.theme.colors.border,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Builder(
          builder: (_) {
            if (info.icon != null) {
              return Icon(info.icon, size: size - padding * 2);
            }
            return Text(
              info.label!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (size - 2) - padding * 2,
                fontWeight: .bold,
              ),
            );
          },
        ),
      );
    }

    return Row(
      mainAxisSize: .min,
      spacing: 2,
      children: [
        for (final mod in shortcut.modifiers) buildKey(mod),
        buildKey(shortcut.mainKey),
      ],
    );
  }
}

class TextWithShortCutInfo extends StatelessWidget {
  final String text;
  final ShortcutActionInfo shortcut;

  const TextWithShortCutInfo(this.text, {super.key, required this.shortcut});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: 8,
      children: [
        Text(text),
        ShortcutInfo(shortcut: shortcut),
      ],
    );
  }
}
