import 'package:cliq/modules/settings/provider/sync.provider.dart';
import 'package:cliq/modules/vaults/provider/vault.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CreateOrEditEntityView extends HookConsumerWidget {
  final Function(DbId?) onSave;
  final bool isEdit;
  final Widget child;
  final String? editLabel;
  final String? createLabel;
  final DbId? initialVaultId;
  final Function(DbId)? onVaultSelected;
  final Function()? onOpenVaultTransferDialog;

  /// Whether to show the vault selector in the form. If this is false, [onSave] will be called with null.
  final bool withVaultSelector;

  /// Loading states and labels for create and edit actions.
  final bool isCreateLoading;
  final bool isEditLoading;
  final String? createLoadingLabel;
  final String? editLoadingLabel;

  const CreateOrEditEntityView({
    super.key,
    required this.onSave,
    required this.isEdit,
    required this.child,
    this.initialVaultId,
    this.onVaultSelected,
    this.onOpenVaultTransferDialog,
    this.editLabel,
    this.createLabel,
    this.withVaultSelector = true,
    this.isCreateLoading = false,
    this.isEditLoading = false,
    this.createLoadingLabel,
    this.editLoadingLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final vaults = ref.watch(vaultProvider);

    final api = ref.watch(syncProvider).api;

    final defaultVault = useState<Vault?>(null);
    final userVault = useState<Vault?>(null);

    final vaultSelectController = useFSelectController<DbId>(
      value: initialVaultId ?? defaultVault.value?.id,
    );

    useEffect(() {
      if (!withVaultSelector) return;
      ref.read(vaultProvider.notifier).findOrCreateDefaultVault().then((vault) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          defaultVault.value = vault;
          if (initialVaultId != null) return;
          vaultSelectController.value = vault.id;
          onVaultSelected?.call(vault.id);
        });
      });
      return null;
    }, []);

    useEffect(() {
      if (!withVaultSelector || api == null) return;
      ref.read(vaultProvider.notifier).findOrCreateUserVault(api).then((vault) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          userVault.value = vault;
        });
      });
      return null;
    }, [api]);

    buildVaultSelector() {
      if (isEdit) {
        return FTooltip(
          tipBuilder: (_, _) => Text('entity_edit_vault'.tr()),
          child: FButton.icon(
            variant: .outline,
            onPress: onOpenVaultTransferDialog,
            child: Icon(LucideIcons.folderPen, size: 16),
          ),
        );
      }

      return SizedBox(
        width: 200,
        child: FSelect<DbId>.rich(
          enabled: !isEdit,
          validator: (v) => Validators.chain(context, [
            Validators.nonNull,
            Validators.nonEmpty,
          ], v),
          control: .managed(
            controller: vaultSelectController,
            onChange: (DbId? vaultId) {
              if (vaultId != null) {
                onVaultSelected?.call(vaultId);
              }
            },
          ),
          format: (s) => vaults.entities.firstWhere((v) => v.id == s).label,
          children: [
            // local vault on top
            if (defaultVault.value != null)
              .item(
                title: Text('local_vault'.tr()),
                value: defaultVault.value!.id,
              ),
            for (final vault in vaults.entities.where((v) => !v.isDefault))
              .item(
                prefix: Icon(LucideIcons.cloudSync),
                title: Text(vault.label),
                value: vault.id,
              ),
          ],
        ),
      );
    }

    return FScaffold(
      childPad: false,
      child: SingleChildScrollView(
        padding: const .symmetric(horizontal: 32, vertical: 20),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  if (withVaultSelector && defaultVault.value != null)
                    buildVaultSelector(),
                  FButton.icon(
                    variant: .outline,
                    onPress: () => context.pop(),
                    child: const Icon(LucideIcons.x),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            child,
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: Builder(
                builder: (_) {
                  final label = isEdit
                      ? (editLabel ?? 'edit'.tr())
                      : (createLabel ?? 'save'.tr());
                  final isLoading = isEdit ? isEditLoading : isCreateLoading;
                  final currentLabel = isEdit
                      ? (editLoadingLabel ?? label)
                      : (createLoadingLabel ?? label);
                  final isBusy = isCreateLoading || isEditLoading;

                  return FButton(
                    onPress: isBusy
                        ? null
                        : () {
                            if (withVaultSelector &&
                                !formKey.currentState!.validate()) {
                              return;
                            }

                            final vaultId = withVaultSelector
                                ? vaultSelectController.value
                                : null;

                            if (withVaultSelector) {
                              ref
                                  .read(syncProvider.notifier)
                                  .pullAndPushVault();
                            }

                            onSave(vaultId);
                          },
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(currentLabel),
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: FCircularProgress(),
                              ),
                            ],
                          )
                        : Text(label),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
