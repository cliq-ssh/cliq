import 'package:cliq/data/sqlite/credentials/credential_type.dart';
import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/shared/validators.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  final TextEditingController _pemController = TextEditingController();
  final TextEditingController _pemPasswordController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _pemController.dispose();
    _pemPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                              hint: Text('My Host'),
                              controller: _labelController,
                            ),
                            CliqTextFormField(
                              label: Text('Address'),
                              hint: Text('127.0.0.1'),
                              controller: _addressController,
                              validator: Validators.address,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onChanged: (val) {
                                if (_labelController.text.isEmpty) {
                                  _labelController.text = val;
                                }
                              },
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
                            CliqTextFormField(
                              label: Text('Private Key (PEM)'),
                              hint: Text('-----BEGIN OPENSSH PRIVATE KEY-----'),
                              controller: _pemController,
                              validator: Validators.pem,
                              minLines: 1,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            CliqTextFormField(
                              label: Text('Private Key Password'),
                              hint: Text('secret'),
                              controller: _pemPasswordController,
                              obscure: true,
                              maxLines: 1,
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

                            // TODO: refactor to support multiple credentials, identity selector
                            print(_addressController.text);

                            final credentialId = await CliqDatabase
                                .credentialsRepository
                                .insert(
                                  CredentialsCompanion.insert(
                                    type: CredentialType.key,
                                    secret: Value(_pemController.text.trim()),
                                    passphrase: Value(
                                      _pemPasswordController.text.trim(),
                                    ),
                                  ),
                                );
                            final identityId = await CliqDatabase
                                .identityService
                                .createIdentity(
                                  IdentitiesCompanion.insert(
                                    username: _usernameController.text.trim(),
                                  ),
                                  [credentialId],
                                );
                            await CliqDatabase.connectionsRepository.insert(
                              ConnectionsCompanion.insert(
                                address: _addressController.text.trim(),
                                port: Value.absentIfNull(
                                  int.tryParse(_portController.text.trim()),
                                ),
                                identityId: identityId,
                              ),
                            );

                            // TODO: loading state, success toast
                            if (!mounted) return;
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
