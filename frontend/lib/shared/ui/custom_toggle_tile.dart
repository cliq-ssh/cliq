import 'package:cliq/shared/data/store.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';

/// Small wrapper around [FTile] that handles our pretty common
/// settings toggles.
/// This also sets the overflow of [title] and [subtitle] to visible, because only
/// then the text seems to get wrapped.
class CustomToggleTile extends StatelessWidget with FTileMixin {
  /// The title translation key of the tile.
  final String title;

  /// The subtitle translation key of the tile. Optional.
  final String? subtitle;

  /// The arguments for the subtitle translation. Optional.
  final List<String>? subtitleArgs;

  /// The prefix widget of the tile. Usually an icon.
  final Widget prefix;

  /// The [StoreKey] that will be used to write the value of the toggle.
  final StoreKey<bool> storeKey;

  /// The current value of the toggle.
  final bool value;

  const CustomToggleTile({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleArgs,
    required this.prefix,
    required this.storeKey,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return FTile(
      title: Text(title.tr(), overflow: .visible),
      subtitle: subtitle != null
          ? Text(subtitle!.tr(args: subtitleArgs ?? []), overflow: .visible)
          : null,
      prefix: prefix,
      suffix: FSwitch(value: value, onChange: (value) => storeKey.write(value)),
    );
  }
}
