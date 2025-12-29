import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/model/page_path.model.dart';
import '../provider/sync.provider.dart';

class SyncSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'sync',
  );

  const SyncSettingsPage({super.key});

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncProvider);

    final serverUrl = useState<RouteOptions?>(null);

    final registerUsernameController = useTextEditingController();
    final registerEmailController = useTextEditingController();
    final registerPasswordController = useTextEditingController();

    final loginEmailController = useTextEditingController();
    final loginPasswordController = useTextEditingController();

    buildLoggedIn() {
      return Column(
        children: [
          FButton(
            style: FButtonStyle.destructive(),
            onPress: () {
              ref.read(syncProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      );
    }

    buildNotLoggedIn() {
      return Column(
        spacing: 20,
        children: [
          FTextField(
            control: .managed(
              onChange: (url) async {
                final uri = Uri.tryParse(url.text);
                if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                  serverUrl.value = null;
                  return;
                }

                try {
                  final routeOptions = RouteOptions()..hostUri = uri;
                  final status = await CliqClient.retrieveHealthStatus(
                    routeOptions,
                  );

                  if (status != 'DOWN') {
                    serverUrl.value = routeOptions;
                  }
                } catch (e) {
                  serverUrl.value = null;
                }
              },
              initial: TextEditingValue(
                text: StoreKey.syncHostUrl.readSync() ?? '',
              ),
            ),
            label: const Text('Server URL'),
            hint: 'https://sync.example.com',
            error: serverUrl.value == null ? Text('Invalid URL') : null,
          ),
          FTabs(
            children: [
              FTabEntry(
                label: const Text('Login'),
                child: FCard(
                  title: const Text('Login'),
                  subtitle: const Text(
                    'Login to your account to sync your data across devices.',
                  ),
                  child: Form(
                    child: Column(
                      spacing: 10,
                      children: [
                        FTextFormField.email(
                          control: .managed(controller: loginEmailController),
                          label: Text('Email'),
                          hint: 'john@doe.com',
                        ),
                        FTextFormField.password(
                          control: .managed(
                            controller: loginPasswordController,
                          ),
                          label: Text('Password'),
                        ),
                        const SizedBox.shrink(),
                        FButton(
                          onPress: () {
                            if (serverUrl.value == null) {
                              return;
                            }
                            final email = loginEmailController.text;
                            final password = loginPasswordController.text;

                            ref
                                .read(syncProvider.notifier)
                                .login(serverUrl.value!, email, password);
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FTabEntry(
                label: const Text('Register'),
                child: FCard(
                  title: const Text('Register'),
                  subtitle: const Text(
                    'Register a new account to start syncing your data across devices.',
                  ),
                  child: Column(
                    spacing: 10,
                    children: [
                      FTextFormField(
                        control: .managed(
                          controller: registerUsernameController,
                        ),
                        label: Text('Name'),
                        hint: 'John Doe',
                      ),
                      FTextFormField.email(
                        control: .managed(controller: registerEmailController),
                        label: Text('Email'),
                        hint: 'john@doe.com',
                      ),
                      FTextFormField.password(
                        control: .managed(
                          controller: registerPasswordController,
                        ),
                        label: Text('Password'),
                      ),
                      const SizedBox.shrink(),
                      FButton(
                        onPress: () {
                          if (serverUrl.value == null) {
                            return;
                          }
                          final username = registerUsernameController.text;
                          final email = registerEmailController.text;
                          final password = registerPasswordController.text;

                          ref
                              .read(syncProvider.notifier)
                              .register(
                                serverUrl.value!,
                                username,
                                email,
                                password,
                              );
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return CliqGridContainer(
      children: [
        CliqGridRow(
          children: [
            CliqGridColumn(
              sizes: {.sm: 12, .md: 8},
              child: SingleChildScrollView(
                child: sync.api != null ? buildLoggedIn() : buildNotLoggedIn(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
