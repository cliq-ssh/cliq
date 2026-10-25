import 'package:cliq/shared/model/entity_type.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:forui/forui.dart';

class EntityList extends StatelessWidget {
  final Map<EntityType, List<String>> entities;

  final double maxHeight;

  const new({super.key, required this.entities, this.maxHeight = 200});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: .new(maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: FTileGroup(
          children: [
            for (final entry in entities.entries)
              for (final name in entry.value)
                .tile(
                  prefix: Icon(entry.key.icon, size: 16),
                  title: Text(name),
                ),
          ],
        ),
      ),
    );
  }
}
