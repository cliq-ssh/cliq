import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/utils/gesture_selection_handler.dart';
import 'package:cliq_term/src/utils/keyboard_helper.dart';
import 'package:cliq_term/src/widgets/terminal_input.dart';
import 'package:cliq_term/src/widgets/terminal_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The height of the accessory bar displayed above the keyboard when it is visible.
const kAccessoryBarHeight = 48.0;

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

  /// The [KeyboardShortcut] for copying selected text from the terminal.
  final KeyboardShortcut? copyShortcut;

  /// The [KeyboardShortcut] for pasting text into the terminal.
  final KeyboardShortcut? pasteShortcut;

  const TerminalView({
    super.key,
    required this.controller,
    this.focusNode,
    this.readOnly = false,
    this.accessoryBarBuilder,
    this.accessoryBarOffset,
    this.copyShortcut,
    this.pasteShortcut,
  });

  @override
  State<TerminalView> createState() => _TerminalViewState();
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

  /// Whether the software keyboard is currently visible.
  final ValueNotifier<bool> _keyboardVisible = ValueNotifier(true);

  final ValueNotifier<bool> _ctrlActive = ValueNotifier(false);
  final ValueNotifier<bool> _altActive = ValueNotifier(false);

  late final TerminalAccessoryBarActions _accessoryActions = .new(
    sendInput: _sendInput,
    keyboardVisible: _keyboardVisible,
    openKeyboard: () => _keyboardVisible.value = true,
    closeKeyboard: () => _keyboardVisible.value = false,
    ctrlActive: _ctrlActive,
    toggleCtrl: () => _ctrlActive.value = !_ctrlActive.value,
    altActive: _altActive,
    toggleAlt: () => _altActive.value = !_altActive.value,
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
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    if (_shouldDisposeFocusNode) {
      _focusNode.dispose();
    }
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
    if (_ctrlActive.value && result.isNotEmpty) {
      final code = result.codeUnitAt(0) & 0x1f;
      result = String.fromCharCode(code) + result.substring(1);
      _ctrlActive.value = false;
    }
    if (_altActive.value) {
      result = '$kSeqEscape$result';
      _altActive.value = false;
    }
    _scrollToBottom();
    widget.controller.clearSelection();
    widget.controller.onInput?.call(result);
  }

  void _onUpdate() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (_userScrolledAwayFromBottom) {
        return; // user is viewing history; don't yank them
      }
      // jump to bottom
      final maxExt = _scrollController.position.maxScrollExtent;
      if (maxExt > 0) {
        _scrollController.jumpTo(maxExt);
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
                height: kAccessoryBarHeight,
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // inform controller if size changed
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.controller.fitResize(constraints.biggest),
        );

        // compute char cell size to compute overall canvas size
        final (cellW, cellH) = TerminalPainter.measureChar(
          widget.controller.typography,
        );

        // total rows available in front buffer (visible + scrollback)
        final totalRows = widget.controller.totalRows;
        final totalCols = widget.controller.cols;

        final canvasWidth = (totalCols > 0)
            ? totalCols * cellW
            : constraints.maxWidth;
        final canvasHeight = (totalRows > 0)
            ? totalRows * cellH
            : constraints.maxHeight;

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
            if (widget.readOnly) {
              return .ignored;
            }

            if (event is KeyDownEvent || event is KeyRepeatEvent) {
              // Do not clear selection on modifier-only key presses.
              if (KeyboardHelper.isModifierOnlyKey(event.logicalKey)) {
                return .handled;
              }

              if (widget.pasteShortcut?.isPressed(event) == true) {
                _scrollToBottom();
                widget.controller.clearSelection();
                Clipboard.getData(Clipboard.kTextPlain).then((clip) {
                  String text = clip?.text ?? '';
                  if (text.isNotEmpty) {
                    // Strip trailing newlines to prevent auto-execution on multiline paste
                    text = _stripTrailingNewlines(text);
                    widget.controller.onInput?.call(text);
                  }
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
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _focusNode.requestFocus();
              // clear any existing selection on simple click
              widget.controller.clearSelection();
            },
            onPanStart: (details) {
              _focusNode.requestFocus();
              final (
                absRow,
                absCol,
              ) = GestureSelectionHandler.calculateAbsoluteCoordinates(
                localPosition: details.localPosition,
                scrollOffset: _scrollController.offset,
                cellWidth: cellW,
                cellHeight: cellH,
                totalRows: widget.controller.totalRows,
                maxCols: widget.controller.cols,
              );
              widget.controller.startSelection(absRow, absCol);
            },
            onPanUpdate: (details) {
              final (
                absRow,
                absCol,
              ) = GestureSelectionHandler.calculateAbsoluteCoordinates(
                localPosition: details.localPosition,
                scrollOffset: _scrollController.offset,
                cellWidth: cellW,
                cellHeight: cellH,
                totalRows: widget.controller.totalRows,
                maxCols: widget.controller.cols,
              );
              widget.controller.updateSelection(absRow, absCol);
            },
            onPanEnd: (details) {
              // selection remains active until user clears or starts another selection
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics(),
              child: SizedBox(
                width: canvasWidth,
                height: canvasHeight < constraints.maxHeight
                    ? constraints.maxHeight
                    : canvasHeight,
                child: CustomPaint(
                  painter: TerminalPainter(
                    widget.controller,
                    readOnly: widget.readOnly,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Strip trailing newlines from multiline text to prevent auto-execution.
  /// Returns trimmed text if multiline, otherwise returns original text.
  ///
  /// TODO: There is a escape code that prevents auto-execution of pasted commands, but it is not implemented atm.
  static String _stripTrailingNewlines(String text) {
    if (text.contains('\n') && text.endsWith('\n')) {
      return text.trimRight();
    }
    return text;
  }
}
