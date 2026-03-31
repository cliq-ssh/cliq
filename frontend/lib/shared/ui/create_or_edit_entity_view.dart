import 'package:cliq/modules/vaults/provider/vault.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CreateOrEditEntityView extends HookConsumerWidget {
  final Function(int?) onSave;
  final bool isEdit;
  final Widget child;
  final Function(int)? onVaultSelected;

  /// Whether to show the vault selector in the form. If this is false, [onSave] will be called with null.
  final bool withVaultSelector;

  const CreateOrEditEntityView({
    super.key,
    required this.onSave,
    required this.isEdit,
    required this.child,
    this.onVaultSelected,
    this.withVaultSelector = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final vaults = ref.watch(vaultProvider);
    final vaultSelectController = useFSelectController<int>();

    final defaultVault = useState<Vault?>(null);
    useEffect(() {
      if (withVaultSelector) {
        ref.read(vaultProvider.notifier).findOrCreateDefaultVault(context).then(
          (vault) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              defaultVault.value = vault;
              vaultSelectController.value = vault.id;
              onVaultSelected?.call(vault.id);
            });
          },
        );
      }
      return null;
    }, []);

    return FScaffold(
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
                    SizedBox(
                      width: 200,
                      child: FSelect<int>.rich(
                        validator: (v) => Validators.chain([
                          Validators.nonNull,
                          Validators.nonEmpty,
                        ], v),
                        control: .managed(
                          controller: vaultSelectController,
                          onChange: (int? vaultId) {
                            if (vaultId != null) {
                              onVaultSelected?.call(vaultId);
                            }
                          },
                        ),
                        format: (s) =>
                            vaults.entities.firstWhere((v) => v.id == s).label,
                        children: [
                          for (final vault in vaults.entities)
                            .item(title: Text(vault.label), value: vault.id),
                        ],
                      ),
                    ),
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
              child: FButton(
                onPress: () {
                  if (withVaultSelector && !formKey.currentState!.validate()) {
                    return;
                  }
                  onSave(
                    withVaultSelector ? vaultSelectController.value! : null,
                  );
                },
                child: Text(isEdit ? 'Edit' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
