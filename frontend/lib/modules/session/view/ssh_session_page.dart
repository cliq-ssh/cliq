import 'dart:async';
import 'dart:convert';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/settings/extension/custom_terminal_theme.extension.dart';
import 'package:cliq/modules/settings/model/keyboard_shortcuts.model.dart';
import 'package:cliq/modules/settings/provider/terminal_theme.provider.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/ui/repeatable_button.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../../../shared/ui/navigation/navigation_shell.dart';
import '../../../shared/utils/platform_utils.dart';
import '../provider/session.provider.dart';
import 'generic_session_page.dart';

/// The padding around the terminal view in the session page.
const kShellSessionPagePadding = EdgeInsets.symmetric(
  horizontal: 8,
  vertical: 4,
);

const kBottomNavigationBarHeight = 80.0;

class SshSessionPage extends StatefulHookConsumerWidget {
  final String sessionId;
  final FocusNode? focusNode;

  const SshSessionPage({super.key, required this.sessionId, this.focusNode});

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
        .getSessionById(widget.sessionId)!;

    final resizeDebounceTimer = useState<Timer?>(null);

    final terminalController = useState<TerminalController?>(
      session.terminalController,
    );

    final defaultTerminalTypography = useStore(.defaultTerminalTypography);
    final defaultTerminalTheme = useStore(.defaultTerminalThemeId);
    final themes = ref.watch(terminalThemeProvider);

    final shortcuts = useStore(.shortcuts);

    final scrollbackSize = useStore(.sshScrollbackSize);
    final bellSound = useStore(.terminalBellSound);
    final cursorStyle = useStore(.terminalCursorStyle);
    final cursorBlinkInterval = useStore(.terminalCursorBlinkInterval);
    final cursorBlinkTimeout = useStore(.terminalCursorBlinkTimeout);

    final effectiveTerminalTheme = session.connection.getEffectiveTerminalTheme(
      themes,
      defaultTerminalTheme.value,
    );

    final isInitialResize = useState(true);
    final resizeOverlayEntry = useState<OverlayEntry?>(null);
    final resizeOverlayTimer = useState<Timer?>(null);

    getEffectiveTerminalTypography() =>
        session.connection.terminalTypographyOverride ??
        defaultTerminalTypography.value;

