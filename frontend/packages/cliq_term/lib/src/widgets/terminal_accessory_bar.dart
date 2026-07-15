import 'package:flutter/cupertino.dart';

class TerminalAccessoryBar extends StatelessWidget {
  /// The list of items to display in the accessory bar.
  final List<Widget> items;

  /// An optional suffix item that is always displayed at the end of the accessory bar, regardless of the number of items.
  final Widget? suffixItem;

  /// The background color of the accessory bar.
  final Color? backgroundColor;

  /// The padding of the accessory bar.
  final EdgeInsetsGeometry? padding;

  const TerminalAccessoryBar({
    super.key,
    required this.items,
    this.suffixItem,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final item = items[index];
                return Semantics(excludeSemantics: true, child: item);
              },
            ),
          ),
          ?suffixItem,
        ],
      ),
    );
  }
}
