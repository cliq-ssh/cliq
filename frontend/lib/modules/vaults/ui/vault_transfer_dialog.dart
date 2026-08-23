import 'package:cliq/modules/vaults/extension/vault.extension.dart';
import 'package:cliq/modules/vaults/provider/vault.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/model/entity_type.dart';
import 'package:cliq/shared/ui/horizontal_dialog.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

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

  const new({
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
    final localVault = useState<Vault?>(null);
    final vaultSelectController = useFSelectController<DbId>();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final isLoading = useState(false);

    useEffect(() {
      ref.read(vaultProvider.notifier).findOrCreateVault().then((vault) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          localVault.value = vault;
        });
      });
      return null;
    }, []);

    return HorizontalDialog(
      style: style,
      animation: animation,
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
                constraints: const .new(maxHeight: 200),
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
              format: (s) => vaults.entities
                  .firstWhere((v) => v.id == s)
                  .getDisplayName(context),
              children: [
                for (final v in VaultExtension.sortVaults(
                  vaults.entities,
                ).where((v) => v.id != currentVault))
                  .item(
                    prefix: v.owner == null
                        ? null
                        : const Icon(LucideIcons.cloudUpload),
                    title: Text(v.getDisplayName(context)),
                    value: v.id,
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
              onPress: isLoading.value || selectedVaultId == null
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;

                      isLoading.value = true;
                      await onTransfer(selectedVaultId);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
              child: isLoading.value
                  ? const FCircularProgress()
                  : Text(
                      selectedVault == null
                          ? 'transfer'.tr()
                          : 'transfer_to'.tr(
                              args: [selectedVault.getDisplayName(context)],
                            ),
                    ),
            );
          },
        ),
      ],
    );
  }
}
