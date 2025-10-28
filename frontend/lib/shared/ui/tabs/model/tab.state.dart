import 'package:cliq/shared/ui/tabs/model/tab.model.dart';

class TabState {
  final List<Tab> tabs;

  const TabState({required this.tabs});

  TabState.initial() : tabs = [];
}
