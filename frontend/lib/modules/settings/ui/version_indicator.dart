import 'dart:async';

import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/utils/build_metadata.dart';
import 'package:cliq_ui/cliq_ui.dart' show CliqFontFamily;
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class const VersionIndicator({super.key}) extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = useState(0);
    final counterTimer = useRef<Timer?>(null);

    return FTappable(
      onPress: () {
        counter.value++;
        counterTimer.value?.cancel();
        counterTimer.value = Timer(const .new(seconds: 1), () {
          counter.value = 0;
        });

        // if the user presses the version indicator 10 times in a row, enable developer mode
        if (counter.value >= 10) {
          counter.value = 0;
          StoreKey.developerMode.write(
            !(StoreKey.developerMode.readSync() ?? false),
          );
        }
      },
      child: Text(
        'v${BuildMetadata.version}+${BuildMetadata.buildNumber} (${BuildMetadata.gitShaShort})',
        style: .new(
          fontFamily: CliqFontFamily.secondary.fontFamily,
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );
  }
}
