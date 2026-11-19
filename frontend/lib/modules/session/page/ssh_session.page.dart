import 'dart:async';

import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/session/hook/use_ssh_session.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/page/generic_session.page.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/modules/settings/extension/custom_terminal_theme.extension.dart';
import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:cliq/shared/model/tab.model.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/provider/tab.provider.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:flterm/flterm.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart' hide LicensePage, Tab;
import 'package:multiview_desktop/multiview_desktop.dart';

/// The padding around the terminal view in the session page.
const kShellSessionPagePadding = EdgeInsets.symmetric(
  horizontal: 8,
  vertical: 4,
);

const kBottomNavigationBarHeight = 80.0;

class const SshSessionPage({
  super.key,
  required final Tab tab,
  required final String sessionId,
}) extends StatefulHookConsumerWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SshSessionPageState();
}

class _SshSessionPageState extends ConsumerState<SshSessionPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final win = MultiViewDesktop.of(context);
    final session = useSshSession(ref, widget.sessionId);

    final focusedTab = ref
        .watch(tabProvider)
        .getSelectedTabIdByWindowId(win.id);
    final focusNode = useFocusNode();

    final defaultTerminalTheme = useStore(.defaultTerminalThemeId);
    final themes = ref.watch(terminalThemeProvider);
    final scrollbackSize = useStore(.sshScrollbackSize);
    final bellSound = useStore(.terminalBellSound);

    final attempt = useState(0);

    final isInitialResize = useRef(true);
    final resizeOverlayEntry = useRef<OverlayEntry?>(null);
    final resizeOverlayTimer = useRef<Timer?>(null);

    buildResizeOverlay(int rows, int cols) {
      return OverlayEntry(
        builder: (context) => Positioned(
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              color: context.theme.colors.background,
              padding: const .all(8),
              child: Text(
                '$cols x $rows',
                style: context.theme.typography.body.md,
              ),
            ),
          ),
        ),
      );
    }

    buildTerminalController() {
      final controller = TerminalController(
        config: .new(scrollbackMaxLines: scrollbackSize.value),
      );

      controller.onBell = () async {
        if (!bellSound.value) return;
        await SystemSound.play(.alert);
      };

      controller.onTitleChanged = () {
        if (!PlatformUtils.isDesktop) return;
        // final title = controller.title;
        // TODO: set window title
      };

      controller.onResize = (cols, rows) {
        ref
            .read(sessionProvider.notifier)
            .findById(widget.sessionId)
            ?.resources
            ?.ssh
            ?.resize(cols, rows);

        if (isInitialResize.value) {
          isInitialResize.value = false;
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          resizeOverlayEntry.value?.remove();
          resizeOverlayEntry.value = buildResizeOverlay(rows, cols);
          Overlay.of(context).insert(resizeOverlayEntry.value!);

          resizeOverlayTimer.value?.cancel();
          resizeOverlayTimer.value = Timer(
            const Duration(milliseconds: 500),
            () {
              if (!mounted) return;
              resizeOverlayEntry.value?.remove();
              resizeOverlayEntry.value = null;
            },
          );
        });
      };

      return controller;
    }

    retrySession({bool skipHostKeyVerification = false}) {
      isInitialResize.value = true;
      ref
          .read(sessionProvider.notifier)
          .reset(
            widget.sessionId,
            skipHostKeyVerification: skipHostKeyVerification,
          );
      attempt.value++;
    }

    // focus terminal when tab is opened
    useEffect(() {
      if (focusedTab != widget.tab.id) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });
      return null;
    }, [focusedTab]);

    // (re)connect whenever a new attempt starts
    useEffect(() {
      bool cancelled = false;

      Future<void> open() async {
        final notifier = ref.read(sessionProvider.notifier);
        final current = notifier.findById(widget.sessionId);
        // already connected
        if (current == null || current.status is! SessionConnecting) return;

        final connection =
            ref
                .read(connectionProvider.notifier)
                .findById(current.connection.id) ??
            current.connection;

        final controller = buildTerminalController();
        final worker = await notifier.connectSsh(
          current,
          connection,
          controller,
          onExit: () {
            if (!mounted) return;
            ref.read(tabProvider.notifier).close(widget.tab.id);
          },
        );

        if (worker == null) {
          controller.dispose();
          return;
        }
        controller.onOutput = worker.write;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!cancelled && mounted) open();
      });
      return () => cancelled = true;
    }, [attempt.value]);

    if (session == null) return const SizedBox.shrink();

    final effectiveTerminalTheme = session.connection.getEffectiveTerminalTheme(
      themes,
      defaultTerminalTheme.value,
    );

    return GenericSessionPage(
      session: session,
      tabId: widget.tab.id,
      onRetry: retrySession,
      builder: (context) {
        final controller = session.resources?.terminalController;
        if (controller == null) return const SizedBox.shrink();

        return SizedBox.expand(
          child: ColoredBox(
            color: effectiveTerminalTheme.background,
            child: TerminalView(
              autofocus: true,
              controller: controller,
              focusNode: focusNode,
              theme: effectiveTerminalTheme.toTerminalTheme(),
            ),
          ),
        );
      },
    );
  }
}
