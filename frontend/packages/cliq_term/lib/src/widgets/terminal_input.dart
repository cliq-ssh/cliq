import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps [child] in a [Focus] widget and opens a software-keyboard
/// TextInputConnection whenever focused, forwarding input to [onInput].
class TerminalInput extends StatefulWidget {
  final FocusNode focusNode;
  final Widget child;
  final ValueChanged<String> onInput;
  final bool readOnly;
  final KeyEventResult Function(FocusNode node, KeyEvent event)? onKeyEvent;
  final ValueChanged<bool>? onFocusChange;
  final ValueNotifier<bool>? keyboardVisible;

  const TerminalInput({
    super.key,
    required this.focusNode,
    required this.child,
    required this.onInput,
    this.readOnly = false,
    this.onKeyEvent,
    this.onFocusChange,
    this.keyboardVisible,
  });

  @override
  State<TerminalInput> createState() => _TerminalInputState();
}

class _TerminalInputState extends State<TerminalInput>
    implements TextInputClient {
  TextInputConnection? _inputConnection;
  bool _lastReportedFocus = false;

  TextEditingValue _editingValue = const .new(
    text: ' ',
    selection: .collapsed(offset: 1),
  );

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_updateConnection);
    widget.keyboardVisible?.addListener(_updateConnection);
    if (widget.focusNode.hasFocus) _updateConnection();
  }

  @override
  void didUpdateWidget(covariant TerminalInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_updateConnection);
      widget.focusNode.addListener(_updateConnection);
    }
    if (oldWidget.keyboardVisible != widget.keyboardVisible) {
      oldWidget.keyboardVisible?.removeListener(_updateConnection);
      widget.keyboardVisible?.addListener(_updateConnection);
    }
    if (widget.readOnly != oldWidget.readOnly) {
      _updateConnection();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_updateConnection);
    widget.keyboardVisible?.removeListener(_updateConnection); // NEW
    _closeInputConnection();
    super.dispose();
  }

  /// Updates the TextInputConnection based on the current focus and read-only state.
  /// If the focus state has changed, it calls [onFocusChange] if provided.
  void _updateConnection() {
    final hasFocus = widget.focusNode.hasFocus;
    if (hasFocus != _lastReportedFocus) {
      _lastReportedFocus = hasFocus;
      widget.onFocusChange?.call(hasFocus);
    }

    final wantsKeyboard = widget.keyboardVisible?.value ?? true;
    if (hasFocus && !widget.readOnly && wantsKeyboard) {
      _openInputConnection();
    } else {
      _closeInputConnection();
    }
  }

  /// Opens a TextInputConnection to the software keyboard if not already open.
  void _openInputConnection() {
    final int? viewId = View.maybeOf(context)?.viewId;
    if (viewId == null) {
      // if the viewId is not available, we cannot open the input connection.
      return;
    }

    if (_inputConnection == null || !_inputConnection!.attached) {
      _inputConnection = TextInput.attach(
        this,
        TextInputConfiguration(
          viewId: viewId,
          inputType: .text,
          keyboardAppearance: Theme.of(context).brightness,
          autocorrect: false,
        ),
      );
      _inputConnection!.setEditingState(_editingValue);
    }
    _inputConnection!.show();
  }

  /// Closes the TextInputConnection to the software keyboard if open.
  void _closeInputConnection() {
    _inputConnection?.close();
    _inputConnection = null;
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    final oldLen = _editingValue.text.length;
    final newLen = value.text.length;

    if (newLen > oldLen) {
      widget.onInput(value.text.substring(oldLen));
    } else if (newLen < oldLen) {
      widget.onInput('\x7f'); // backspace
    }

    _editingValue = const TextEditingValue(
      text: ' ',
      selection: TextSelection.collapsed(offset: 1),
    );
    // Use a post-frame callback to avoid engine-side race conditions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (_inputConnection?.attached ?? false)) {
        _inputConnection!.setEditingState(_editingValue);
      }
    });
  }

  @override
  void performAction(TextInputAction action) {
    if (action == TextInputAction.done || action == TextInputAction.newline) {
      widget.onInput('\n');
    }
  }

  @override
  TextEditingValue? get currentTextEditingValue => _editingValue;
  @override
  AutofillScope? get currentAutofillScope => null;
  @override
  void connectionClosed() => _inputConnection = null;
  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}
  @override
  void showAutocorrectionPromptRect(int start, int end) {}
  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}
  @override
  void insertTextPlaceholder(Size size) {}
  @override
  void removeTextPlaceholder() {}
  @override
  void didChangeInputControl(
    TextInputControl? oldControl,
    TextInputControl? newControl,
  ) {}
  @override
  void performSelector(String selectorName) {}
  @override
  void insertContent(KeyboardInsertedContent content) {}
  @override
  bool onFocusReceived() => true;
  @override
  void showToolbar() {}

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: widget.onKeyEvent,
      child: widget.child,
    );
  }
}
