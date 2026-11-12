import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/session/page/generic_session.page.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:flterm/flterm.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart' hide LicensePage;

/// The padding around the terminal view in the session page.
const kShellSessionPagePadding = EdgeInsets.symmetric(
  horizontal: 8,
  vertical: 4,
);

const kBottomNavigationBarHeight = 80.0;

class SshSessionPage extends StatefulHookConsumerWidget {
  final String sessionId;
  final FocusNode? focusNode;

  const new({super.key, required this.sessionId, this.focusNode});

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

    final session = ref
        .watch(sessionProvider.notifier)
        .findById(widget.sessionId)!;

    final terminalController = useState<TerminalController?>(
      session.terminalController,
    );

    final defaultTerminalTypography = useStore(.defaultTerminalTypography);
    final defaultTerminalTheme = useStore(.defaultTerminalThemeId);
    final themes = ref.watch(terminalThemeProvider);

    final scrollbackSize = useStore(.sshScrollbackSize);
    final bellSound = useStore(.terminalBellSound);
    final cursorStyle = useStore(.terminalCursorStyle);
    final cursorBlinkInterval = useStore(.terminalCursorBlinkInterval);
    final cursorBlinkTimeout = useStore(.terminalCursorBlinkTimeout);

    final effectiveTerminalTheme = session.connection.getEffectiveTerminalTheme(
      themes,
      defaultTerminalTheme.value,
    );

    final isInitialResize = useRef(true);
    final resizeOverlayEntry = useRef<OverlayEntry?>(null);
    final resizeOverlayTimer = useRef<Timer?>(null);

    buildResizeOverlay(int rows, int cols) {
      return OverlayEntry(
        builder: (context) {
          return Positioned(
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
          );
        },
      );
    }

    void rebindTerminalControllerCallbacks(TerminalController controller) {
      controller.onBell = () async {
        if (!bellSound.value) return;
        await SystemSound.play(.alert);
      };

      controller.onTitleChanged = () {
        if (!PlatformUtils.isDesktop) return;
        final title = controller.title;
        // TODO: set window title
        ref
            .read(sessionProvider.notifier)
            .rename(session.id, title, userChangedTitle: false);
      };

      controller.onResize = (cols, rows) {
        ref
            .read(sessionProvider.notifier)
            .findById(widget.sessionId)
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
    }

    buildTerminalController() {
      final controller = TerminalController(
        config: .new(scrollbackMaxLines: scrollbackSize.value),
      );
      rebindTerminalControllerCallbacks(controller);
      return controller;
    }

    retrySession({bool skipHostKeyVerification = false}) {
      ref
          .read(sessionProvider.notifier)
          .reset(session.id, skipHostKeyVerification: skipHostKeyVerification);
      terminalController.value = buildTerminalController();
    }

    // focus terminal when page is opened
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.focusNode?.requestFocus();
      });
      return null;
    }, []);

    // initial setup of terminal controller
    useEffect(() {
      if (terminalController.value == null) {
        terminalController.value = buildTerminalController();
      } else {
        rebindTerminalControllerCallbacks(terminalController.value!);
      }
      return null;
    }, []);

    // open SSH connection when terminal controller is set
    useEffect(() {
      if (terminalController.value == null) return null;

      Future<void> openSsh(ConnectionFull connection) async {
        if (!mounted || terminalController.value == null) return;
        final notifier = ref.read(sessionProvider.notifier);

        // reuse the worker if the session is already connected (page was rebuilt)
        final worker =
            session.ssh ??
            await notifier.connectSsh(
              session,
              connection,
              terminalController.value!,
              onExit: () {
                if (!context.mounted) return;
                notifier.remove(session.id);
              },
            );
        if (worker == null || !mounted) return;

        // always rebind, also when the worker already existed
        terminalController.value!.onOutput = worker.write;
      }

      final connectionFull = ref
          .read(connectionProvider.notifier)
          .findById(session.connection.id);

      if (connectionFull != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          openSsh(connectionFull);
        });
      }

      return null;
    }, [terminalController.value]);

    // update terminal controller when typography or theme changes
    useEffect(
      () {
        if (terminalController.value == null) return null;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
        });

        return null;
      },
      [
        defaultTerminalTypography.value,
        defaultTerminalTheme.value,
        cursorStyle.value,
        cursorBlinkInterval.value,
        cursorBlinkTimeout.value,
      ],
    );

    return GenericSessionPage(
      session: session,
      isConnected: session.isConnected && terminalController.value != null,
      isLikelyLoading: session.isLikelyLoading,
      onRetry: retrySession,
      child: SizedBox.expand(
        child: ColoredBox(
          color: effectiveTerminalTheme.background,
          child: TerminalView(
            controller: terminalController.value!,
            focusNode: widget.focusNode,
            // TODO: theming
          ),
        ),
      ),
    );
  }
}
