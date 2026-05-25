import 'package:cliq/modules/keys/model/ssh_key_generator.dart';
import 'package:cliq/modules/keys/provider/key_service.provider.dart';
import 'package:cliq/shared/ui/create_or_edit_entity_view.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:cliq/shared/ui/option_tile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GenerateKeyView extends HookConsumerWidget {
  const GenerateKeyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final labelCtrl = useTextEditingController();
    final keyType = useState(SshKeyAlgorithm.ed25519);
    final ecdsaSize = useState(SshEcdsaCurveSize.bits256);
    final rsaSize = useState(SshRsaKeySize.bits2048);

    Future<void> onSave(int? vaultId) async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final label = labelCtrl.text.trim();
      final generated = await SshKeyGenerator.generate(
        keyType.value,
        ecdsaCurveSize: ecdsaSize.value,
        rsaKeySize: rsaSize.value,
        comment: label,
      );

      final keyService = ref.read(keyServiceProvider);
      final keyId = await keyService.createKey(
        vaultId: vaultId!,
        label: label,
        privateKey: generated.privateKey,
        publicKey: generated.publicKey,
        passphrase: null,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop((keyId, label));
    }

    Widget buildAlgorithmOption(SshKeyAlgorithm algorithm) {
      final isSelected = keyType.value == algorithm;
      final subtitleStyle = context.theme.typography.sm.copyWith(
        color: context.theme.colors.mutedForeground,
      );

      return OptionTile(
        padding: EdgeInsets.zero,
        onTap: () => keyType.value = algorithm,
        leading: Icon(
          isSelected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
        ),
        title: Text(algorithm.label),
        subtitle: Text(algorithm.note, style: subtitleStyle),
        selected: isSelected,
        dense: true,
      );
    }

    Widget buildCurveOption(SshEcdsaCurveSize size) {
      final isSelected = ecdsaSize.value == size;
      return OptionTile(
        padding: EdgeInsets.zero,
        onTap: () => ecdsaSize.value = size,
        leading: Icon(
          isSelected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
        ),
        title: Text(size.label),
        selected: isSelected,
        dense: true,
      );
    }

    Widget buildRsaOption(SshRsaKeySize size) {
      final isSelected = rsaSize.value == size;
      return OptionTile(
        padding: EdgeInsets.zero,
        onTap: () => rsaSize.value = size,
        leading: Icon(
          isSelected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
        ),
        title: Text(size.label),
        selected: isSelected,
        dense: true,
      );
    }

    return CreateOrEditEntityView(
      onSave: onSave,
      isEdit: false,
      createLabel: 'Generate Key',
      child: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FTextFormField(
              control: .managed(controller: labelCtrl),
              label: const Text('Label'),
              hint: 'My Key',
              validator: Validators.nonEmpty,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Key Type', style: context.theme.typography.lg),
                const SizedBox(height: 8),
                buildAlgorithmOption(SshKeyAlgorithm.ed25519),
                buildAlgorithmOption(SshKeyAlgorithm.ecdsa),
                buildAlgorithmOption(SshKeyAlgorithm.rsa),
              ],
            ),
            if (keyType.value == SshKeyAlgorithm.ecdsa)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elliptic Curve Size (bits)',
                    style: context.theme.typography.lg,
                  ),
                  const SizedBox(height: 8),
                  buildCurveOption(SshEcdsaCurveSize.bits521),
                  buildCurveOption(SshEcdsaCurveSize.bits384),
                  buildCurveOption(SshEcdsaCurveSize.bits256),
                ],
              ),
            if (keyType.value == SshKeyAlgorithm.rsa)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key Size (bits)', style: context.theme.typography.lg),
                  const SizedBox(height: 8),
                  buildRsaOption(SshRsaKeySize.bits4096),
                  buildRsaOption(SshRsaKeySize.bits2048),
                  buildRsaOption(SshRsaKeySize.bits1024),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
