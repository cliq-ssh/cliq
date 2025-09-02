part of 'header.dart';

class _CliqProgressHeader extends CliqHeader {
  final double progress;

  const _CliqProgressHeader({
    super.key,
    super.left,
    super.right,
    super.style,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CliqHeader(
      left: left,
      right: right,
      style: style,
      title: CliqProgressBar(progress: progress),
    );
  }
}
