import 'dart:async';

import 'package:cliq/shared/data/store.dart';
import 'package:cliq_ui/cliq_ui.dart' show CliqFontFamily;
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:forui/forui.dart';

class VersionIndicator extends HookConsumerWidget {
  final PackageInfo packageInfo;

  const VersionIndicator({super.key, required this.packageInfo});

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
        'v${packageInfo.version}+${packageInfo.buildNumber}',
        style: .new(
          fontFamily: CliqFontFamily.secondary.fontFamily,
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );
  }
}
