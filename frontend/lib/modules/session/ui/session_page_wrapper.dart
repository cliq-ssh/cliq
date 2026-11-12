import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/page/sftp_session.page.dart';
import 'package:cliq/modules/session/page/ssh_session.page.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart' hide LicensePage;

class const SessionPageWrapper({super.key}) extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@session');

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SessionPageState();
}

class _SessionPageState extends ConsumerState<SessionPageWrapper> {
  final Map<String, ShellSession> _pageMap = {};

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
      final Map<String, ShellSession> newPageMap = {};
      for (final session in session.sessions) {
        newPageMap[session.id] = session;
      }

      // dispose of any sessions that are no longer in the list
      for (final id in _pageMap.keys) {
        if (!newPageMap.containsKey(id)) {
          _pageMap[id]?.dispose();
        }
      }

      _pageMap
        ..clear()
        ..addAll(newPageMap);
      return null;
    }, [session.sessions]);

    buildSessionPage(ShellSession session) {
      return switch (session.type) {
        .ssh => SshSessionPage(sessionId: session.id),
        .sftp => SftpSessionPage(sessionId: session.id),
      };
    }

    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: session.sessions.map(buildSessionPage).toList(),
    );
  }
}
