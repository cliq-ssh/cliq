import 'package:cliq/shared/data/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../modules/credentials/model/credential_type.dart';
import '../utils/validators.dart';

/// Helper class to define allowed credential types and their properties.
enum _AllowedCredentialType {
  password(
    type: .password,
    label: 'Password',
    icon: LucideIcons.rectangleEllipsis,
    singleInstance: true,
  )
  // TODO: key(type: .key, label: 'Key', icon: LucideIcons.keyRound)
  ;

  final CredentialType type;
  final String label;
  final IconData icon;

  /// Whether only a single instance of this credential type is allowed.
  final bool singleInstance;

  const _AllowedCredentialType({
    required this.type,
    required this.label,
    required this.icon,
    this.singleInstance = false,
  });
}

final class _CredentialData {
  final CredentialType type;
  final TextEditingController dataController = TextEditingController();
  final TextEditingController passphraseController = TextEditingController();

  _CredentialData({
    required this.type,
    String? initialData,
    String? initialPassphrase,
  }) {
    if (initialData != null) {
      dataController.text = initialData;
    }
    if (initialPassphrase != null) {
      passphraseController.text = initialPassphrase;
    }
  }

  void dispose() {
    dataController.dispose();
    passphraseController.dispose();
  }
}

class CreateOrEditCredentialsForm extends StatefulHookConsumerWidget {
  final List<int>? current;
  final bool isEdit;

  const CreateOrEditCredentialsForm.create({super.key})
    : current = null,
      isEdit = false;

  const CreateOrEditCredentialsForm.edit(this.current, {super.key})
    : isEdit = true;

  @override
  ConsumerState<CreateOrEditCredentialsForm> createState() =>
      CreateOrEditCredentialsFormState();
}

class CreateOrEditCredentialsFormState
    extends ConsumerState<CreateOrEditCredentialsForm> {
  late final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final ValueNotifier<List<_CredentialData>> _selectedCredentials;

  @override
  void initState() {
    super.initState();
    _selectedCredentials = ValueNotifier<List<_CredentialData>>([]);
  }

  Future<List<int>?> save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return null;
    }

    // TODO save logic
    final ids = <int>[];
    for (final data in _selectedCredentials.value) {
      if (widget.isEdit) {
        // TODO: handle edit case
      } else {
        ids.add(
          await CliqDatabase.credentialService.create(
            data.type,
            data.dataController.text,
            data.passphraseController.text.isNotEmpty
                ? data.passphraseController.text
                : null,
          ),
        );
      }
    }

    return ids;
  }

  @override
  void dispose() {
    for (final credential in _selectedCredentials.value) {
      credential.dispose();
    }
    _selectedCredentials.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      if (widget.current != null) {
        CliqDatabase.credentialService.findByIds(widget.current!).then((creds) {
          _selectedCredentials.value = creds.map((c) {
            return _CredentialData(
              type: c.type,
              initialData: c.type == .password ? c.password : c.key?.privatePem,
              initialPassphrase: c.type == .key ? c.key?.passphrase : null,
            );
          }).toList();
        });
      }

      return null;
    }, []);

    return Form(
      key: _formKey,
      child: ValueListenableBuilder(
        valueListenable: _selectedCredentials,
        builder: (_, selectedCredentials, _) {
          buildCredentialLabel(_CredentialData credential) {
            final allowedType = _AllowedCredentialType.values.firstWhere(
              (e) => e.type == credential.type,
            );

            return Row(
              spacing: 8,
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(allowedType.label),
                FButton.icon(
                  style: FButtonStyle.ghost(),
                  onPress: () {
                    credential.dispose();
                    final updated = [...selectedCredentials];
                    updated.remove(credential);
                    _selectedCredentials.value = updated;
                  },
                  child: const Icon(LucideIcons.trash, size: 16),
                ),
              ],
            );
          }

          buildFormFields() {
            final children = [];

            for (int i = 0; i < selectedCredentials.length; i++) {
              final data = selectedCredentials[i];
              final allowedType = _AllowedCredentialType.values.firstWhere(
                (e) => e.type == data.type,
              );
              children.add(switch (allowedType) {
                .password => FTextFormField(
                  control: .managed(controller: data.dataController),
                  label: buildCredentialLabel(data),
                  minLines: 1,
                  obscureText: true,
                  validator: Validators.nonEmpty,
                  autovalidateMode: .onUserInteraction,
                ),
              });
            }

            return children;
          }

          return Column(
            spacing: 16,
            children: [
              ...buildFormFields(),

              // check if there are any allowed credential types left to add
              if (_AllowedCredentialType.values.any(
                (a) =>
                    !a.singleInstance ||
                    !selectedCredentials.any((e) => e.type == a.type),
              ))
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    FPopoverMenu(
                      menu: [
                        FItemGroup(
                          children: [
                            for (final allowed in _AllowedCredentialType.values)
                              if (!allowed.singleInstance ||
                                  !selectedCredentials.any(
                                    (e) => e.type == allowed.type,
                                  ))
                                FItem(
                                  prefix: Icon(allowed.icon),
                                  title: Text(allowed.label),
                                  onPress: () {
                                    final updated = [
                                      ...selectedCredentials,
                                      _CredentialData(type: allowed.type),
                                    ];
                                    _selectedCredentials.value = updated;
                                  },
                                ),
                          ],
                        ),
                      ],
                      builder: (context, controller, child) {
                        return FButton(
                          style: FButtonStyle.ghost(),
                          prefix: const Icon(LucideIcons.plus),
                          onPress: controller.toggle,
                          child: Flexible(
                            child: const Text('Add Authentication Method'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
