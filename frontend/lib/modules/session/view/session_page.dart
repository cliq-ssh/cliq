import 'package:cliq/modules/session/model/session.model.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SSHSessionPage extends StatefulHookConsumerWidget {
  final SSHSession session;

  const SSHSessionPage({super.key, required this.session});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SSHSessionPageState();
}

class _SSHSessionPageState extends ConsumerState<SSHSessionPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final counter = useState(0);

    return FScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SSH Session Page for ${widget.session.id}'),
            SizedBox(height: 16),
            Text('Counter: ${counter.value}'),
            SizedBox(height: 16),
            FButton(
              child: Text('Increment Counter'),
              onPress: () {
                counter.value++;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
