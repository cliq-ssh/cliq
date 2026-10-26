import 'package:flutter/material.dart';

class const PropertyTable({
  super.key,
  required final List<(String, Object?)> properties,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alternateRowColor = Theme.of(context)
        .colorScheme
        .surfaceContainerHighest;

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
}
