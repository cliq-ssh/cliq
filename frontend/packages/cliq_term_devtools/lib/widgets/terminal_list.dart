import 'dart:async';

import 'package:devtools_app_shared/ui.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

class TerminalList extends StatefulWidget {
  const TerminalList({super.key});

  @override
  State<TerminalList> createState() => _TerminalListState();
}

class _TerminalListState extends State<TerminalList> {
  Timer? _refreshTimer;
  List<Map<String, Object?>> _terminals = [];

  String? _selectedId;
  Map<String, Object?>? _selectedCell;
  int? _selectedRow;
  int? _selectedCol;

  String? _error;
  bool _refreshing = false;

  final _gridHorizontalController = ScrollController();
  final _gridVerticalController = ScrollController();

  Map<String, Object?>? get _selectedTerminal {
    for (final terminal in _terminals) {
      if (terminal['id'] == _selectedId) {
        return terminal;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    unawaited(_refresh());
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refresh(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _gridHorizontalController.dispose();
    _gridVerticalController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_refreshing || !serviceManager.connectedState.value.connected) {
      return;
    }

    _refreshing = true;

    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.cliq_term.getTerminals',
      );

      final values = response.json?['terminals'];
      if (values is! List) {
        throw const FormatException(
          'Invalid response from ext.cliq_term.getTerminals',
        );
      }

      final terminals = [
        for (final value in values)
          if (value is Map) Map<String, Object?>.from(value),
      ];

      final selectedCell = _selectedCell;
      final selectedId = _selectedId;

      if (selectedCell != null && selectedId != null) {
        unawaited(
          _selectCell(
            selectedId,
            selectedCell['row'] as int,
            selectedCell['col'] as int,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _terminals = terminals;
        _error = null;

        if (_selectedId == null ||
            !terminals.any((terminal) => terminal['id'] == _selectedId)) {
          _selectedId = terminals.isEmpty
              ? null
              : terminals.first['id'] as String?;
          _selectedCell = null;
          _selectedRow = null;
          _selectedCol = null;
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _selectCell(String id, int row, int col) async {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });

    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.cliq_term.getCell',
        args: {'id': id, 'row': '$row', 'col': '$col'},
      );

      final cell = response.json;
      if (!mounted || cell == null) return;

      setState(() {
        _selectedCell = Map<String, Object?>.from(cell);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final terminal = _selectedTerminal;
    final alternateRowColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;

    buildTerminalList() {
      if (_error != null && _terminals.isEmpty) {
        return Center(child: Text(_error!));
      }

      if (_terminals.isEmpty) {
        return const Center(child: Text('No running terminals'));
      }

      return ListView.builder(
        itemCount: _terminals.length,
        itemBuilder: (context, index) {
          final current = _terminals[index];
          final id = current['id'] as String;

          return ListTile(
            selected: id == _selectedId,
            title: Text(id, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              setState(() {
                _selectedId = id;
                _selectedCell = null;
                _selectedRow = null;
                _selectedCol = null;
              });
            },
          );
        },
      );
    }

    buildPropertyTable(List<(String, Object?)> properties) {
      return DataTable(
        columns: const [
          DataColumn(label: Text('Property')),
          DataColumn(label: Text('Value')),
        ],
        rows: [
          for (var index = 0; index < properties.length; index++)
            DataRow(
              color: WidgetStatePropertyAll(
                index.isEven ? null : alternateRowColor,
              ),
              cells: [
                DataCell(Text(properties[index].$1)),
                DataCell(Text('${properties[index].$2}')),
              ],
            ),
        ],
      );
    }

    buildTerminalTab() {
      if (terminal == null) {
        return const Center(child: Text('Select a terminal'));
      }

      return ListView(
        padding: const EdgeInsets.all(denseSpacing),
        children: [
          buildPropertyTable([
            ('ID', terminal['id']),
            ('Title', terminal['title']),
            ('Size', '${terminal['rows']} × ${terminal['cols']}'),
            (
              'Cursor',
              '${(terminal['cursorRow'] as int) + 1}:'
                  '${(terminal['cursorCol'] as int) + 1}',
            ),
            ('Scrollback', terminal['scrollback']),
            ('Alternate buffer', terminal['backBufferActive']),
            ('Paused', terminal['isPaused']),
            ('Dirty', terminal['isDirty']),
          ]),
        ],
      );
    }

    buildCellInspectorTab() {
      if (terminal == null) {
        return const Center(child: Text('Select a terminal'));
      }

      final rows = terminal['rows'] as int? ?? 0;
      final cols = terminal['cols'] as int? ?? 0;
      final selectedRow = _selectedRow ?? 0;
      final selectedCol = _selectedCol ?? 0;

      return ListView(
        padding: const .all(denseSpacing),
        children: [
          Row(
            children: [
              const Text('Row'),
              const SizedBox(width: denseSpacing),
              DropdownButton<int>(
                value: selectedRow < rows ? selectedRow : null,
                items: [
                  for (var row = 0; row < rows; row++)
                    DropdownMenuItem(value: row, child: Text('${row + 1}')),
                ],
                onChanged: (row) {
                  if (row == null) return;
                  _selectCell(terminal['id'] as String, row, selectedCol);
                },
              ),
              const SizedBox(width: denseSpacing),
              const Text('Column'),
              const SizedBox(width: denseSpacing),
              DropdownButton<int>(
                value: selectedCol < cols ? selectedCol : null,
                items: [
                  for (var col = 0; col < cols; col++)
                    DropdownMenuItem(value: col, child: Text('${col + 1}')),
                ],
                onChanged: (col) {
                  if (col == null) return;
                  _selectCell(terminal['id'] as String, selectedRow, col);
                },
              ),
            ],
          ),
          const SizedBox(height: denseSpacing),
          SizedBox(
            height: 300,
            child: Scrollbar(
              controller: _gridHorizontalController,
              thumbVisibility: true,
              trackVisibility: true,
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _gridHorizontalController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: cols * 12.0,
                  child: Scrollbar(
                    controller: _gridVerticalController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: GridView.builder(
                      controller: _gridVerticalController,
                      itemCount: rows * cols,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisExtent: 12,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final row = index ~/ cols;
                        final col = index % cols;
                        final selected =
                            _selectedRow == row && _selectedCol == col;

                        return InkWell(
                          onTap: () =>
                              _selectCell(terminal['id'] as String, row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : null,
                              border: .all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.25),
                                width: 0.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_selectedCell != null) ...[
            const SizedBox(height: denseSpacing),
            buildPropertyTable([
              (
                'Position',
                '${(_selectedCell!['row'] as int) + 1}:'
                    '${(_selectedCell!['col'] as int) + 1}',
              ),
              ('Character', _selectedCell!['character']),
              ('Foreground', _selectedCell!['foreground']),
              ('Background', _selectedCell!['background']),
              ('Bold', _selectedCell!['bold']),
              ('Faint', _selectedCell!['faint']),
              ('Italic', _selectedCell!['italic']),
              ('Underline', _selectedCell!['underline']),
              ('Concealed', _selectedCell!['concealed']),
              ('Inverted', _selectedCell!['inverted']),
              ('Hyperlink', _selectedCell!['hyperlink']),
            ]),
          ],
        ],
      );
    }

    return Padding(
      padding: const .all(denseSpacing),
      child: SplitPane(
        axis: .horizontal,
        initialFractions: const [0.2, 0.7],
        minSizes: const [180, 240],
        children: [
          DevToolsAreaPane(
            header: AreaPaneHeader(
              title: const Text('Terminals'),
              actions: [
                DevToolsButton.iconOnly(
                  icon: Icons.refresh,
                  tooltip: 'Refresh',
                  onPressed: _refreshing ? null : _refresh,
                ),
              ],
            ),
            child: buildTerminalList(),
          ),
          DevToolsAreaPane(
            header: AreaPaneHeader(
              title: Text(
                terminal?['title'] as String? ??
                    terminal?['id'] as String? ??
                    'Terminal details',
              ),
            ),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Terminal'),
                      Tab(text: 'Cell inspector'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [buildTerminalTab(), buildCellInspectorTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
