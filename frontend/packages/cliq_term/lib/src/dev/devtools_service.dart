import 'dart:convert';
import 'dart:developer' as developer;

import '../model/terminal_registry.dart';

void registerCliqTermDevToolsService() {
  developer.registerExtension('ext.cliq_term.getTerminals', (
    method,
    parameters,
  ) async {
    final terminals = [
      for (final entry in TerminalRegistry.instance.controllers.entries)
        {
          'id': entry.key,
          'title': entry.value.currentTitle,
          'rows': entry.value.rows,
          'cols': entry.value.cols,
          'backBufferActive': entry.value.backBufferActive,
          'cursorRow': entry.value.activeBuffer.cursorRow,
          'cursorCol': entry.value.activeBuffer.cursorCol,
          'scrollback': entry.value.activeBuffer.currentScrollback,
          'isPaused': entry.value.isPaused,
          'isDirty': entry.value.isDirty,
        },
    ];

    return developer.ServiceExtensionResponse.result(
      jsonEncode({'terminals': terminals}),
    );
  });

  developer.registerExtension('ext.cliq_term.getCell', (
    method,
    parameters,
  ) async {
    final id = parameters['id'];
    final row = int.tryParse(parameters['row'] ?? '');
    final col = int.tryParse(parameters['col'] ?? '');

    if (id == null || row == null || col == null) {
      return developer.ServiceExtensionResponse.error(
        developer.ServiceExtensionResponse.invalidParams,
        'id, row, and col are required',
      );
    }

    final controller = TerminalRegistry.instance.controllers[id];
    if (controller == null) {
      return developer.ServiceExtensionResponse.error(
        developer.ServiceExtensionResponse.extensionError,
        'Terminal not found',
      );
    }

    if (row < 0 ||
        row >= controller.rows ||
        col < 0 ||
        col >= controller.cols) {
      return developer.ServiceExtensionResponse.error(
        developer.ServiceExtensionResponse.invalidParams,
        'Cell coordinates are out of range',
      );
    }

    final cell = controller.activeBuffer.getCell(row, col);

    return developer.ServiceExtensionResponse.result(
      jsonEncode({
        'row': row,
        'col': col,
        'character': cell.ch,
        'foreground': cell.fmt.fgColor?.value,
        'background': cell.fmt.bgColor?.value,
        'bold': cell.fmt.bold,
        'faint': cell.fmt.faint,
        'italic': cell.fmt.italic,
        'underline': cell.fmt.underline.name,
        'concealed': cell.fmt.concealed,
        'inverted': cell.fmt.inverted,
        'hyperlink': cell.fmt.hyperlink,
      }),
    );
  });
}
