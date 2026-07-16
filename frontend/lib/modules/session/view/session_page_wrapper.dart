import 'package:cliq/modules/session/model/tab.model.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/modules/session/ui/session_title_bar.dart';
import 'package:cliq/modules/session/view/sftp_session_page.dart';
import 'package:cliq/modules/session/view/ssh_session_page.dart';
import 'package:cliq/shared/ui/hover_builder.dart';
import 'package:cliq/shared/ui/navigation/navigation_shell.dart';
import 'package:cliq/shared/ui/split_view.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
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
  final Map<String, SplitNode<ShellSession>> _pageMap = {};

  /// Checks if the given session ID is present in the node tree.
  bool _containsSessionId(SplitNode<ShellSession> node, String id) =>
      switch (node) {
        SplitLeaf<ShellSession>(:final value) => value.id == id,
        SplitBranch<ShellSession>(:final first, :final second) =>
          _containsSessionId(first, id) || _containsSessionId(second, id),
      };

  /// Builds a [SplitLeaf] widget for the given [ShellSession].
  SplitLeaf<ShellSession> _buildLeaf(ShellSession s, {required bool isSingle}) {
    late final SplitLeaf<ShellSession> leaf;
    leaf = SplitLeaf(
      value: s,
      builder: (context, focus) {
        return switch (s.type) {
          .ssh => SshSessionPage(
            key: leaf.pageKey,
            sessionId: s.id,
            focusNode: focus,
          ),
          .sftp => SftpSessionPage(key: leaf.pageKey, sessionId: s.id),
        };
      },
    );
    return leaf;
  }

  /// Replaces the target leaf node with the replacement node in the given tree.
  SplitNode<ShellSession> _replaceLeaf(
    SplitNode<ShellSession> node,
    SplitLeaf<ShellSession> target,
    SplitNode<ShellSession> replacement,
  ) {
    if (identical(node, target)) return replacement;
    if (node is SplitBranch<ShellSession>) {
      node.first = _replaceLeaf(node.first, target, replacement);
      node.second = _replaceLeaf(node.second, target, replacement);
    }
    return node;
  }

  /// Removes leaves whose session ID is no longer active.
  /// If a branch loses one child, the other side collapses up.
  SplitNode<ShellSession>? _removeFromTree(
    SplitNode<ShellSession> node,
    Set<String> activeIds,
  ) {
    if (node is SplitLeaf<ShellSession>) {
      return activeIds.contains(node.value.id) ? node : null;
    }
    if (node is SplitBranch<ShellSession>) {
      final newFirst = _removeFromTree(node.first, activeIds);
      final newSecond = _removeFromTree(node.second, activeIds);
      if (newFirst == null) return newSecond;
      if (newSecond == null) return newFirst;
      node.first = newFirst;
      node.second = newSecond;
    }
    return node;
  }

  /// Synchronizes the page map with the list of active sessions.
  void _syncPageMap(List<SessionTab> activeTabs) {
    // add new sessions
    for (final tab in activeTabs) {
      _pageMap[tab.id] ??= _buildLeaf(tab.root, isSingle: tab.sessions.isEmpty);
    }

    // collect every active session ID across all tabs
    final activeSessionIds = activeTabs
        .expand((tab) => [...tab.sessions, tab.root].map((s) => s.id))
        .toSet();

    // prune closed sessions from within split trees
    for (final tabId in _pageMap.keys.toList()) {
      final pruned = _removeFromTree(_pageMap[tabId]!, activeSessionIds);
      if (pruned == null) {
        _pageMap.remove(tabId);
      } else {
        _pageMap[tabId] = pruned;
      }
    }

    // remove closed tabs
    final activeTabIds = activeTabs.map((t) => t.id).toSet();
    _pageMap.removeWhere((id, node) {
      if (!activeTabIds.contains(id)) {
        node.dispose();
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    for (final node in _pageMap.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final pageController = usePageController();

    useEffect(() {
      _syncPageMap(session.activeTabs);
      return null;
    }, [session.activeTabs]);

    useEffect(() {
      if (pageController.hasClients && session.selectedTabId != null) {
        pageController.jumpToPage(session.selectedTabPageIndex!);
      }
      return null;
    }, [session.selectedTabId]);

    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final tab in session.activeTabs)
          SplitView<ShellSession>(
            root: _pageMap[tab.id]!,
            canDrop: (target, dropped) {
              if (dropped.id == target.value.id) return false;
              // dont allow adding an existing session to its own tree
              return !_containsSessionId(_pageMap[tab.id]!, dropped.id);
            },
            onDrop: (target, dropped, direction, isFirst) {
              setState(() {
                _pageMap[tab.id] = _replaceLeaf(
                  _pageMap[tab.id]!,
                  target,
                  SplitBranch<ShellSession>(
                    direction: direction,
                    first: isFirst
                        ? _buildLeaf(dropped, isSingle: false)
                        : target,
                    second: isFirst
                        ? target
                        : _buildLeaf(dropped, isSingle: false),
                  ),
                );

                // add to tab
                ref
                    .read(sessionProvider.notifier)
                    .merge(NavigationShell.of(context), tab.id, dropped);
              });
            },
            borderColor: context.theme.colors.border,
            focusedBorderColor: context.theme.colors.primary,
            nodeBuilder: (context, leaf, child) {
              // hide title bar for only one session
              if (_pageMap[tab.id] is SplitLeaf<ShellSession>) {
                return child;
              }

              return HoverBuilder(
                builder: (_, hovered) => Column(
                  children: [
                    SessionTitleBar(sessionId: leaf.value.id, hovered: hovered),
                    Expanded(child: child),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
