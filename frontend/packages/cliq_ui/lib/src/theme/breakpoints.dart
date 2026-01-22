enum Breakpoint {
  sm,
  md,
  lg,
  xl,
  xxl;

  bool operator <(Breakpoint other) => index < other.index;
  bool operator <=(Breakpoint other) => index <= other.index;
  bool operator >(Breakpoint other) => index > other.index;
  bool operator >=(Breakpoint other) => index >= other.index;
}

typedef BreakpointMap<T> = Map<Breakpoint, T>;

extension BreakpointMapExtension<T> on BreakpointMap<T> {
  BreakpointMap<T> cascadeUp({required T defaultValue}) {
    T last = defaultValue;
    return {for (var b in Breakpoint.values) b: last = (this[b] ?? last)};
  }
}

final class CliqBreakpoints {
  final BreakpointMap<int> breakpointWidths;
  final BreakpointMap<int> nonFluidWidths;

  const CliqBreakpoints({
    this.breakpointWidths = const {
      Breakpoint.sm: 576,
      Breakpoint.md: 768,
      Breakpoint.lg: 992,
      Breakpoint.xl: 1200,
      Breakpoint.xxl: 1400,
    },
    this.nonFluidWidths = const {
      Breakpoint.sm: 540,
      Breakpoint.md: 720,
      Breakpoint.lg: 960,
      Breakpoint.xl: 1140,
      Breakpoint.xxl: 1320,
    },
  }) : assert(
         breakpointWidths.length == Breakpoint.values.length,
         'CliqBreakpoints must define all breakpoints.',
       ),
       assert(
         nonFluidWidths.length == Breakpoint.values.length,
         'CliqBreakpoints must define all non-fluid widths.',
       );

  Breakpoint getBreakpoint(double width) {
    for (final entry in breakpointWidths.entries) {
      if (width < entry.value) {
        return entry.key;
      }
    }
    return Breakpoint.xxl;
  }

  double getNonFluidWidth(double width) {
    for (final entry in Breakpoint.values.reversed) {
      if (width >= breakpointWidths[entry]!) {
        return nonFluidWidths[entry]!.toDouble();
      }
    }
    return width;
  }

  int getMaxWidth(double width) => breakpointWidths[getBreakpoint(width)]!;
}
