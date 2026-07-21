import 'dart:async';

import 'package:cliq/modules/identities/model/identity_full.model.dart';
import 'package:cliq/shared/extensions/text_controller.extension.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/data/database.dart';
import '../../../shared/model/entity_type.dart';
import '../../../shared/model/router.model.dart';
import '../../../shared/ui/create_or_edit_credential_form.dart';
import '../../../shared/ui/create_or_edit_entity_view.dart';
import '../../connections/provider/connection.provider.dart';
import '../../settings/provider/sync.provider.dart';
import '../../vaults/provider/vault_move_service.provider.dart';
import '../../vaults/ui/vault_transfer_dialog.dart';
import '../provider/identity.provider.dart';
import '../provider/identity_service.provider.dart';

class CreateOrEditIdentityView extends HookConsumerWidget {
  final String? initialLabel;
  final IdentitiesCompanion? current;
  final List<DbId>? currentCredentialIds;
  final bool isEdit;

  const CreateOrEditIdentityView.create({super.key, this.initialLabel})
    : current = null,
      currentCredentialIds = null,
      isEdit = false;

  CreateOrEditIdentityView.edit(IdentityFull identity, {super.key})
    : initialLabel = null,
      current = IdentitiesCompanion(
        id: Value(identity.id),
        vaultId: Value(identity.vaultId),
        label: Value(identity.label),
        username: Value(identity.username),
      ),
      currentCredentialIds = identity.credentialIds,
      isEdit = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final credentialsKey = useMemoized(
      () => GlobalKey<CreateOrEditCredentialsFormState>(),
    );
    final selectedVaultId = useState<DbId?>(current?.vaultId.value);

    final labelCtrl = useTextEditingController(
      text: initialLabel ?? current?.label.value,
    );
    final usernameCtrl = useTextEditingController(
      text: current?.username.value,
    );

    /// Handles the save action for the form.
    /// Validates the form, inserts any additional credentials, and either updates
    /// or creates a new connection based on the [isEdit] flag.
    Future<void> onSave(DbId? vaultId) async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final newCredentialIds = await credentialsKey.currentState?.save();
      // null is only returned when validation fails
      if (newCredentialIds == null) return;

      final identityService = ref.read(identityServiceProvider);
      final identityId = isEdit
          ? identityService.update(
              current!.id.value,
              vaultId: vaultId,
              label: labelCtrl.textOrNull,
              username: usernameCtrl.textOrNull,
              newCredentialIds: newCredentialIds,
              compareTo: current,
            )
          : identityService.createIdentity(
              vaultId: vaultId!,
              label: labelCtrl.text,
              username: usernameCtrl.text,
              credentialIds: newCredentialIds,
            );

      if (!context.mounted) return;
      context.pop((identityId, labelCtrl.text));
    }

    return CreateOrEditEntityView(
      onSave: onSave,
      initialVaultId: selectedVaultId.value,
      onVaultSelected: (vaultId) => selectedVaultId.value = vaultId,
      onOpenVaultTransferDialog: () async {
        final vaultMoveService = ref.read(vaultMoveServiceProvider);
        final preview = await vaultMoveService.previewMove(
          seedIdentityIds: {current!.id.value},
        );

        final otherIdentityIds = preview.identityIds.difference({
          current!.id.value,
        });
        final allIdentities = ref.read(identityProvider).entities;
        final allConnections = ref.read(connectionProvider).entities;

        final relations = <EntityType, List<String>>{
          if (otherIdentityIds.isNotEmpty)
            .identity: allIdentities
                .where((i) => otherIdentityIds.contains(i.id))
                .map((i) => i.label)
                .toList(),
          if (preview.connectionIds.isNotEmpty)
            .connection: allConnections
                .where((c) => preview.connectionIds.contains(c.id))
                .map((c) => c.label)
                .toList(),
          if (preview.keyIds.isNotEmpty)
            .key: ['keys_label'.plural(preview.keyIds.length)],
        };

        if (!context.mounted) return;

        await showFDialog(
          context: Router.rootNavigatorKey.currentContext ?? context,
          builder: (_, style, animation) => VaultTransferDialog(
            style: style,
            animation: animation,
            currentVault: selectedVaultId.value!,
            entityName: current?.label.value ?? labelCtrl.text,
            relations: relations.isEmpty ? null : relations,
            onTransfer: (targetVaultId) async {
              await vaultMoveService.commitMove(preview, targetVaultId);
              await ref.read(syncProvider.notifier).pullAndPushVault();
              selectedVaultId.value = targetVaultId;
              if (!context.mounted) return;
              Navigator.of(context).pop(); // close edit view after transfer
            },
          ),
        );
      },
      isEdit: isEdit,
      child: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FTextFormField(
              control: .managed(controller: labelCtrl),
              label: Text('identities_label'.tr()),
              hint: 'identities_label_placeholder'.tr(),
              validator: (s) => Validators.nonEmpty(context, s),
            ),

            FTextFormField(
              control: .managed(controller: usernameCtrl),
              label: Text('identities_username'.tr()),
              hint: 'identities_username_placeholder'.tr(),
              validator: (s) => Validators.nonEmpty(context, s),
            ),

            if (selectedVaultId.value != null)
              isEdit
                  ? CreateOrEditCredentialsForm.edit(
                      key: credentialsKey,
                      vaultId: selectedVaultId.value!,
                      currentCredentialIds,
                    )
                  : CreateOrEditCredentialsForm.create(
                      key: credentialsKey,
                      vaultId: selectedVaultId.value!,
                    ),
          ],
        ),
      ),
    );
  }
}
