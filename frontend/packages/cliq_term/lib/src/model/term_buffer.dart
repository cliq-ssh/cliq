import 'package:cliq_term/src/model/cell.dart';

typedef Buff = List<List<Cell>>;

class TermBuffer {
  int x = 0;
  int y = 0;
  late Buff buff;
  TermBuffer(int width, int height) {
    buff = List.generate(height, (_) => List.generate(width, (_) => Cell("")));
  }
}
