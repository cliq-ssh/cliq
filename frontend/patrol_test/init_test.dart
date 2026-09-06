import 'utils/commons.dart';

void main() {
  patrol('See "No hosts" on initial launch', ($) async {
    await patrolCreateApp($);
    expect(find.text('No hosts'), findsOneWidget);
    expect(
      find.text('Add your first host by clicking the button below.'),
      findsOneWidget,
    );
  });
}
