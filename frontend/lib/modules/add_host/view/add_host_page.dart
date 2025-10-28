import 'package:cliq/data/sqlite/credentials/credential_type.dart';
import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/shared/extensions/async_snapshot.extension.dart';
import 'package:cliq/shared/ui/future_wrapper.dart';
import 'package:cliq/shared/validators.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../routing/page_path.dart';
import '../../../shared/ui/commons.dart';

class AddHostsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/hosts');

  const AddHostsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddHostsPageState();
}

class _AddHostsPageState extends ConsumerState<AddHostsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pemController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelPlaceholder = useState('');
    final hasIdentities = useMemoizedFuture(() async {
      return await CliqDatabase.identityService.hasIdentities();
    }, []);

    final additionalCredentialType = useState<CredentialType?>(null);

    return CliqScaffold(
      extendBehindAppBar: true,
      header: CliqHeader(
        title: Text('Add Host'),
        left: [Commons.backButton(context)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 80),
        child: CliqGridContainer(
          children: [
            CliqGridRow(
              alignment: WrapAlignment.center,
              children: [
                CliqGridColumn(
                  sizes: {Breakpoint.lg: 8, Breakpoint.xl: 6},
                  child: Column(
                    spacing: 24,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          spacing: 16,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CliqTextFormField(
                              label: Text('Label'),
                              hint: Text(labelPlaceholder.value),
                              controller: _labelController,
                            ),
                            CliqTextFormField(
                              label: Text('Address'),
                              hint: Text('127.0.0.1'),
                              controller: _addressController,
                              validator: Validators.address,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onChanged: (val) => labelPlaceholder.value = val,
                            ),
                            CliqTextFormField(
                              label: Text('Port'),
                              hint: Text('22'),
                              controller: _portController,
                              validator: Validators.port,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            CliqTextFormField(
                              label: Text('Username'),
                              hint: Text('root'),
                              controller: _usernameController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            if (additionalCredentialType.value ==
                                CredentialType.password)
                              CliqTextFormField(
                                label: Text('Password'),
                                hint: Text('••••••••'),
                                controller: _passwordController,
                                obscure: true,
                                maxLines: 1,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            if (additionalCredentialType.value ==
                                CredentialType.key)
                              CliqTextFormField(
                                label: Text('PEM Key'),
                                hint: Text(
                                  '-----BEGIN OPENSSH PRIVATE KEY-----',
                                ),
                                controller: _pemController,
                                minLines: 5,
                                maxLines: null,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
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
                                    return CliqIconButton(
                                      icon: Icon(LucideIcons.keyRound),
                                      label: Text('Use Identity'),
                                    );
                                  },
                                ),
                                CliqLink(
                                  icon: Icon(LucideIcons.keyRound),
                                  label: TextSpan(text: 'Use Identity'),
                                ),
                                // TODO: implement context menu to select credential type
                                if (additionalCredentialType.value !=
                                    CredentialType.key)
                                  CliqLink(
                                    icon: Icon(LucideIcons.plus),
                                    label: TextSpan(
                                      text:
                                          additionalCredentialType.value == null
                                          ? 'Add Key'
                                          : 'Use Key',
                                    ),
                                    onPressed: () =>
                                        additionalCredentialType.value =
                                            CredentialType.key,
                                  ),
                                if (additionalCredentialType.value !=
                                    CredentialType.password)
                                  CliqLink(
                                    icon: Icon(LucideIcons.plus),
                                    label: TextSpan(
                                      text:
                                          additionalCredentialType.value == null
                                          ? 'Add Password'
                                          : 'Use Password',
                                    ),
                                    onPressed: () =>
                                        additionalCredentialType.value =
                                            CredentialType.password,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: CliqButton(
                          label: Text('Save Host'),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            int? credentialId;
                            if (additionalCredentialType.value ==
                                CredentialType.password) {
                              credentialId = await CliqDatabase
                                  .credentialsRepository
                                  .insert(
                                    CredentialsCompanion.insert(
                                      type: CredentialType.password,
                                      data: _passwordController.text,
                                    ),
                                  );
                            } else if (additionalCredentialType.value ==
                                CredentialType.key) {
                              credentialId = await CliqDatabase
                                  .credentialsRepository
                                  .insert(
                                    CredentialsCompanion.insert(
                                      type: CredentialType.key,
                                      data: _pemController.text,
                                    ),
                                  );
                            }

                            await CliqDatabase.connectionsRepository.insert(
                              ConnectionsCompanion.insert(
                                label: Value.absentIfNull(
                                  _labelController.text.trim().isNotEmpty
                                      ? _labelController.text.trim()
                                      : null,
                                ),
                                address: _addressController.text.trim(),
                                port:
                                    int.tryParse(_portController.text.trim()) ??
                                    22,
                                username: Value.absentIfNull(
                                  _usernameController.text.trim().isNotEmpty
                                      ? _usernameController.text.trim()
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
