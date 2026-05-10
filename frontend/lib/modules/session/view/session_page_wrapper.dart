import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/modules/session/view/session_page.dart';
import 'package:cliq/shared/ui/split_view.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/model/page_path.model.dart';
import '../model/session.model.dart';

class SessionPageWrapper extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@session');

  const SessionPageWrapper({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SessionPageState();
}

class _SessionPageState extends ConsumerState<SessionPageWrapper> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final pageController = usePageController();
    final pageMap = useState<Map<int, SplitViewItem<ShellSession>>>({});

    SplitViewItem<ShellSession> buildItem(ShellSession s, int pageIndex) {
      return SplitViewItem<ShellSession>(
        builder: (_, focus) => ShellSessionPage(
          key: PageStorageKey('session-${s.id}'),
          session: s,
          focusNode: focus,
        ),
        onDrop: (targetItem, droppedSession, direction, topOrLeft) {
          final newChild = buildItem(droppedSession, pageIndex);

          SplitViewItem<ShellSession> replaceInTree(SplitViewItem<ShellSession> node) {
            if (identical(node, targetItem)) {
              return node.copyWith(split: (direction, topOrLeft, newChild));
            }
            if (node.split != null) {
              final replaced = replaceInTree(node.split!.$3);
              if (!identical(replaced, node.split!.$3)) {
                return node.copyWith(
                  split: (node.split!.$1, node.split!.$2, replaced),
                );
              }
            }
            return node;
          }

          pageMap.value = {
            ...pageMap.value,
            pageIndex: replaceInTree(pageMap.value[pageIndex]!),
          };
        },
      );
    }

    useEffect(() {
      if (pageController.hasClients && session.selectedSessionId != null) {
        pageController.jumpToPage(session.selectedSessionPageIndex!);
      }
      return null;
    }, [session.selectedSessionId]);

    useEffect(() {
      final newPageMap = <int, SplitViewItem<ShellSession>>{};
      for (int i = 0; i < session.activeSessions.length; i++) {
        // preserve existing split trees for sessions that are still active
        newPageMap[i] = pageMap.value[i] ?? buildItem(session.activeSessions[i], i);
      }
      pageMap.value = newPageMap;
      return null;
    }, [session.activeSessions]);

    return PageView(
      controller: pageController,
      children: [
        for (int i = 0; i < session.activeSessions.length; i++)
          if (pageMap.value.containsKey(i))
            SplitView<ShellSession>(parent: pageMap.value[i]!),
      ],
    );
  }
}
