import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/modules/session/view/session_page.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/model/page_path.model.dart';

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

    useEffect(() {
      if (pageController.hasClients && session.selectedSessionId != null) {
        pageController.jumpToPage(session.selectedSessionPageIndex!);
      }
      return null;
    }, [session.selectedSessionId]);

    return PageView(
      key: PageStorageKey('session_page_wrapper'),
      controller: pageController,
      children: [
        for (final session in session.activeSessions)
          ShellSessionPage(
            key: ValueKey('session-${session.effectiveName}--${session.id}'),
            session: session,
          ),
      ],
    );
  }
}