    buildResizeOverlay(int rows, int cols) {
      return OverlayEntry(
        builder: (context) {
          return Positioned(
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                color: context.theme.colors.background,
                padding: .all(8),
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

    buildTerminalController() {
      return TerminalController(
        theme: effectiveTerminalTheme.toTerminalTheme(),
        typography: getEffectiveTerminalTypography(),
        debugLogging: kDebugMode,
        maxScrollbackLines: scrollbackSize.value,
        onBell: () {
          if (!bellSound.value) return;
          SystemSound.play(.alert);
        },
        onTitleChange: (title) {
          if (!PlatformUtils.isDesktop) return;
          windowManager.setTitle(title);
        },
        onHyperlinkTap: (hyperlink) {
          debugPrint('Hyperlink tapped: $hyperlink');
          // TODO: handle hyperlinks?
        },
        cursorBlinkInterval: Duration(milliseconds: cursorBlinkInterval.value),
        cursorBlinkTimeout: Duration(seconds: cursorBlinkTimeout.value),
        onResize: (rows, cols, size) {
          resizeDebounceTimer.value?.cancel();
          resizeDebounceTimer.value = Timer(
            const Duration(milliseconds: 100),
            () {
              if (!mounted) return;
              final currentSession = ref
                  .read(sessionProvider.notifier)
                  .getSessionById(widget.sessionId);

              currentSession?.sshSession?.resizeTerminal(
                cols,
                rows,
                size.width.round(),
                size.height.round(),
              );
            },
          );

          if (isInitialResize.value) {
            isInitialResize.value = false;
            return;
          }

          removeOverlay() {
            resizeOverlayEntry.value?.remove();
            resizeOverlayEntry.value = null;
          }

          if (resizeOverlayEntry.value != null) {
            removeOverlay();
          }

          resizeOverlayEntry.value = buildResizeOverlay(rows, cols);
          Overlay.of(context).insert(resizeOverlayEntry.value!);

          resizeOverlayTimer.value?.cancel();
          resizeOverlayTimer.value = Timer(
            const .new(milliseconds: 500),
            removeOverlay,
          );
        },
      );
    }

    retrySession({bool skipHostKeyVerification = false}) {
      ref
          .read(sessionProvider.notifier)
          .resetSession(
            NavigationShell.of(context),
            session.id,
            skipHostKeyVerification: skipHostKeyVerification,
          );
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
      if (terminalController.value != null) return null;
      terminalController.value = buildTerminalController();
      return null;
    }, []);

    // open SSH connection when terminal controller is set
    useEffect(() {
      if (terminalController.value == null) return null;

      Future<void> openSsh(ConnectionFull connection) async {
        if (terminalController.value == null) return;

        final client =
            session.client ??
            await ref
                .read(sessionProvider.notifier)
                .createSSHClient(session, connection);

        if (client == null || !mounted) {
          return;
        }

        final sshSession = await ref
            .read(sessionProvider.notifier)
            .spawnSsh(session.id, client, terminalController.value!);

        if (sshSession == null) return;

        // close SSH session when terminal is closed
        sshSession.done.then((_) {
          if (!context.mounted) return;
          ref
              .read(sessionProvider.notifier)
              .closeSessionAndMaybeGo(NavigationShell.of(context), session.id);
        });

        terminalController.value!.onInput = (s) {
          sshSession.write(Uint8List.fromList(s.codeUnits));
        };

        StreamSubscription? stdoutSub;
        StreamSubscription? stderrSub;

        // Terminal backpressure handling
        terminalController.value!.onPause = () {
          // We only need to pause stdout as stdout & stderr share one stream
          stdoutSub?.pause();
        };

        terminalController.value!.onResume = () {
          // We only need to resume stdout as stdout & stderr share one stream
          stdoutSub?.resume();
        };

        stdoutSub =
            session.stdoutSub ??
            const Utf8Decoder(
              allowMalformed: true,
            ).bind(sshSession.stdout).listen((str) {
              terminalController.value?.feed(str);
            });

        stderrSub =
            session.stderrSub ??
            const Utf8Decoder(
              allowMalformed: true,
            ).bind(sshSession.stderr).listen((str) {
              terminalController.value?.feed(str);
            });

        ref
            .read(sessionProvider.notifier)
            .setStreamListeners(session.id, stdoutSub, stderrSub);
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

          terminalController.value!.setTerminalTypography(
            getEffectiveTerminalTypography(),
          );
          terminalController.value!.setTerminalTheme(
            effectiveTerminalTheme.toTerminalTheme(),
          );
          terminalController.value!.setCursorStyle(cursorStyle.value);
          terminalController.value!.setCursorBlinkInterval(
            Duration(milliseconds: cursorBlinkInterval.value),
          );
          terminalController.value!.setCursorBlinkTimeout(
            Duration(seconds: cursorBlinkTimeout.value),
          );
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

    buildAccessoryButton(
      VoidCallback onPress, {
      String? text,
      IconData? icon,
      FButtonVariant? variant,
      bool repeatable = false,
    }) {
      assert(
        text != null || icon != null,
        'Either text or icon must be provided',
      );
      Widget child = FButton.icon(
        variant: variant ?? .outline,
        onPress: repeatable ? () {} : onPress,
        child: text == null
            ? Icon(icon!, size: 16)
            : Text(
                text,
                style: .new().copyWith(fontSize: 12, fontWeight: .bold),
              ),
      );

      if (repeatable) {
        child = RepeatableButton(onPress: onPress, child: child);
      }

      return child;
    }

    getButtonVariantForState(AccessoryBarButtonState state) {
      return switch (state) {
        .inactive => FButtonVariant.outline,
        .oneShot => FButtonVariant.secondary,
        .active => FButtonVariant.primary,
      };
    }

    buildAccessoryBar() {
      if (PlatformUtils.isDesktop) return null;

      return (_, TerminalAccessoryBarActions actions) {
        return TerminalAccessoryBar(
          backgroundColor: effectiveTerminalTheme.backgroundColor,
          padding: .symmetric(horizontal: 8, vertical: 4),
          items: [
            buildAccessoryButton(
              () => actions.sendInput(kSeqEscape),
              text: 'ESC',
            ),
            buildAccessoryButton(() => actions.sendInput(kSeqTab), text: 'TAB'),
            ValueListenableBuilder(
              valueListenable: actions.ctrlActive,
              builder: (_, value, _) {
                return buildAccessoryButton(
                  () => actions.toggleCtrl(),
                  text: 'CTRL',
                  variant: getButtonVariantForState(value),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: actions.altActive,
              builder: (_, value, _) {
                return buildAccessoryButton(
                  () => actions.toggleAlt(),
                  text: 'ALT',
                  variant: getButtonVariantForState(value),
                );
              },
            ),

            buildAccessoryButton(
              () => actions.sendInput(kSeqCursorUp),
              icon: LucideIcons.arrowUp,
              repeatable: true,
            ),
            buildAccessoryButton(
              () => actions.sendInput(kSeqCursorDown),
              icon: LucideIcons.arrowDown,
              repeatable: true,
            ),
            buildAccessoryButton(
              () => actions.sendInput(kSeqCursorLeft),
              icon: LucideIcons.arrowLeft,
              repeatable: true,
            ),
            buildAccessoryButton(
              () => actions.sendInput(kSeqCursorRight),
              icon: LucideIcons.arrowRight,
              repeatable: true,
            ),
          ],
          suffixItem: buildAccessoryButton(
            () => actions.toggleKeyboard(),
            icon: actions.keyboardVisible.value
                ? LucideIcons.keyboardOff
                : LucideIcons.keyboard,
          ),
        );
      };
    }

    final rawKeyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final adjustedKeyboardInset = PlatformUtils.isMobile
        ? (rawKeyboardInset - kBottomNavigationBarHeight).clamp(
            0.0,
            double.infinity,
          )
        : rawKeyboardInset;

    return GenericSessionPage(
      session: session,
      isConnected: session.isConnected && terminalController.value != null,
      isLikelyLoading: session.isLikelyLoading,
      onRetry: retrySession,
      child: SizedBox.expand(
        child: Container(
          color: effectiveTerminalTheme.backgroundColor,
          padding: kShellSessionPagePadding.copyWith(
            bottom:
                kShellSessionPagePadding.bottom +
                adjustedKeyboardInset +
                TerminalView.getAccessoryBarHeight(PlatformUtils.isMobile),
          ),
          child: TerminalView(
            controller: terminalController.value!,
            focusNode: widget.focusNode,
            accessoryBarBuilder: buildAccessoryBar(),
            accessoryBarOffset: kBottomNavigationBarHeight,
            allowTextSelection: PlatformUtils.isDesktop,
            copyShortcut: shortcuts.value.shortcuts[KeyboardShortcutType.copy],
            pasteShortcut:
                shortcuts.value.shortcuts[KeyboardShortcutType.paste],
            isMobile: PlatformUtils.isMobile,
          ),
        ),
      ),
    );
  }
}
