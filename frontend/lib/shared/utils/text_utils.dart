import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:forui/forui.dart';
import 'package:flutter/cupertino.dart';

import '../ui/shortcut_info.dart';

enum _RenderableTag {
  bold(tag: 'b', render: _renderBold),
  tip(tag: 'tip', render: _renderTip),
  shiftIcon(tag: 'shiftIcon', render: _renderShiftIcon);

  final String tag;
  final InlineSpan Function(BuildContext context, List<InlineSpan> children)
  render;

  const _RenderableTag({required this.tag, required this.render});

  static _RenderableTag? fromTag(String tag) =>
      _RenderableTag.values.where((t) => t.tag == tag).firstOrNull;

  static InlineSpan _renderBold(
    BuildContext context,
    List<InlineSpan> children,
  ) => TextSpan(
    style: const TextStyle(fontWeight: FontWeight.bold),
    children: children,
  );

  static InlineSpan _renderTip(
    BuildContext context,
    List<InlineSpan> children,
  ) => TextSpan(
    style: TextStyle(color: context.theme.colors.mutedForeground),
    children: children,
  );

  static InlineSpan _renderShiftIcon(
    BuildContext context,
    List<InlineSpan> children,
  ) => WidgetSpan(child: ShortcutInfo(shortcut: KeyboardShortcut(.shift)));
}

class TextUtils {
  const TextUtils._();

  static String? formatBytes(int? bytes, {int decimals = 2}) {
    if (bytes == null || bytes <= 0) return null;
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / (pow(1024, i))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Renders the given text into a list of InlineSpan.
  /// This allows using simple tags like <b> for bold, <i> for italic, and <u> for underline
  static List<InlineSpan> renderText(BuildContext context, String text) {
    final spans = <InlineSpan>[];

    final tagNames = _RenderableTag.values
        .map((t) => RegExp.escape(t.tag))
        .join('|');
    final pattern = RegExp('<($tagNames)(?:/>|>(.*?)</\\1>)', dotAll: true);

    var lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      // Add any plain text that appeared before this tag
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      final tagName = match.group(1)!;
      final content = match.group(2); // null for self-closing tags

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
            content == null ? const [] : renderText(context, content),
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
}
