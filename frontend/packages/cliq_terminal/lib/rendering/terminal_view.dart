import 'dart:convert';

import 'package:cliq_terminal/cliq_terminal.dart';
import 'package:flutter/material.dart';

class CliqTerminalView extends StatefulWidget {
  final CliqTerminal terminal;
  const CliqTerminalView({super.key, required this.terminal});

  @override
  State<CliqTerminalView> createState() => _CliqTerminalViewState();
}

class _CliqTerminalViewState extends State<CliqTerminalView> {
  final ScrollController _scrollController = ScrollController();
  final StringBuffer _buffer = StringBuffer();
  final TextEditingController _textController = TextEditingController();

  String _displayText = '';

  @override
  void initState() {
    super.initState();
    widget.terminal.session.stdout.listen((data) {
      final decoded = utf8.decode(data);
      _buffer.write(decoded);

      // Update UI with new text
      setState(() {
        _displayText = _buffer.toString();
      });

      // Optional: auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _sendCommand(String input) {
    if (input.trim().isEmpty) return;
    widget.terminal.write('$input\n');
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _displayText,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _sendCommand,
                    decoration: const InputDecoration(
                      hintText: 'Enter command',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendCommand(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
