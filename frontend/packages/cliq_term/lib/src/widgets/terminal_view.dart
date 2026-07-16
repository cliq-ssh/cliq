import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/utils/keyboard_helper.dart';
import 'package:cliq_term/src/widgets/terminal_input.dart';
import 'package:cliq_term/src/widgets/terminal_painter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class TerminalView extends StatefulWidget {
  /// The [TerminalController] used to manage the terminal state and handle input/output.
  final TerminalController controller;

  /// An optional [FocusNode] to manage focus for the terminal view.
  /// If not provided, a new [FocusNode] will be created.
  final FocusNode? focusNode;

  /// The accessory bar widget (such as [TerminalAccessoryBar]) to build.
  /// Leave null to disable the accessory bar.
  final Widget Function(BuildContext, TerminalAccessoryBarActions)?
  accessoryBarBuilder;

  /// The offset from the bottom of the screen for the accessory bar.
  final double? accessoryBarOffset;

  /// Whether the terminal view is read-only. If true, user input will be ignored.
  final bool readOnly;

  /// Whether to allow text selection in the terminal view.
  /// Usually set to false for mobile platforms.
  final bool allowTextSelection;

  /// The [KeyboardShortcut] for copying selected text from the terminal.
  final KeyboardShortcut? copyShortcut;

  /// The [KeyboardShortcut] for pasting text into the terminal.
  final KeyboardShortcut? pasteShortcut;

  /// Whether the terminal view is running on a mobile platform.
  final bool isMobile;

  const TerminalView({
    super.key,
    required this.controller,
    this.focusNode,
    this.readOnly = false,
    this.accessoryBarBuilder,
    this.accessoryBarOffset,
    this.allowTextSelection = true,
    this.copyShortcut,
    this.pasteShortcut,
    required this.isMobile,
  });

  @override
  State<TerminalView> createState() => _TerminalViewState();

  /// The height of the accessory bar displayed above the keyboard when it is visible.
  static double getAccessoryBarHeight(bool isMobile) {
    return isMobile ? 48.0 : 0.0;
  }
}

class _TerminalViewState extends State<TerminalView> {
  /// The [OverlayEntry] for the accessory bar, which is displayed above the keyboard when it is visible.
  OverlayEntry? _accessoryBarEntry;

  /// The effective [FocusNode] used for managing focus in the terminal view.
  late final FocusNode _focusNode;

  /// Whether the [FocusNode] should be disposed when the widget is disposed.
  /// This is true if the [FocusNode] was created internally (i.e., not provided by the user).
  late final bool _shouldDisposeFocusNode;

  /// The [ScrollController] used to manage scrolling in the terminal view.
  final ScrollController _scrollController = ScrollController();

  /// Whether the user has scrolled away from the bottom of the terminal view.
  bool _userScrolledAwayFromBottom = false;
  bool _isUpdatePending = false;

  /// Whether the software keyboard is currently visible.
  late final ValueNotifier<bool> _keyboardVisible = ValueNotifier(
    widget.isMobile,
  );

  final ValueNotifier<AccessoryBarButtonState> _ctrlActive = ValueNotifier(
    .inactive,
  );
  final ValueNotifier<AccessoryBarButtonState> _altActive = ValueNotifier(
    .inactive,
  );

  late final TerminalAccessoryBarActions _accessoryActions = .new(
    sendInput: _sendInput,
    keyboardVisible: _keyboardVisible,
    openKeyboard: () => _keyboardVisible.value = true,
    closeKeyboard: () => _keyboardVisible.value = false,
    ctrlActive: _ctrlActive,
    toggleCtrl: () => _ctrlActive.value = _ctrlActive.value.next,
    altActive: _altActive,
    toggleAlt: () => _altActive.value = _altActive.value.next,
  );

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
    _shouldDisposeFocusNode = widget.focusNode == null;

