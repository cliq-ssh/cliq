import 'package:cliq/shared/extensions/async_snapshot.extension.dart';
import 'package:cliq/shared/validators.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../data/credentials/credential_type.dart';
import '../../../data/database.dart';

class AddConnectionView extends StatefulHookConsumerWidget {
  const AddConnectionView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddConnectionPageState();
}

class _AddConnectionPageState extends ConsumerState<AddConnectionView> {
  static const List<(CredentialType, String, IconData)> allowedCredentialTypes =
      [
        (.password, 'Password', LucideIcons.rectangleEllipsis),
        (.key, 'Key', LucideIcons.keyRound),
      ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final labelController = useTextEditingController();
    final addressController = useTextEditingController();
    final portController = useTextEditingController();
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final pemController = useTextEditingController();
    final pemPassphraseController = useTextEditingController();

    final labelPlaceholder = useState('');
    final hasIdentities = useMemoizedFuture(() async {
      return await CliqDatabase.identityService.hasIdentities();
    }, []);

    final additionalCredentialType = useState<CredentialType?>(null);

    buildForm() {
      return Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FTextFormField(
                  label: Text('Label'),
                  hint: labelPlaceholder.value,
                  controller: labelController,
                ),
                FTextFormField(
                  label: Text('Address'),
                  hint: '127.0.0.1',
                  controller: addressController,
                  validator: Validators.address,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChange: (val) => labelPlaceholder.value = val,
                ),
                FTextFormField(
                  label: Text('Port'),
                  hint: '22',
                  controller: portController,
                  validator: Validators.port,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                FTextFormField(
                  label: Text('Username'),
                  hint: 'root',
                  controller: usernameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                if (additionalCredentialType.value == .password)
                  FTextFormField(
                    label: Text('Password'),
                    controller: passwordController,
                    obscureText: true,
                    maxLines: 1,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                if (additionalCredentialType.value == .key) ...[
                  FTextFormField(
                    label: Text('PEM Key'),
                    hint: '-----BEGIN OPENSSH PRIVATE KEY-----',
                    controller: pemController,
                    minLines: 5,
                    maxLines: null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  FTextFormField(
                    label: Text('PEM Passphrase'),
                    controller: pemPassphraseController,
                    obscureText: true,
                    maxLines: 1,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ],
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    hasIdentities.on(
                      defaultValue: SizedBox.shrink(),
                      onData: (hasIdentities) {
                        if (!hasIdentities) {
                          return SizedBox.shrink();
                        }
                        return FButton(
                          style: FButtonStyle.ghost(),
                          prefix: Icon(LucideIcons.keyRound),
                          onPress: null,
                          child: Text('Use Identity'),
                        );
                      },
                    ),
                    FPopoverMenu(
                      menu: [
                        FItemGroup(
                          children: [
                            for (final type in allowedCredentialTypes)
                              FItem(
                                prefix: Icon(type.$3),
                                title: Text(type.$2),
                                onPress: () =>
                                    additionalCredentialType.value = type.$1,
                              ),
                          ],
                        ),
                      ],
                      builder: (context, controller, child) {
                        return FButton(
                          style: FButtonStyle.ghost(),
                          prefix: Icon(LucideIcons.plus),
                          onPress: controller.toggle,
                          child: Text('Add Credential'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FButton(
              child: Text('Save Host'),
              onPress: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                int? credentialId;
                if (additionalCredentialType.value == .password) {
                  credentialId = await CliqDatabase.credentialsRepository
                      .insert(
                        CredentialsCompanion.insert(
                          type: .password,
                          data: passwordController.text,
                        ),
                      );
                } else if (additionalCredentialType.value == .key) {
                  final passphrase = pemPassphraseController.text.trim();
                  credentialId = await CliqDatabase.credentialsRepository
                      .insert(
                        CredentialsCompanion.insert(
                          type: .key,
                          data: pemController.text,
                          passphrase: Value.absentIfNull(
                            passphrase.isNotEmpty ? passphrase : null,
                          ),
                        ),
                      );
                }

                await CliqDatabase.connectionsRepository.insert(
                  ConnectionsCompanion.insert(
                    label: Value.absentIfNull(
                      labelController.text.trim().isNotEmpty
                          ? labelController.text.trim()
                          : null,
                    ),
                    address: addressController.text.trim(),
                    port: int.tryParse(portController.text.trim()) ?? 22,
                    username: Value.absentIfNull(
                      usernameController.text.trim().isNotEmpty
                          ? usernameController.text.trim()
                          : null,
                    ),
                    credentialId: Value.absentIfNull(credentialId),
                    identityId: Value.absent(), // TODO:
                  ),
                );

                // TODO: loading state, success toast
                if (!context.mounted) return;
                context.pop();
              },
            ),
          ),
        ],
      );
    }

    return FScaffold(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: buildForm(),
      ),
    );
  }
}
