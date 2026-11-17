import 'package:cliq/modules/session/provider/tab.provider.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:multiview_desktop/multiview_desktop.dart';

class const TabPageWrapper({super.key}) extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@tabs');

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SessionPageState();
}

class _SessionPageState extends ConsumerState<TabPageWrapper> {
  @override
  Widget build(BuildContext context) {
    final win = MultiViewDesktop.of(context);

    final tabs = ref.watch(tabProvider);
    final children = useState<Map<String, Widget>>({});

    final pageController = usePageController();

    // build pages
    useEffect(() {
      final Map<String, Widget> newChildren = {};
      for (final tab in tabs.getTabsByWindowId(win.id)) {
        newChildren[tab.id] = tab.getEffectiveContent(context);
      }
      children.value = newChildren;
      return null;
    }, [tabs.tabs]);

    // jump to page once selected
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final selectedTabId = tabs.getSelectedTabIdByWindowId(win.id);
        if (selectedTabId == null) {
          // focus next/last tab
          final nextTabs = tabs.getTabsByWindowId(win.id);
          if (nextTabs.isEmpty) {
            NavigationShell.of(context).goToDashboardBranch();
          } else {
            ref
                .read(tabProvider.notifier)
                .select(NavigationShell.of(context), win.id, nextTabs.last.id);
          }
          return;
        }
        pageController.jumpToPage(
          children.value.keys.toList().indexOf(selectedTabId),
        );
      });
      return null;
    }, [tabs.selectedTabs]);

    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: children.value.values.toList(),
    );
  }
}
