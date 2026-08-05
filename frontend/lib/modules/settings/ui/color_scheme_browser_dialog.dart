import 'package:cliq/modules/settings/extension/color_scheme.extension.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart' show useMemoizedFuture;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iterm2_color_schemes_dart/iterm2_color_schemes_dart.dart'
    deferred as cs;
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/extensions/async_snapshot.extension.dart';
import '../../../shared/ui/horizontal_dialog.dart';
import '../../../shared/utils/platform_utils.dart';

class ColorSchemeBrowserDialog extends HookConsumerWidget {
  final FDialogStyle style;
  final Animation<double> animation;

  const ColorSchemeBrowserDialog({
    super.key,
    required this.style,
    required this.animation,
  });

  static const String sampleInput =
      "\x1b[31mLorem\x1b[0m "
      "\x1b[32mipsum\x1b[0m "
      "\x1b[33mdolor\x1b[0m "
      "\x1b[34msit\x1b[0m "
      "\x1b[35mamet\x1b[0m "
      "\x1b[36mconsectetur\x1b[0m "
      "\x1b[37madipiscing\x1b[0m "
      "elit. "
      "\x1b[1mSuspendisse\x1b[0m "
      "\x1b[3mblandit\x1b[0m "
      "\x1b[4mcondimentum\x1b[0m "
      "\x1b[9msem\x1b[0m "
      "\x1b[7meget\x1b[0m "
      "auctor. Praesent convallis, lacus quis egestas tincidunt, mauris arcu volutpat purus, ut ullamcorper dui turpis nec sapien."
      "\n"
      "${kSeqEscape}7"
      "\r"
      "\x1b[1B"
      "\x1b[40m   \x1b[0m"
      "\x1b[41m   \x1b[0m"
      "\x1b[42m   \x1b[0m"
      "\x1b[43m   \x1b[0m"
      "\x1b[44m   \x1b[0m"
      "\x1b[45m   \x1b[0m"
      "\x1b[46m   \x1b[0m"
      "\x1b[47m   \x1b[0m"
      "\x1b8"
      "\x1b[2B"
      "\r"
      "\x1b[100m   \x1b[0m"
      "\x1b[101m   \x1b[0m"
      "\x1b[102m   \x1b[0m"
      "\x1b[103m   \x1b[0m"
      "\x1b[104m   \x1b[0m"
      "\x1b[105m   \x1b[0m"
      "\x1b[106m   \x1b[0m"
      "\x1b[107m   \x1b[0m\n";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final csFuture = useMemoizedFuture(() => cs.loadLibrary(), []);
    final terminalController = useState<TerminalController?>(null);

    final defaultTerminalTypography = useStore(.defaultTerminalTypography);

    final selectedThemeName = useState<String?>(null);
    final filterText = useState<TextEditingValue>(.new());

    // init controller
    useEffect(() {
      setController() {
        // set default to first theme
        final first = cs.ITerm2ColorSchemes.values.first;
        selectedThemeName.value = first.name;
        terminalController.value = TerminalController(
          theme: first.toTerminalTheme(),
          typography: defaultTerminalTypography.value,
        );
        terminalController.value?.setAutoWrapMode(true);
      }

      cs.loadLibrary().then((_) => setController());
      return () => terminalController.value?.dispose();
    }, []);

    useEffect(() {
      if (terminalController.value == null) return null;
      terminalController.value!.activeBuffer.clear();
      terminalController.value!.feed('${selectedThemeName.value}\n\n\r');
      terminalController.value!.feed(sampleInput);
      return null;
    }, [selectedThemeName.value]);

    final subtitleStyle = context.theme.typography.body.xs.copyWith(
      color: context.theme.colors.mutedForeground,
    );

    return HorizontalDialog(
      style: style,
      animation: animation,
      title: Column(
        spacing: 4,
        crossAxisAlignment: .start,
        children: [
          Text('dialog_color_scheme_browser_title'.tr()),
          Text.rich(
            style: subtitleStyle,
            TextSpan(
              children: TextUtils.renderText(
                context,
                'dialog_color_scheme_browser_subtitle'.tr(),
                style: subtitleStyle,
              ),
            ),
          ),
        ],
      ),
      constraints: .expand(),
      body: Padding(
        padding: const .only(top: 16),
        child: csFuture.on(
          onLoading: () => const Center(child: FCircularProgress()),
          onData: (_) {
            final values = cs.ITerm2ColorSchemes.values
                .where(
                  (theme) => theme.name.toLowerCase().contains(
                    filterText.value.text.toLowerCase(),
                  ),
                )
                .toList();

            final selectedTheme = cs.ITerm2ColorSchemes.values
                .where((theme) => theme.name == selectedThemeName.value)
                .firstOrNull
                ?.toTerminalTheme();

            return Row(
              spacing: 8,
              crossAxisAlignment: .start,
              children: [
                SizedBox(
                  width: 200,
                  child: Column(
                    spacing: 8,
                    children: [
                      FTextField(
                        control: .lifted(
                          value: filterText.value,
                          onChange: (value) => filterText.value = value,
                        ),
                        hint: 'filter'.tr(),
                        prefixBuilder: (_, _, _) => IconTheme(
                          data: context.theme.textFieldStyles.md.iconStyle.base,
                          child: Padding(
                            padding: const .only(left: 8, right: 4),
                            child: Icon(LucideIcons.search),
                          ),
                        ),
                        clearable: (value) => value.text.isNotEmpty,
                      ),
                      if (values.isNotEmpty)
                        Expanded(
                          child: FTileGroup.builder(
                            count: values.length,
                            tileBuilder: (context, index) {
                              final theme = values[index];
                              final isSelected =
                                  selectedThemeName.value == theme.name;

                              return FTile(
                                title: Text(theme.name),
                                selected: isSelected,
                                prefix: isSelected
                                    ? Icon(LucideIcons.check)
                                    : null,
                                onPress: () {
                                  selectedThemeName.value = theme.name;
                                  terminalController.value?.setTerminalTheme(
                                    theme.toTerminalTheme(),
                                  );
                                },
                              );
                            },
                          ),
                        )
                      else
                        Expanded(
                          child: Center(
                            child: Column(
                              spacing: 8,
                              crossAxisAlignment: .center,
                              mainAxisAlignment: .center,
                              children: [
                                Text(
                                  'filters_no_match'.tr(),
                                  textAlign: TextAlign.center,
                                  style: context.theme.typography.body.sm
                                      .copyWith(
                                        color: context
                                            .theme
                                            .colors
                                            .mutedForeground,
                                      ),
                                ),
                                Row(
                                  mainAxisAlignment: .center,
                                  children: [
                                    FButton(
                                      variant: .outline,
                                      onPress: () => filterText.value =
                                          const TextEditingValue(),
                                      child: Text('filters_reset'.tr()),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const FDivider(),
                if (terminalController.value != null)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const .all(8),
                      color: selectedTheme?.backgroundColor,
                      child: LayoutBuilder(
                        builder: (_, constraints) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            terminalController.value!.fitResize(
                              constraints.biggest,
                            );
                          });
                          return TerminalView(
                            controller: terminalController.value!,
                            readOnly: true,
                            isMobile: PlatformUtils.isMobile,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        FButton(
          variant: .outline,
          child: Text('cancel'.tr()),
          onPress: () => Navigator.of(context).pop(),
        ),
        FButton(
          variant: .primary,
          child: Text('import'.tr()),
          onPress: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
