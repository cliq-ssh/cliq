import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/model/connection_icons.dart';
import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/model/tab.model.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ConnectionFull buildConnection() {
    return ConnectionFull.fromConnection(
      Connection(
        id: 1,
        vaultId: 1,
        label: 'Example',
        address: '127.0.0.1',
        port: 22,
        icon: ConnectionIcons.server,
        iconColor: const Color(0xFF000000),
        iconBackgroundColor: const Color(0xFFFFFFFF),
        usesDefaultThemeOverride: true,
      ),
      credentialIds: const [],
      vault: const Vault(id: 1, label: 'Vault', isDefault: true),
    );
  }

  test('copyWith keeps custom label when updating sessions', () {
    final connection = buildConnection();
    final root = ShellSession.disconnected(
      id: 'root',
      connection: connection,
      type: .ssh,
    );
    final tab = SessionTab(
      id: 'tab',
      root: root,
      sessions: const [],
      label: 'Custom label',
    );

    final updated = tab.copyWith(sessions: [root]);

    expect(updated.label, 'Custom label');
  });

  test('copyWith can explicitly clear the label', () {
    final connection = buildConnection();
    final root = ShellSession.disconnected(
      id: 'root',
      connection: connection,
      type: .ssh,
    );
    final tab = SessionTab(
      id: 'tab',
      root: root,
      sessions: const [],
      label: 'Custom label',
    );

    final updated = tab.copyWith(clearLabel: true);

    expect(updated.label, isNull);
  });
}
