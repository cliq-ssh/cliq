import 'package:test/test.dart';
import 'package:cliq_term/src/parser/csi_parser.dart';

void main() {
  late CsiParser parser;

  setUp(() {
    parser = CsiParser();
  });

  group('SGR', () {
    test('"[m" -> empty params, final m', () {
      final r = parser.parseCsi('[m');
      expect(r.leader, isNull);
      expect(r.intermediates, isEmpty);
      expect(r.params, isEmpty);
      expect(String.fromCharCode(r.finalByteCode), 'm');
    });

    test('"[1;32m" -> params [1,32], final m', () {
      final r = parser.parseCsi('[1;32m');
      expect(r.leader, isNull);
      expect(r.intermediates, isEmpty);
      expect(r.params, orderedEquals(<int?>[1, 32]));
      expect(String.fromCharCode(r.finalByteCode), 'm');
    });

    test('"[38;5;198m" -> params [38,5,198]', () {
      final r = parser.parseCsi('[38;5;198m');
      expect(r.params, orderedEquals(<int?>[38, 5, 198]));
      expect(String.fromCharCode(r.finalByteCode), 'm');
    });

    test('"[38;2;255;0;0m" -> params [38,2,255,0,0] (truecolor)', () {
      final r = parser.parseCsi('[38;2;255;0;0m');
      expect(r.params, orderedEquals(<int?>[38, 2, 255, 0, 0]));
      expect(String.fromCharCode(r.finalByteCode), 'm');
    });

    test('"[00m" -> leading zeros parsed as 0', () {
      final r = parser.parseCsi('[00m');
      expect(r.params, orderedEquals(<int?>[0]));
      expect(String.fromCharCode(r.finalByteCode), 'm');
    });
  });

  test('CUU: "[5A" -> params [5], final A', () {
    final r = parser.parseCsi('[5A');
    expect(r.params, orderedEquals(<int?>[5]));
    expect(String.fromCharCode(r.finalByteCode), 'A');
  });

  test('SR: "[10 A" -> space as intermediate', () {
    final r = parser.parseCsi('[10 A'); // note: single space before 'A'
    expect(r.params, orderedEquals(<int?>[10]));
    expect(r.intermediates, ' ');
    expect(String.fromCharCode(r.finalByteCode), 'A');
  });

  test('Private/DEC: "[?25l" -> leader "?", params [25], final l', () {
    final r = parser.parseCsi('[?25l');
    expect(r.leader, '?');
    expect(r.params, orderedEquals(<int?>[25]));
    expect(String.fromCharCode(r.finalByteCode), 'l');
  });

  test('ED: "[2J" -> params [2], final J', () {
    final r = parser.parseCsi('[2J');
    expect(r.params, orderedEquals(<int?>[2]));
    expect(String.fromCharCode(r.finalByteCode), 'J');
  });

  test('CUP: "[12;40H" -> params [12,40], final H', () {
    final r = parser.parseCsi('[12;40H');
    expect(r.params, orderedEquals(<int?>[12, 40]));
    expect(String.fromCharCode(r.finalByteCode), 'H');
  });

  test('EL: "[K" -> no params, final K', () {
    final r = parser.parseCsi('[K');
    expect(r.params, isEmpty);
    expect(String.fromCharCode(r.finalByteCode), 'K');
  });

  test('Empty body -> throws ArgumentError (invalid CSI body)', () {
    expect(() => parser.parseCsi(''), throwsArgumentError);
  });

  test('Empty parameter tokens: "[;m" -> params [null, null]', () {
    final r = parser.parseCsi('[;m');
    expect(r.params.length, 2);
    expect(r.params[0], isNull);
    expect(r.params[1], isNull);
    expect(String.fromCharCode(r.finalByteCode), 'm');
  });
}
