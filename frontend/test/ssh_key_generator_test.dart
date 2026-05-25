import 'package:cliq/modules/keys/model/ssh_key_generator.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SshKeyGenerator', () {
    test('generates parseable ED25519 SSH keys', () async {
      final generated = await SshKeyGenerator.generate(
        SshKeyAlgorithm.ed25519,
        comment: 'cliq@test',
      );

      expect(generated.privateKey, startsWith('-----BEGIN '));
      expect(generated.privateKey, contains('PRIVATE KEY-----'));
      expect(generated.publicKey, startsWith(SshKeyAlgorithm.ed25519.sshType));

      final parsed = SSHKeyPair.fromPem(generated.privateKey);
      expect(parsed, isNotEmpty);
      expect(parsed.single.name, SshKeyAlgorithm.ed25519.sshType);
    });

    for (final curveSize in SshEcdsaCurveSize.values) {
      test(
        'generates parseable ECDSA ${curveSize.bits}-bit SSH keys',
        () async {
          final generated = await SshKeyGenerator.generate(
            SshKeyAlgorithm.ecdsa,
            ecdsaCurveSize: curveSize,
            comment: 'cliq@test',
          );

          expect(generated.privateKey, startsWith('-----BEGIN '));
          expect(
            generated.publicKey,
            startsWith('ecdsa-sha2-${curveSize.curveId}'),
          );

          final parsed = SSHKeyPair.fromPem(generated.privateKey);
          expect(parsed, isNotEmpty);
          expect(parsed.single.name, 'ecdsa-sha2-${curveSize.curveId}');
        },
      );
    }

    for (final keySize in SshRsaKeySize.values) {
      test('generates parseable RSA ${keySize.bits}-bit SSH keys', () async {
        final generated = await SshKeyGenerator.generate(
          SshKeyAlgorithm.rsa,
          rsaKeySize: keySize,
          comment: 'cliq@test',
        );

        expect(generated.privateKey, startsWith('-----BEGIN '));
        expect(generated.publicKey, startsWith(SshKeyAlgorithm.rsa.sshType));

        final parsed = SSHKeyPair.fromPem(generated.privateKey);
        expect(parsed, isNotEmpty);
        expect(parsed.single.name, SshKeyAlgorithm.rsa.sshType);
      });
    }
  });
}
