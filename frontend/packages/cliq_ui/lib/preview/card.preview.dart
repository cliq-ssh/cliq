part of '_preview.dart';

@Preview(name: 'CliqCard', wrapper: previewWrapper)
Widget cardPreview() {
  return CliqCard(
    title: Text('Card Title'),
    subtitle: Text('Card Subtitle'),
    leading: Icon(LucideIcons.image),
    trailing: Icon(LucideIcons.chevronRight),
    onTap: () {},
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('This is a card preview.'),
    ),
  );
}
