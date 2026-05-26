import 'package:cliq/modules/keys/model/ssh_key_generator.dart';
import 'package:cliq/modules/keys/provider/key_service.provider.dart';
import 'package:cliq/shared/ui/create_or_edit_entity_view.dart';
import 'package:cliq/shared/utils/validators.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _KeyGenerationParams {
  final SshKeyAlgorithm algorithm;
  final SshEcdsaCurveSize ecdsaCurveSize;
  final SshRsaKeySize rsaKeySize;
  final String comment;

  _KeyGenerationParams({
    required this.algorithm,
    required this.ecdsaCurveSize,
    required this.rsaKeySize,
    required this.comment,
  });
}

Future<GeneratedSshKeyPair> _generateKeyInIsolate(
  _KeyGenerationParams params,
) => SshKeyGenerator.generate(
  params.algorithm,
  ecdsaCurveSize: params.ecdsaCurveSize,
  rsaKeySize: params.rsaKeySize,
  comment: params.comment,
);

class GenerateKeyView extends HookConsumerWidget {
  const GenerateKeyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final labelCtrl = useTextEditingController();
    final keyType = useState(SshKeyAlgorithm.ed25519);
    final ecdsaSize = useState(SshEcdsaCurveSize.bits256);
    final rsaSize = useState(SshRsaKeySize.bits2048);
    final isLoading = useState(false);

    Future<void> onSave(int? vaultId) async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      if (isLoading.value) return;

      try {
        isLoading.value = true;
        final label = labelCtrl.text.trim();

        final generated = await compute(
          _generateKeyInIsolate,
          _KeyGenerationParams(
            algorithm: keyType.value,
            ecdsaCurveSize: ecdsaSize.value,
            rsaKeySize: rsaSize.value,
            comment: label,
          ),
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
      } finally {
        isLoading.value = false;
      }
    }

    return CreateOrEditEntityView(
      onSave: onSave,
      isEdit: false,
      createLabel: 'Generate Key',
      isCreateLoading: isLoading.value,
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
              enabled: !isLoading.value,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FSelectGroup<SshKeyAlgorithm>(
                  control: FMultiValueControl<SshKeyAlgorithm>.managedRadio(
                    initial: keyType.value,
                    onChange: (value) {
                      if (!isLoading.value) {
                        keyType.value = value.firstOrNull ?? keyType.value;
                      }
                    },
                  ),
                  label: const Text('Key Type'),
                  children: [
                    for (final algorithm in SshKeyAlgorithm.values)
                      FSelectGroupItemMixin.radio(
                        value: algorithm,
                        label: Text(algorithm.label),
                        description: Text(algorithm.note),
                      ),
                  ],
                ),
              ],
            ),
            if (keyType.value == SshKeyAlgorithm.ecdsa)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FSelectGroup<SshEcdsaCurveSize>(
                    control: FMultiValueControl<SshEcdsaCurveSize>.managedRadio(
                      initial: ecdsaSize.value,
                      onChange: (value) {
                        if (!isLoading.value) {
                          ecdsaSize.value =
                              value.firstOrNull ?? ecdsaSize.value;
                        }
                      },
                    ),
                    label: const Text('Elliptic Curve Size (bits)'),
                    children: [
                      for (final size in [
                        SshEcdsaCurveSize.bits521,
                        SshEcdsaCurveSize.bits384,
                        SshEcdsaCurveSize.bits256,
                      ])
                        FSelectGroupItemMixin.radio(
                          value: size,
                          label: Text(size.label),
                        ),
                    ],
                  ),
                ],
              ),
            if (keyType.value == SshKeyAlgorithm.rsa)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FSelectGroup<SshRsaKeySize>(
                    control: FMultiValueControl<SshRsaKeySize>.managedRadio(
                      initial: rsaSize.value,
                      onChange: (value) {
                        if (!isLoading.value) {
                          rsaSize.value = value.firstOrNull ?? rsaSize.value;
                        }
                      },
                    ),
                    label: const Text('Key Size (bits)'),
                    children: [
                      for (final size in [
                        SshRsaKeySize.bits4096,
                        SshRsaKeySize.bits2048,
                        SshRsaKeySize.bits1024,
                      ])
                        FSelectGroupItemMixin.radio(
                          value: size,
                          label: Text(size.label),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
