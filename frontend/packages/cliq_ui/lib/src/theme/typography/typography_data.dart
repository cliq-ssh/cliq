import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';

final class CliqTypographyData {
  final BreakpointMap<CliqTextStyle> h1;
  final BreakpointMap<CliqTextStyle> h2;
  final BreakpointMap<CliqTextStyle> h3;
  final BreakpointMap<CliqTextStyle> h4;
  final BreakpointMap<CliqTextStyle> h5;
  final BreakpointMap<CliqTextStyle> copyXL;
  final BreakpointMap<CliqTextStyle> copyL;
  final BreakpointMap<CliqTextStyle> copyM;
  final BreakpointMap<CliqTextStyle> copyS;
  final BreakpointMap<CliqTextStyle> copyXS;

  const CliqTypographyData({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.h5,
    required this.copyXL,
    required this.copyL,
    required this.copyM,
    required this.copyS,
    required this.copyXS,
  });

  factory CliqTypographyData.inherit({required CliqColorScheme colorScheme}) {
    final baseStyle = TextStyle(
      fontFamily: CliqFontFamily.primary.fontFamily,
      color: colorScheme.onBackground,
      fontWeight: FontWeight.w400,
    );

    final headlineStyle = baseStyle.copyWith(
      fontFamily: CliqFontFamily.secondary.fontFamily,
      fontWeight: FontWeight.w700,
    );

    final BreakpointMap<CliqTextStyle> h1 = {
      Breakpoint.xl: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 48, height: 60 / 48),
        padding: EdgeInsets.only(bottom: 24),
      ),
      Breakpoint.lg: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 40, height: 50 / 40),
        padding: EdgeInsets.only(bottom: 24),
      ),
      Breakpoint.sm: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 32, height: 40 / 32),
        padding: EdgeInsets.only(bottom: 20),
      ),
    }.cascadeUp(defaultValue: CliqTextStyle(headlineStyle));

    final BreakpointMap<CliqTextStyle> h2 = {
      Breakpoint.xl: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 36, height: 46 / 36),
        padding: EdgeInsets.only(bottom: 32),
      ),
      Breakpoint.lg: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 32, height: 42 / 32),
        padding: EdgeInsets.only(bottom: 32),
      ),
      Breakpoint.sm: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 26, height: 34 / 26),
        padding: EdgeInsets.only(bottom: 32),
      ),
    }.cascadeUp(defaultValue: CliqTextStyle(headlineStyle));

    final BreakpointMap<CliqTextStyle> h3 = {
      Breakpoint.xl: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 28, height: 38 / 28),
        padding: EdgeInsets.only(bottom: 12),
      ),
      Breakpoint.lg: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 26, height: 36 / 26),
        padding: EdgeInsets.only(bottom: 12),
      ),
      Breakpoint.sm: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 24, height: 32 / 24),
        padding: EdgeInsets.only(bottom: 8),
      ),
    }.cascadeUp(defaultValue: CliqTextStyle(headlineStyle));

    final BreakpointMap<CliqTextStyle> h4 = {
      Breakpoint.xl: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 24, height: 32 / 24),
        padding: EdgeInsets.only(bottom: 4),
      ),
      Breakpoint.lg: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 20, height: 30 / 20),
        padding: EdgeInsets.only(bottom: 4),
      ),
      Breakpoint.sm: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 19, height: 29 / 19),
        padding: EdgeInsets.only(bottom: 4),
      ),
    }.cascadeUp(defaultValue: CliqTextStyle(headlineStyle));

    final BreakpointMap<CliqTextStyle> h5 = {
      Breakpoint.xl: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 18, height: 28 / 18),
      ),
      Breakpoint.lg: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 18, height: 28 / 18),
      ),
      Breakpoint.sm: CliqTextStyle(
        headlineStyle.copyWith(fontSize: 17, height: 27 / 17),
      ),
    }.cascadeUp(defaultValue: CliqTextStyle(headlineStyle));

    final BreakpointMap<CliqTextStyle> copyXL = {
      Breakpoint.xl: CliqTextStyle(
        baseStyle.copyWith(fontSize: 28, height: 38 / 28),
      ),
      Breakpoint.lg: CliqTextStyle(
        baseStyle.copyWith(fontSize: 28, height: 38 / 28),
      ),
      Breakpoint.sm: CliqTextStyle(
        baseStyle.copyWith(fontSize: 24, height: 34 / 24),
      ),
    }.cascadeUp(defaultValue: CliqTextStyle(headlineStyle));

    final BreakpointMap<CliqTextStyle> copyL = {
      Breakpoint.xl: CliqTextStyle(
        baseStyle.copyWith(fontSize: 24, height: 34 / 24),
      ),
      Breakpoint.lg: CliqTextStyle(
        baseStyle.copyWith(fontSize: 20, height: 30 / 20),
      ),
      Breakpoint.sm: CliqTextStyle(
        baseStyle.copyWith(fontSize: 19, height: 29 / 19),
      ),
    }.cascadeUp(defaultValue: CliqTextStyle(headlineStyle));

    final BreakpointMap<CliqTextStyle> copyM = {
      Breakpoint.xl: CliqTextStyle(
        baseStyle.copyWith(fontSize: 18, height: 28 / 18),
      ),
      Breakpoint.lg: CliqTextStyle(
        baseStyle.copyWith(fontSize: 18, height: 28 / 18),
      ),
      Breakpoint.sm: CliqTextStyle(
        baseStyle.copyWith(fontSize: 17, height: 27 / 17),
      ),
    }.cascadeUp(defaultValue: CliqTextStyle(headlineStyle));

    final BreakpointMap<CliqTextStyle> copyS = {
      Breakpoint.xl: CliqTextStyle(
        baseStyle.copyWith(fontSize: 15, height: 20 / 15),
      ),
      Breakpoint.lg: CliqTextStyle(
        baseStyle.copyWith(fontSize: 15, height: 20 / 15),
      ),
      Breakpoint.sm: CliqTextStyle(
        baseStyle.copyWith(fontSize: 15, height: 20 / 15),
      ),
    }.cascadeUp(defaultValue: CliqTextStyle(headlineStyle));

    final BreakpointMap<CliqTextStyle> copyXS = {
      Breakpoint.xl: CliqTextStyle(
        baseStyle.copyWith(fontSize: 12, height: 18 / 12),
      ),
      Breakpoint.lg: CliqTextStyle(
        baseStyle.copyWith(fontSize: 11, height: 17 / 11),
      ),
      Breakpoint.sm: CliqTextStyle(
        baseStyle.copyWith(fontSize: 10, height: 16 / 10),
      ),
    }.cascadeUp(defaultValue: CliqTextStyle(headlineStyle));

    return CliqTypographyData(
      h1: h1,
      h2: h2,
      h3: h3,
      h4: h4,
      h5: h5,
      copyXL: copyXL,
      copyL: copyL,
      copyM: copyM,
      copyS: copyS,
      copyXS: copyXS,
    );
  }
}
