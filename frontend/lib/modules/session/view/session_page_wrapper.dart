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
  final Map<String, SplitNode<ShellSession>> _pageMap = {};

  /// Checks if the given session ID is present in the node tree.
  bool _containsSessionId(SplitNode<ShellSession> node, String id) =>
      switch (node) {
        SplitLeaf<ShellSession>(:final value) => value.id == id,
        SplitBranch<ShellSession>(:final first, :final second) =>
          _containsSessionId(first, id) || _containsSessionId(second, id),
      };

  /// Builds a [SplitLeaf] widget for the given [ShellSession].
  SplitLeaf<ShellSession> _buildLeaf(ShellSession s) => SplitLeaf(
    value: s,
    builder: (_, focus) => ShellSessionPage(
      key: ValueKey('session-${s.id}'),
      sessionId: s.id,
      focusNode: focus,
    ),
  );

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

  /// Synchronizes the page map with the list of active sessions.
  void _syncPageMap(List<ShellSession> activeSessions) {
    // add new sessions
    for (final s in activeSessions) {
      _pageMap[s.id] ??= _buildLeaf(s);
    }
    // remove closed sessions
    final activeIds = activeSessions.map((s) => s.id).toSet();
    _pageMap.removeWhere((id, node) {
      if (!activeIds.contains(id)) {
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
      _syncPageMap(session.activeSessions);
      return null;
    }, [session.activeSessions]);

    useEffect(() {
      if (pageController.hasClients && session.selectedSessionId != null) {
        pageController.jumpToPage(session.selectedSessionPageIndex!);
      }
      return null;
    }, [session.selectedSessionId]);

    return PageView(
      controller: pageController,
      children: [
        for (final s in session.activeSessions)
          SplitView<ShellSession>(
            root: _pageMap[s.id]!,
            canDrop: (target, dropped) {
              if (dropped.id == target.value.id) return false;
              // dont allow adding an existing session to its own tree
              return !_containsSessionId(_pageMap[s.id]!, dropped.id);
            },
            onDrop: (target, dropped, direction, isFirst) {
              setState(() {
                _pageMap[s.id] = _replaceLeaf(
                  _pageMap[s.id]!,
                  target,
                  SplitBranch<ShellSession>(
                    direction: direction,
                    first: isFirst ? _buildLeaf(dropped) : target,
                    second: isFirst ? target : _buildLeaf(dropped),
                  ),
                );
              });
            },
          ),
      ],
    );
  }
}
