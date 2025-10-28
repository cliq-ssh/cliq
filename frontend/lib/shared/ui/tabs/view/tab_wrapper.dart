import 'package:cliq/shared/ui/tabs/provider/tab.provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../model/tab.model.dart';

class TabWrapper extends StatefulWidget {
  final Widget child;

  const TabWrapper({super.key, required this.child});

  @override
  State<TabWrapper> createState() => _TabWrapperState();
}

class _TabWrapperState extends State<TabWrapper> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          _TabView(),
          Expanded(child: widget.child),
        ]
    );
  }
}

class _TabView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FTheme.of(context);
    final tabs = ref.watch(tabProvider);

    buildTab(Tab tab) {
      return FBadge(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tab.title),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: theme.colors.background,
      child: Row(
        spacing: 8,
        children: [
          for (final tab in tabs.tabs) buildTab(tab),
          Icon(LucideIcons.plus)
        ],
      ),
    );
  }
}
