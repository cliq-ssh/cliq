import 'package:cliq/modules/keys/provider/key.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/extensions/async_snapshot.extension.dart';
import 'package:cliq_ui/cliq_ui.dart' show useMemoizedFuture;
import 'package:cliq_ui/hooks/use_breakpoint.export.dart' show useBreakpoint;
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../modules/credentials/model/credential_type.dart';
import '../../modules/keys/view/create_or_edit_key_view.dart';
import '../utils/commons.dart';
import '../utils/validators.dart';

/// Helper class to define allowed credential types and their properties.
enum _AllowedCredentialType {
  password(
    type: .password,
    label: 'Password',
    icon: LucideIcons.rectangleEllipsis,
    singleInstance: true,
  ),
  key(type: .key, label: 'Key', icon: LucideIcons.keyRound);

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
  final int? id;
  final CredentialType type;
  final FAutocompleteController controller = FAutocompleteController();

  _CredentialData({required this.id, required this.type, String? initialData}) {
    if (initialData != null) {
      controller.text = initialData;
    }
  }

  void dispose() => controller.dispose();
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
  late final FocusNode _focusNode = FocusNode();
  late final ValueNotifier<List<_CredentialData>> _selectedCredentials;

  @override
  void initState() {
    super.initState();
    _selectedCredentials = ValueNotifier<List<_CredentialData>>([]);
  }

  static String toAutocompleteString(int keyId, String keyLabel) {
    return '${keyLabel.trim()} ($keyId)';
  }

  static (int? keyId, String? keyLabel) fromAutocompleteString(String value) {
    final match = RegExp(r'^(.*) \((\d+)\)$').firstMatch(value);
    if (match != null) {
      final label = match.group(1)!.trim();
      final id = int.parse(match.group(2)!);
      return (id, label);
    }
    return (null, null);
  }

  /// Saves the current state of the form.
  /// Validates the form and creates or updates credentials as necessary.
  /// Returns a list of created credential IDs, or null if validation fails.
  Future<List<int>?> save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return null;
    }

    final createdIds = <int>[];
    final modifiedIds = <int>[];
    for (final data in _selectedCredentials.value) {
      final controllerData = switch (data.type) {
        .key => fromAutocompleteString(data.controller.text).$1!.toString(),
        .password => data.controller.text,
      };

      if (data.id != null) {
        modifiedIds.add(
          await CliqDatabase.credentialService.update(
            data.id!,
            data.type,
            controllerData,
          ),
        );
      } else {
        createdIds.add(
          await CliqDatabase.credentialService.create(
            data.type,
            controllerData,
          ),
        );
      }
    }

    // check for removed/deleted credentials (in edit mode)
    if (widget.isEdit && widget.current != null) {
      final remaining = widget.current!
          .where((id) => ![...createdIds, ...modifiedIds].contains(id))
          .toList();
      if (remaining.isNotEmpty) {
        await CliqDatabase.credentialService.deleteByIds(remaining);
      }
    }

    return createdIds;
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
    final breakpoint = useBreakpoint();
    final popoverController = useFPopoverController();
    final keyIds = ref.watch(keyIdProvider);
    final keysFuture = useMemoizedFuture(() async {
      return await CliqDatabase.keysService.findByIds(keyIds.entities);
    }, [keyIds]);
    useEffect(() {
      if (widget.current != null) {
        CliqDatabase.credentialService.findByIds(widget.current!).then((creds) {
          _selectedCredentials.value = creds.map((c) {
            return _CredentialData(
              id: c.id,
              type: c.type,
              initialData: switch (c.type) {
                .password => c.password,
                .key => toAutocompleteString(c.key!.id, c.key!.label),
              },
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
                  control: .managed(controller: data.controller),
                  focusNode: _focusNode,
                  label: buildCredentialLabel(data),
                  minLines: 1,
                  obscureText: true,
                  validator: Validators.nonEmpty,
                  autovalidateMode: .onUserInteraction,
                ),
                .key => FAutocomplete.builder(
                  control: .managed(controller: data.controller),
                  filter: (query) async {
                    return keysFuture.on(
                      onLoading: () => [],
                      onData: (keys) {
                        final values = keys.map(
                          (k) => toAutocompleteString(k.id, k.label),
                        );
                        if (query.isEmpty) {
                          return values;
                        }
                        return values.where(
                          (v) => v.toLowerCase().contains(query.toLowerCase()),
                        );
                      },
                    );
                  },
                  contentEmptyBuilder: (_, _) => GestureDetector(
                    onTap: () async {
                      final result = await Commons.showResponsiveDialog(
                        context,
                        breakpoint,
                        (_) => CreateOrEditKeyView.create(
                          initialLabel: data.controller.text.isEmpty
                              ? null
                              : data.controller.text.trim(),
                        ),
                      );
                      if (result != null) {
                        _focusNode.unfocus();
                        final newText = toAutocompleteString(
                          result.$1,
                          result.$2,
                        );
                        data.controller.text = newText;
                      }
                    },
                    child: Padding(
                      padding: const .symmetric(horizontal: 8, vertical: 14),
                      child: Row(
                        spacing: 4,
                        mainAxisAlignment: .center,
                        children: [
                          Icon(
                            LucideIcons.plus,
                            size: 16,
                            color: context.theme.colors.foreground,
                          ),
                          data.controller.text.isEmpty
                              ? Text('Create Key')
                              : Text('Create Key "${data.controller.text}"'),
                        ],
                      ),
                    ),
                  ),
                  contentBuilder: (context, text, suggestions) => [
                    for (final suggestion in suggestions)
                      FAutocompleteItem(
                        prefix: Icon(LucideIcons.keyRound),
                        title: Text(
                          fromAutocompleteString(suggestion).$2 ?? suggestion,
                        ),
                        value: suggestion,
                      ),
                  ],
                  focusNode: _focusNode,
                  label: buildCredentialLabel(data),
                  minLines: 1,
                  validator: (s) {
                    final empty = Validators.nonEmpty(s);
                    if (empty != null) {
                      return empty;
                    }
                    final (id, label) = fromAutocompleteString(s ?? '');
                    if (id == null ||
                        (keysFuture.hasData &&
                            !keysFuture.data!.any((k) => k.id == id))) {
                      return 'Please select a valid key.';
                    }
                    return null;
                  },
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
                      control: .managed(controller: popoverController),
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
                                    popoverController.hide();
                                    final updated = [
                                      ...selectedCredentials,
                                      _CredentialData(
                                        id: null,
                                        type: allowed.type,
                                      ),
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
