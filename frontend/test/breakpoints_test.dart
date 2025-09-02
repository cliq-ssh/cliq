import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Breakpoint Cascade', () {
    test('empty cascade (default)', () {
      final BreakpointMap<int> input = {};
      final BreakpointMap<int> result = input.cascadeUp(defaultValue: 12);

      expect(result[Breakpoint.sm], 12);
      expect(result[Breakpoint.md], 12);
      expect(result[Breakpoint.lg], 12);
      expect(result[Breakpoint.xl], 12);
      expect(result[Breakpoint.xxl], 12);
    });

    test('minimum cascade', () {
      final BreakpointMap<int> input = {Breakpoint.sm: 4};
      final BreakpointMap<int> result = input.cascadeUp(defaultValue: 12);

      for (final breakpoint in Breakpoint.values) {
        expect(result[breakpoint], 4);
      }
    });

    test('specific cascade', () {
      final BreakpointMap<int> input = {
        Breakpoint.sm: 1,
        Breakpoint.md: 2,
        Breakpoint.lg: 3,
        Breakpoint.xl: 4,
        Breakpoint.xxl: 5,
      };
      final BreakpointMap<int> result = input.cascadeUp(defaultValue: 12);

      expect(result[Breakpoint.sm], 1);
      expect(result[Breakpoint.md], 2);
      expect(result[Breakpoint.lg], 3);
      expect(result[Breakpoint.xl], 4);
      expect(result[Breakpoint.xxl], 5);
    });

    test('mixed cascade', () {
      final BreakpointMap<int> input = {Breakpoint.md: 1, Breakpoint.xl: 4};
      final BreakpointMap<int> result = input.cascadeUp(defaultValue: 12);

      expect(result[Breakpoint.sm], 12);
      expect(result[Breakpoint.md], 1);
      expect(result[Breakpoint.lg], 1);
      expect(result[Breakpoint.xl], 4);
      expect(result[Breakpoint.xxl], 4);
    });
  });
}
