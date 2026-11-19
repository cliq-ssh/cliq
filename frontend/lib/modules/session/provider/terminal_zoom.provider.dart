import 'package:hooks_riverpod/hooks_riverpod.dart';

final terminalZoomProvider =
    NotifierProvider<TerminalZoomNotifier, Map<String, double>>(
      TerminalZoomNotifier.new,
    );

class TerminalZoomNotifier extends Notifier<Map<String, double>> {
  static const double _step = 1;
  static const double _min = -8;
  static const double _max = 24;

  @override
  Map<String, double> build() => const {};

  void zoomIn(String sessionId) =>
      _set(sessionId, (state[sessionId] ?? 0) + _step);
  void zoomOut(String sessionId) =>
      _set(sessionId, (state[sessionId] ?? 0) - _step);
  void reset(String sessionId) => state = {...state}..remove(sessionId);

  void _set(String sessionId, double value) {
    state = {...state, sessionId: value.clamp(_min, _max)};
  }
}
