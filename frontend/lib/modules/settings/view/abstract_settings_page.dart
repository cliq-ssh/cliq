import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';

import '../../../shared/ui/commons.dart';

abstract class AbstractSettingsPage extends StatelessWidget {
  const AbstractSettingsPage({super.key});

  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return CliqScaffold(
      extendBehindAppBar: true,
      header: CliqHeader(left: [Commons.backButton(context)]),
      body: buildBody(context),
    );
  }
}
