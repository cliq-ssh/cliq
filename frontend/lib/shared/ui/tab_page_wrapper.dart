import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/provider/tab.provider.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

class const TabPageWrapper({super.key}) extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@tabs');

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TabPageWrapperState();
}

class TabPageWrapperState extends ConsumerState<TabPageWrapper> {
  @override
  Widget build(BuildContext context) {
    final win = MultiViewDesktop.of(context);

    final tabs = ref.watch(tabProvider);
    final windowTabs = tabs.getTabsByWindowId(win.id);
    final pageController = usePageController();

    final selectedTabId = tabs.getSelectedTabIdByWindowId(win.id);

    // jump to page once selected
    useEffect(() {
      if (!context.mounted) return;

      if (selectedTabId == null) {
        if (windowTabs.isEmpty) {
          NavigationShell.of(context).goToDashboardBranch();
        } else {
          ref
              .read(tabProvider.notifier)
              .select(NavigationShell.of(context), win.id, windowTabs.last.id);
        }
        return;
      }

      final selectedIndex = windowTabs.indexWhere(
        (tab) => tab.id == selectedTabId,
      );

      if (selectedIndex >= 0 && pageController.hasClients) {
        pageController.jumpToPage(selectedIndex);
      }

      return null;
    }, [tabs.tabs, tabs.selectedTabs]);

    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final tab in windowTabs)
          KeyedSubtree(
            key: ValueKey(tab.id),
            child: tab.getEffectiveContent(context),
          ),
      ],
    );
  }
}
