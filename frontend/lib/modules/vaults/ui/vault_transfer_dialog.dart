import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/model/entity_type.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/utils/validators.dart';
import '../provider/vault.provider.dart';

class VaultTransferDialog extends HookConsumerWidget {
  final FDialogStyle style;
  final Animation<double> animation;

  /// The current vault the entity is in.
  /// This vault will be excluded from the list of vaults to transfer to.
  final DbId currentVault;

  /// The entities' name.
  final String entityName;

  /// The relations of this entity, keyed by their type.
  final Map<EntityType, List<String>>? relations;

  /// A callback for transferring the entity to another vault.
  final Future<void> Function(DbId) onTransfer;

  const VaultTransferDialog({
    super.key,
    required this.style,
    required this.animation,
    required this.currentVault,
    required this.entityName,
    required this.relations,
    required this.onTransfer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaults = ref.watch(vaultProvider);
    final defaultVault = useState<Vault?>(null);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final vaultSelectController = useFSelectController<DbId>();

    useEffect(() {
      ref.read(vaultProvider.notifier).findOrCreateDefaultVault().then((vault) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          defaultVault.value = vault;
        });
      });
      return null;
    }, []);

    return FDialog(
      style: style,
      animation: animation,
      direction: .horizontal,
      title: Text('dialog_vault_transfer'.tr()),
      body: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            if (relations != null && relations!.isNotEmpty)
              Text.rich(
                TextSpan(
                  children: TextUtils.renderText(
                    context,
                    'dialog_vault_transfer_dependencies_body'.tr(
                      args: [entityName],
                    ),
                  ),
                ),
              )
            else
              Text.rich(
                TextSpan(
                  children: TextUtils.renderText(
                    context,
                    'dialog_vault_transfer_body'.tr(args: [entityName]),
                  ),
                ),
              ),
            if (relations != null && relations!.isNotEmpty) ...[
              ConstrainedBox(
                constraints: .new(maxHeight: 200),
                child: SingleChildScrollView(
                  child: FTileGroup(
                    children: [
                      for (final entry in relations!.entries)
                        for (final dependency in entry.value)
                          .tile(
                            prefix: Icon(entry.key.icon, size: 16),
                            title: Text(dependency),
                          ),
                    ],
                  ),
                ),
              ),
            ],

            FSelect<DbId>.rich(
              validator: (v) => Validators.chain(context, [
                Validators.nonNull,
                Validators.nonEmpty,
              ], v),
              control: .managed(controller: vaultSelectController),
              format: (s) => vaults.entities.firstWhere((v) => v.id == s).label,
              children: [
                if (defaultVault.value != null &&
                    defaultVault.value!.id != currentVault)
                  .item(
                    title: Text('local_vault'.tr()),
                    value: defaultVault.value!.id,
                  ),
                for (final vault in vaults.entities.where(
                  (v) => !v.isDefault && v.id != currentVault,
                ))
                  .item(
                    prefix: Icon(LucideIcons.cloudSync),
                    title: Text(vault.label),
                    value: vault.id,
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        FButton(
          variant: .outline,
          child: Text('cancel'.tr()),
          onPress: () => Navigator.of(context).pop(),
        ),
        ValueListenableBuilder<DbId?>(
          valueListenable: vaultSelectController,
          builder: (context, selectedVaultId, _) {
            final selectedVault = selectedVaultId == null
                ? null
                : vaults.entities
                      .where((v) => v.id == selectedVaultId)
                      .firstOrNull;

            return FButton(
              variant: .destructive,
              onPress: selectedVaultId == null
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;

                      await onTransfer(selectedVaultId);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
              child: Text(
                selectedVault == null
                    ? 'transfer'.tr()
                    : 'transfer_to'.tr(args: [selectedVault.label]),
              ),
            );
          },
        ),
      ],
    );
  }
}
