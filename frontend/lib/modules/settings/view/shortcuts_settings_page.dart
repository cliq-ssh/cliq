import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/model/page_path.model.dart';
import '../model/keyboard_shortcuts.model.dart';

class ShortcutsSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'shortcuts',
  );

  const ShortcutsSettingsPage({super.key});

  @override
  String get title => 'Shortcuts';

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final shortcuts = useStore(.shortcuts);

    // the type of shortcut currently being recorded, or null if not recording
    final recording = useState<KeyboardShortcutType?>(null);
    // the current reported value of the recording
    final currentRecording = useState<(KeyboardShortcut, String?)?>(null);

    useEffect(() {
      if (recording.value == null) return null;

      bool handler(KeyEvent event) {
        if (event is! KeyDownEvent || event.character?.length != 1) {
          return false;
        }

        final modifiers = <LogicalKeyboardKey>{
          if (HardwareKeyboard.instance.isControlPressed) .control,
          if (HardwareKeyboard.instance.isShiftPressed) .shift,
          if (HardwareKeyboard.instance.isAltPressed) .alt,
          if (HardwareKeyboard.instance.isMetaPressed) .meta,
        };

        if (modifiers.isEmpty) return false; // require at least one modifier

        final shortcut = KeyboardShortcut(
          event.logicalKey,
          modifiers: modifiers,
        );
        currentRecording.value = (shortcut, event.character);
        return true;
      }

      HardwareKeyboard.instance.addHandler(handler);
      return () => HardwareKeyboard.instance.removeHandler(handler);
    }, [recording.value]);

    buildShortcutTile({required KeyboardShortcutType type}) {
      final shortcut = shortcuts.value.shortcuts[type];

      record() {
        recording.value = type;
        currentRecording.value = null;
      }

      saveRecording() {
        if (recording.value == null || currentRecording.value == null) {
          recording.value = null;
          currentRecording.value = null;
          return;
        }

        // save to store
        StoreKey.shortcuts.write(
          shortcuts.value.copyWith(
            shortcuts: {
              ...shortcuts.value.shortcuts,
              recording.value!: currentRecording.value!.$1,
            },
          ),
        );

        recording.value = null;
        currentRecording.value = null;
      }

      buildShortcutPreview() {
        if (shortcut == null) {
          return FButton(
            variant: .outline,
            onPress: record,
            child: Text('Not set'),
          );
        }

        if (recording.value == type && currentRecording.value != null) {
          return ShortcutInfo(shortcut: currentRecording.value!.$1, size: 24);
        }

        return FTappable(
          onPress: record,
          child: ShortcutInfo(shortcut: shortcut, size: 24),
        );
      }

      return FTile(
        title: Text(type.getDisplayName(context)),
        suffix: Row(
          spacing: 8,
          mainAxisSize: .min,
          children: [
            buildShortcutPreview(),
            if (recording.value == type)
              FButton.icon(
                variant: .primary,
                onPress: saveRecording,
                size: .xs,
                child: Icon(LucideIcons.check),
              ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                child: Column(
                  mainAxisAlignment: .center,
                  spacing: 16,
                  children: [
                    FTileGroup(
                      children: [
                        for (final s in KeyboardShortcutType.values)
                          buildShortcutTile(type: s),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
