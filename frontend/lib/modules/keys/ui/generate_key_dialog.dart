import 'package:cliq/shared/utils/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pointycastle/export.dart';

import '../../../shared/extensions/text_controller.extension.dart';

enum _KeyType {
  rsa(_generateRSA, maxBitStrength: 16384),
  ecdsa(
    _generateECDSA,
    supportedCurves: ['secp256r1', 'secp384r1', 'secp521r1'],
  );

  final AsymmetricKeyPair<PublicKey, PrivateKey> Function({
    String? passphrase,
    int? bitStrength,
    ECDomainParameters? curve,
  })
  generator;
  final int? maxBitStrength;
  final List<String>? supportedCurves;

  const _KeyType(this.generator, {this.maxBitStrength, this.supportedCurves});

  String getDisplayName(BuildContext context) {
    return switch (this) {
      _KeyType.rsa => 'RSA',
      _KeyType.ecdsa => 'ECDSA',
    };
  }

  static AsymmetricKeyPair<PublicKey, PrivateKey> _generateRSA({
    String? passphrase,
    int? bitStrength,
    ECDomainParameters? curve,
  }) {
    assert(bitStrength != null);
    return (RSAKeyGenerator()..init(
          ParametersWithRandom(
            RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
            FortunaRandom(),
          ),
        ))
        .generateKeyPair();
  }

  static AsymmetricKeyPair<PublicKey, PrivateKey> _generateECDSA({
    String? passphrase,
    int? bitStrength,
    ECDomainParameters? curve,
  }) {
    assert(curve != null);
    return (ECKeyGenerator()..init(
          ParametersWithRandom(
            ECKeyGeneratorParameters(curve!),
            FortunaRandom(),
          ),
        ))
        .generateKeyPair();
  }
}

class GenerateKeyDialog extends HookConsumerWidget {
  final FDialogStyle style;
  final Animation<double> animation;

  const GenerateKeyDialog({
    super.key,
    required this.style,
    required this.animation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();
    final keyTypeController = useFSelectController<_KeyType>();
    final keyBitStrengthController = useTextEditingController();
    final keyCurveController = useFSelectController<String>();

    final formKey = useMemoized(() => GlobalKey<FormState>());

    onGenerateKey() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final keyType = keyTypeController.value!;
      final keyPair =
          await compute<_KeyType, AsymmetricKeyPair<PublicKey, PrivateKey>>(
            (type) => type.generator(
              passphrase: passwordController.textOrNull,
              bitStrength: keyBitStrengthController.textOrNull != null
                  ? int.parse(keyBitStrengthController.text)
                  : null,
              curve: keyCurveController.value != null
                  ? ECDomainParameters(keyCurveController.value!)
                  : null,
            ),
            keyType,
          );
      Navigator.of(context).pop((keyPair, passwordController.textOrNull));
    }

    return FDialog(
      style: style,
      animation: animation,
      direction: Axis.horizontal,
      title: const Text('Generate a new key pair'),
      body: Form(
        key: formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            Text(
              'Generate a new SSH key pair by selecting the key type and providing an optional passphrase.',
            ),
            FSelect<_KeyType>.rich(
              control: .managed(controller: keyTypeController),
              label: Text('Key Type'),
              format: (s) => s.getDisplayName(context),
              validator: Validators.nonNull,
              children: [
                for (final type in _KeyType.values)
                  FSelectItem(
                    value: type,
                    title: Text(type.getDisplayName(context)),
                  ),
              ],
            ),
            if (keyTypeController.value == .rsa)
              FTextFormField(
                label: Text('Key Bit Strength'),
                control: .managed(controller: keyBitStrengthController),
                hint: '2048',
                validator: (v) => Validators.chain([
                  Validators.nonNull,
                  Validators.nonEmpty,
                ], v),
              ),
            if (keyTypeController.value == .ecdsa)
              FSelect<String>.rich(
                control: .managed(controller: keyCurveController),
                label: Text('Elliptic Curve'),
                validator: Validators.nonNull,
                format: (s) => s,
                children: [
                  for (final curve in _KeyType.ecdsa.supportedCurves!)
                    FSelectItem(
                      value: curve,
                      title: Text(curve),
                    ),
                ],
              ),
            FTextFormField.password(
              label: Text('Passphrase (recommended)'),
              control: .managed(controller: passwordController),
            ),
          ],
        ),
      ),
      actions: [
        FButton(
          variant: .outline,
          child: Text('Cancel'),
          onPress: () => Navigator.of(context).pop(),
        ),
        FButton(
          variant: .primary,
          child: Text('Generate'),
          onPress: onGenerateKey,
        ),
      ],
    );
  }
}
