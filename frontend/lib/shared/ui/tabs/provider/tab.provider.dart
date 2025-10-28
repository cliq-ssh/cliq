import 'package:riverpod/riverpod.dart';

import '../model/tab.state.dart';


final NotifierProvider<TabNotifier, TabState> tabProvider = NotifierProvider(TabNotifier.new);

class TabNotifier extends Notifier<TabState> {
  @override
  TabState build() => TabState.initial();
}
