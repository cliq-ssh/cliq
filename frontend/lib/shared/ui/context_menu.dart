import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomContextMenuAction {
  final String label;
  final IconData? icon;
  final VoidCallback onPress;
  final bool hideAfterPress;
  final ShortcutActionInfo? shortcut;

  CustomContextMenuAction({
    required this.label,
    this.icon,
    required this.onPress,
    this.hideAfterPress = true,
    this.shortcut,
  });
}

class CustomContextMenu extends HookConsumerWidget {
  final List<CustomContextMenuAction> actions;
  final WidgetBuilder builder;
  final FPopoverController? popoverController;

  const CustomContextMenu({
    super.key,
    required this.actions,
    required this.builder,
    this.popoverController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managedPopoverController = useFPopoverController();

    if (PlatformUtils.isMobile) {
      return builder(context);
    }

    onPress(CustomContextMenuAction action) async {
      if (action.hideAfterPress) {
        await (popoverController ?? managedPopoverController).hide();
      }
      action.onPress();
    }

    return CallbackShortcuts(
      bindings: {
        for (final action in actions)
          if (action.shortcut != null)
            SingleActivator(
              action.shortcut!.mainKey,
              alt: action.shortcut!.modifiers.contains(LogicalKeyboardKey.alt),
              control: action.shortcut!.modifiers.contains(
                LogicalKeyboardKey.control,
              ),
              meta: action.shortcut!.modifiers.contains(
                LogicalKeyboardKey.meta,
              ),
              shift: action.shortcut!.modifiers.contains(
                LogicalKeyboardKey.shift,
              ),
            ): () =>
                onPress(action),
      },
      child: FPopoverMenu(
        autofocus: true,
        control: .managed(
          controller: popoverController ?? managedPopoverController,
        ),
        menu: [
          FItemGroup(
            children: [
              for (final action in actions)
                FItem(
                  prefix: action.icon != null ? Icon(action.icon) : null,
                  title: action.shortcut == null
                      ? Text(action.label)
                      : Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Flexible(child: Text(action.label)),
                            ShortcutInfo(shortcut: action.shortcut!),
                          ],
                        ),
                  onPress: () => onPress(action),
                ),
            ],
          ),
        ],
        builder: (context, controller, _) {
          return GestureDetector(
            onSecondaryTap: controller.toggle,
            child: builder(context),
          );
        },
      ),
    );
  }
}
