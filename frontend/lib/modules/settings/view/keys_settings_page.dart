import 'package:cliq/modules/keys/view/create_or_edit_key_view.dart';
import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:cliq_ui/hooks/use_memoized_future.export.dart'
    show useMemoizedFuture;
import 'package:flutter/cupertino.dart' hide Key;
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
import '../../../shared/extensions/async_snapshot.extension.dart';
import '../../../shared/model/page_path.model.dart';
import '../../../shared/utils/commons.dart';
import '../../keys/provider/key.provider.dart';
import '../../keys/ui/key_card.dart';

class KeysSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'keys',
  );

  const KeysSettingsPage({super.key});

  @override
  String get title => 'Keys';

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final keyIds = ref.watch(keyIdProvider);
    final keysFuture = useMemoizedFuture(() async {
      return await CliqDatabase.keysService.findByIds(keyIds.entities);
    }, [keyIds]);

    return keysFuture.on(
      onLoading: () => Center(child: FCircularProgress()),
      onData: (keys) {
        return EntityCardView<Key>(
          entities: keys,
          entityCardBuilder: (key) => KeyCard(keyEntity: key),
          viewTypeKey: .keysCardViewType,
          noEntitiesTitle: 'No Keys',
          noEntitiesSubtitle:
              'Add your first key by clicking the button below.',
          addEntityTitle: 'Add Key',
          filterableFields: (k) => [k.label],
          onAddEntity: () => Commons.showResponsiveDialog(
            context,
            (_) => CreateOrEditKeyView.create(),
          ),
        );
      },
    );
  }
}