    widget.controller.addListener(_onUpdate);

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final maxExt = _scrollController.position.maxScrollExtent;
      final atBottom = _scrollController.offset >= (maxExt - 20);
      _userScrolledAwayFromBottom = !atBottom;
    });
  }

  @override
  void didUpdateWidget(TerminalView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onUpdate);
      widget.controller.addListener(_onUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    if (_shouldDisposeFocusNode) {
      _focusNode.dispose();
    }
    _accessoryBarEntry?.remove();
    _scrollController.dispose();
    _keyboardVisible.dispose();
    _ctrlActive.dispose();
    _altActive.dispose();
    super.dispose();
  }

  /// Sends [text] as terminal input, applying any armed one-shot
  /// modifiers (Ctrl/Alt) first, then clearing them.
  void _sendInput(String text) {
    var result = text;
    if (_ctrlActive.value.isActive && result.isNotEmpty) {
      final code = result.codeUnitAt(0) & 0x1f;
      result = String.fromCharCode(code) + result.substring(1);
      if (_ctrlActive.value == .oneShot) {
        _ctrlActive.value = .inactive;
      }
    }
    if (_altActive.value.isActive) {
      result = '$kSeqEscape$result';
      if (_altActive.value == .oneShot) {
        _altActive.value = .inactive;
      }
    }
    _scrollToBottom();
    widget.controller.clearSelection();
    widget.controller.onInput?.call(result);
  }

  void _onUpdate() {
    if (!mounted || _isUpdatePending) return;
    _isUpdatePending = true;

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isUpdatePending = false;
      if (!mounted || !_scrollController.hasClients) return;

      if (!_userScrolledAwayFromBottom) {
        final maxExt = _scrollController.position.maxScrollExtent;
        if (maxExt > 0) {
          _scrollController.jumpTo(maxExt);
        }
      }
    });
  }

  /// Scrolls the terminal view to the bottom, ensuring that the latest output is visible.
  void _scrollToBottom() {
    _userScrolledAwayFromBottom = false;
    if (!_scrollController.hasClients) return;
    final maxExt = _scrollController.position.maxScrollExtent;
    if (maxExt > 0) {
      _scrollController.jumpTo(maxExt);
    }
  }

  /// Shows the accessory bar above the keyboard when it is visible.
  void _showAccessoryBar() {
    _accessoryBarEntry?.remove();
    if (widget.accessoryBarBuilder == null) return;

    buildOverlayEntry() {
      return OverlayEntry(
        builder: (context) {
          final viewInsets = MediaQuery.of(context).viewInsets.bottom;

          return ValueListenableBuilder<bool>(
            valueListenable: _keyboardVisible,
            builder: (context, wantsKeyboard, _) {
              final restingBottom = viewInsets > 0 && wantsKeyboard
                  ? viewInsets
                  : (widget.accessoryBarOffset ?? 0.0);

              return Positioned(
                left: 0,
                right: 0,
                bottom: restingBottom,
                height: TerminalView.getAccessoryBarHeight(widget.isMobile),
                child: widget.accessoryBarBuilder!(context, _accessoryActions),
              );
            },
          );
        },
      );
    }

    _accessoryBarEntry = buildOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_accessoryBarEntry!);
  }

  int? _mouseButtonFromEvent(int buttons) {
    if (buttons & kPrimaryButton != 0) return 0;
    if (buttons & kMiddleMouseButton != 0) return 1;
    if (buttons & kSecondaryButton != 0) return 2;
    return null;
  }

  bool get _mouseReportingActive =>
      widget.controller.mouseTrackingMode != MouseTrackingMode.none &&
      !HardwareKeyboard.instance.isShiftPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // inform controller if size changed
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.controller.fitResize(constraints.biggest),
        );

        // compute char cell size
        final (cellW, cellH) = CharWidth.measureChar(
          widget.controller.typography,
        );

        final totalRows = widget.controller.totalRows;

        return TerminalInput(
          focusNode: _focusNode,
          readOnly: widget.readOnly,
          keyboardVisible: _keyboardVisible,
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              _showAccessoryBar();
              widget.controller.startCursorBlink();
            } else {
              widget.controller.stopCursorBlink();
            }
          },
          onInput: _sendInput,
          onKeyEvent: (node, event) {
            if (widget.readOnly) return .ignored;

            if (event is KeyDownEvent || event is KeyRepeatEvent) {
              if (KeyboardHelper.isModifierOnlyKey(event.logicalKey)) {
                return .handled;
              }

              if (widget.pasteShortcut?.isPressed(event) == true) {
                _scrollToBottom();
                widget.controller.clearSelection();
                Clipboard.getData(Clipboard.kTextPlain).then((clip) {
                  widget.controller.paste(clip?.text ?? '');
                });
                return .handled;
              }

              if (widget.copyShortcut?.isPressed(event) == true) {
                final selection = widget.controller.getSelectedText();
                if (selection?.isNotEmpty == true) {
                  Clipboard.setData(ClipboardData(text: selection!));
                }
                return .handled;
              }

              _scrollToBottom();
              widget.controller.clearSelection();
              widget.controller.handleKey(event);
              return .handled;
            }
            return .ignored;
          },
          child: Listener(
            onPointerDown: (event) {
              if (!_mouseReportingActive) return;
              _focusNode.requestFocus();
              final button = _mouseButtonFromEvent(event.buttons);
              if (button == null) return;
              final (row, col) = _calculateCoords(
                event.localPosition,
                cellW,
                cellH,
              );
              widget.controller.reportMouseEvent(
                row: row,
                col: col,
                button: button,
              );
            },
            onPointerUp: (event) {
              if (!_mouseReportingActive) return;
              _focusNode.requestFocus();
              final (row, col) = _calculateCoords(
                event.localPosition,
                cellW,
                cellH,
              );
              widget.controller.reportMouseEvent(
                row: row,
                col: col,
                isRelease: true,
              );
            },
            onPointerMove: (event) {
              if (!_mouseReportingActive) return;
              final (row, col) = _calculateCoords(
                event.localPosition,
                cellW,
                cellH,
              );
              widget.controller.reportMouseEvent(
                row: row,
                col: col,
                isMotion: true,
              );
            },
            onPointerSignal: (event) {
              if (event is! PointerScrollEvent) return;
              final (row, col) = _calculateCoords(
                event.localPosition,
                cellW,
                cellH,
              );
              widget.controller.handleScroll(
                row: row,
                col: col,
                up: event.scrollDelta.dy < 0,
                lines: 10,
              );
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (_mouseReportingActive) return;
                _focusNode.requestFocus();
                widget.controller.clearSelection();
              },
              onPanStart: (details) {
                _focusNode.requestFocus();
                if (!widget.allowTextSelection || _mouseReportingActive) return;
                final (absRow, absCol) = _calculateCoords(
                  details.localPosition,
                  cellW,
                  cellH,
                );
                widget.controller.startSelection(absRow, absCol);
              },
              onPanUpdate: (details) {
                if (!widget.allowTextSelection || _mouseReportingActive) return;
                final (absRow, absCol) = _calculateCoords(
                  details.localPosition,
                  cellW,
                  cellH,
                );
                widget.controller.updateSelection(absRow, absCol);
              },
              child: Container(
                color: widget.controller.theme.backgroundColor,
                child: ListView.builder(
                  scrollCacheExtent: ScrollCacheExtent.pixels(cellH * 10),
                  controller: _scrollController,
                  itemCount: totalRows,
                  itemExtent: cellH,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return TerminalRowWidget(
                      controller: widget.controller,
                      absoluteRowIndex: index,
                      cellWidth: cellW,
                      cellHeight: cellH,
                      readOnly: widget.readOnly,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  (int, int) _calculateCoords(
    Offset localPosition,
    double cellW,
    double cellH,
  ) {
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final totalLocalY = localPosition.dy + scrollOffset;

    final absRow = (totalLocalY / cellH).floor();
    final col = (localPosition.dx / cellW).floor();

    return (
      absRow.clamp(0, max(0, widget.controller.totalRows - 1)),
      col.clamp(0, widget.controller.cols - 1),
    );
  }
}

class TerminalRowWidget extends StatelessWidget {
  final TerminalController controller;
  final int absoluteRowIndex;
  final double cellWidth;
  final double cellHeight;
  final bool readOnly;

  const TerminalRowWidget({
    super.key,
    required this.controller,
    required this.absoluteRowIndex,
    required this.cellWidth,
    required this.cellHeight,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    final row = controller.activeBuffer.getAbsoluteRow(absoluteRowIndex);

    return Stack(
      children: [
        RepaintBoundary(
          child: CustomPaint(
            size: Size(controller.cols * cellWidth, cellHeight),
            painter: SingleRowPainter(
              controller: controller,
              absoluteRowIndex: absoluteRowIndex,
              cellWidth: cellWidth,
              cellHeight: cellHeight,
              readOnly: readOnly,
              rowRevision: row.revision,
              row: row,
              selection: controller.selection,
              theme: controller.theme,
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: controller.cursorBlinkNotifier,
          builder: (context, isBlinkVisible, child) {
            return CustomPaint(
              size: Size(controller.cols * cellWidth, cellHeight),
              painter: CursorPainter(
                controller: controller,
                absoluteRowIndex: absoluteRowIndex,
                cellWidth: cellWidth,
                cellHeight: cellHeight,
                readOnly: readOnly,
                isBlinkVisible: isBlinkVisible,
                cursorRow: controller.activeBuffer.cursorRow,
                cursorCol: controller.activeBuffer.cursorCol,
                scrollback: controller.activeBuffer.currentScrollback,
                cursorStyle: controller.cursor.style,
                cursorEnabled: controller.cursor.enabled,
                theme: controller.theme,
                typography: controller.typography,
              ),
            );
          },
        ),
      ],
    );
  }
}
