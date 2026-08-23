import 'dart:math';

import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum _RenderableTag {
  bold(tag: 'b', render: _renderBold),
  tip(tag: 'tip', render: _renderTip),
  link(tag: 'link', render: _renderLink),
  shiftIcon(tag: 'shiftIcon', render: _renderShiftIcon),
  undoIcon(tag: 'undoIcon', render: _renderUndoIcon);

  final String tag;
  final InlineSpan Function(
    BuildContext context,
    List<InlineSpan> children,
    Map<String, String> attributes,
    TextStyle? parentStyle,
  )
  render;

  new({required this.tag, required this.render});

  static _RenderableTag? fromTag(String tag) =>
      _RenderableTag.values.where((t) => t.tag == tag).firstOrNull;

  static InlineSpan _renderBold(
    BuildContext context,
    List<InlineSpan> children,
    Map<String, String> attributes,
    TextStyle? parentStyle,
  ) => TextSpan(
    style: const TextStyle(fontWeight: .bold),
    children: children,
  );

  static InlineSpan _renderTip(
    BuildContext context,
    List<InlineSpan> children,
    Map<String, String> attributes,
    TextStyle? parentStyle,
  ) => TextSpan(
    style: TextStyle(color: context.theme.colors.mutedForeground),
    children: children,
  );

  static InlineSpan _renderLink(
    BuildContext context,
    List<InlineSpan> children,
    Map<String, String> attributes,
    TextStyle? parentStyle,
  ) {
    final style = (parentStyle ?? const .new()).copyWith(
      color: context.theme.colors.primary,
    );

    final url = attributes['url'];
    if (url != null) {
      return WidgetSpan(
        style: style,
        alignment: .middle,
        child: FTappable(
          onPress: () => launchUrlString(url, mode: .externalApplication),
          child: Text.rich(
            style: style,
            TextSpan(
              children: [
                WidgetSpan(
                  style: style,
                  alignment: .middle,
                  child: Padding(
                    padding: const .only(right: 4),
                    child: IconTheme(
                      data: .new(color: style.color, size: style.fontSize),
                      child: const Icon(LucideIcons.externalLink),
                    ),
                  ),
                ),
                ...children,
              ],
            ),
          ),
        ),
      );
    }

    return TextSpan(style: style, children: children);
  }

  static InlineSpan _renderShiftIcon(
    BuildContext context,
    List<InlineSpan> children,
    Map<String, String> attributes,
    TextStyle? parentStyle,
  ) => WidgetSpan(child: ShortcutInfo(shortcut: KeyboardShortcut(.shift)));

  static InlineSpan _renderUndoIcon(
    BuildContext context,
    List<InlineSpan> children,
    Map<String, String> attributes,
    TextStyle? parentStyle,
  ) => WidgetSpan(
    alignment: .middle,
    child: Icon(
      LucideIcons.undo2,
      color: parentStyle?.color,
      size: parentStyle?.fontSize,
    ),
  );
}

class TextUtils {
  const new _();

  static String? formatBytes(num? bytes, {int decimals = 2}) {
    if (bytes == null || bytes <= 0) return null;
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / (pow(1024, i))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Renders the given text into a list of InlineSpan.
  /// This allows using simple tags like <b> for bold, <i> for italic, and <u> for underline
  static List<InlineSpan> renderText(
    BuildContext context,
    String text, {
    TextStyle? style,
  }) {
    final spans = <InlineSpan>[];

    final tagNames = _RenderableTag.values
        .map((t) => RegExp.escape(t.tag))
        .join('|');

    final pattern = RegExp(
      '<($tagNames)(?:\\s+([^>]*))?(/>|>(.*?)</\\1>)',
      dotAll: true,
    );

    var lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      // Add any plain text that appeared before this tag
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      final tagName = match.group(1)!;
      final attributesStr = match.group(2);
      final content = match.group(4); // null for self-closing tags
      final attributes = _parseAttributes(attributesStr);

      final tag = _RenderableTag.fromTag(tagName);
      if (tag == null) {
        // if the tag is not recognized, treat it as plain text
        spans.add(TextSpan(text: text.substring(match.start, match.end)));
      } else {
        // recursively parse the tag's content so nested tags are rendered too;
        // self-closing tags have no content, so pass an empty list
        spans.add(
          tag.render(
            context,
            content == null
                ? const []
                : renderText(context, content, style: style),
            attributes,
            style,
          ),
        );
      }

      lastEnd = match.end;
    }

    // Add any trailing plain text after the last matched tag
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    // If there were no tags at all, just return the whole text as a single span
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }

    return spans;
  }

  static Map<String, String> _parseAttributes(String? attributesStr) {
    final attributes = <String, String>{};
    if (attributesStr == null || attributesStr.isEmpty) return attributes;

    for (final match in RegExp(r'(\w+)="([^"]*)"').allMatches(attributesStr)) {
      attributes[match.group(1)!] = match.group(2)!;
    }

    return attributes;
  }
}
