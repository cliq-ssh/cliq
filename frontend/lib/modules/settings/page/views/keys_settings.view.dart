import 'package:cliq/modules/keys/model/key_full.model.dart';
import 'package:cliq/modules/keys/provider/key.provider.dart';
import 'package:cliq/modules/keys/provider/key_service.provider.dart';
import 'package:cliq/modules/keys/ui/key_card.dart';
import 'package:cliq/modules/keys/ui/key_creation_choice_sheet.dart';
import 'package:cliq/modules/settings/page/abstract_settings_page.dart';
import 'package:cliq/modules/settings/page/settings.page.dart';
import 'package:cliq/shared/extensions/async_snapshot.extension.dart';
import 'package:cliq/shared/model/page_path.model.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq_ui/hooks/use_memoized_future.export.dart'
    show useMemoizedFuture;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' hide Key;
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class const KeysSettingsView({super.key}) extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = .child(
    parent: SettingsPage.pagePath,
    path: 'keys',
  );

  @override
  String get title => 'keys'.tr();

  @override
  Widget buildBodyWrapper(BuildContext context, WidgetRef ref, Widget body) =>
      body;

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final keyIds = ref.watch(keyIdProvider);
    final keysFuture = useMemoizedFuture(() async {
      return await ref.read(keyServiceProvider).findByIds(keyIds.entities);
    }, [keyIds]);

    return keysFuture.on(
      onLoading: () => const Center(child: FCircularProgress()),
      onData: (keys) {
        return EntityCardView<KeyFull>(
          entities: keys,
          entityCardBuilder: (key) => KeyCard(keyEntity: key),
          viewTypeKey: .keysCardViewType,
          noEntitiesTitle: 'keys_empty'.tr(),
          noEntitiesSubtitle: 'keys_empty_subtitle'.tr(),
          addEntityTitle: 'keys_add'.tr(),
          filterableFields: (k) => [?k.vault.owner, k.label],
          filterableVaultId: (k) => k.vaultId,
          onAddEntity: () => Commons.showResponsiveSheet(
            (_) => const KeyCreationChoiceSheet(),
            context: context,
          ),
        );
      },
    );
  }
}
