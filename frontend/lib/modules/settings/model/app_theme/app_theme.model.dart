import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

part 'generated/style.g.dart';
part 'generated/typography.g.dart';

class BaseColors {
  final int barrier;
  final int background;
  final int foreground;
  final int primary;
  final int primaryForeground;
  final int secondary;
  final int secondaryForeground;
  final int muted;
  final int mutedForeground;
  final int destructive;
  final int destructiveForeground;
  final int error;
  final int errorForeground;
  final int card;
  final int border;

  const new({
    required this.barrier,
    required this.background,
    required this.foreground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.error,
    required this.errorForeground,
    required this.card,
    required this.border,
  });
}

class PrimaryColors {
  final int primary;
  final int primaryForeground;

  const new({required this.primary, required this.primaryForeground});
}

abstract class PresetColors<T> {
  final T light;
  final T dark;

  const new({required this.light, required this.dark});

  String getDisplayName(BuildContext context);
  T getByThemeMode(ThemeMode mode);
}

enum PresetBaseColors implements PresetColors<BaseColors> {
  neutral(
    light: .new(
      barrier: 0x33000000,
      background: 0xFFFFFFFF,
      foreground: 0xFF0A0A0A,
      primary: 0xFF171717,
      primaryForeground: 0xFFFAFAFA,
      secondary: 0xFFF5F5F5,
      secondaryForeground: 0xFF171717,
      muted: 0xFFF5F5F5,
      mutedForeground: 0xFF737373,
      destructive: 0xFFE7000B,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFE7000B,
      errorForeground: 0xFFFAFAFA,
      card: 0xFFFFFFFF,
      border: 0xFFE5E5E5,
    ),
    dark: .new(
      barrier: 0x7A000000,
      background: 0xFF0A0A0A,
      foreground: 0xFFFAFAFA,
      primary: 0xFFE5E5E5,
      primaryForeground: 0xFF171717,
      secondary: 0xFF262626,
      secondaryForeground: 0xFFFAFAFA,
      muted: 0xFF262626,
      mutedForeground: 0xFFA1A1A1,
      destructive: 0xFFFF6467,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFFF6467,
      errorForeground: 0xFFFAFAFA,
      card: 0xFF171717,
      border: 0x1AFFFFFF,
    ),
  ),
  stone(
    light: .new(
      barrier: 0x33000000,
      background: 0xFFFFFFFF,
      foreground: 0xFF0C0A09,
      primary: 0xFF1C1917,
      primaryForeground: 0xFFFAFAF9,
      secondary: 0xFFF5F5F4,
      secondaryForeground: 0xFF1C1917,
      muted: 0xFFF5F5F4,
      mutedForeground: 0xFF79716B,
      destructive: 0xFFE7000B,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFE7000B,
      errorForeground: 0xFFFAFAFA,
      card: 0xFFFFFFFF,
      border: 0xFFE7E5E4,
    ),
    dark: .new(
      barrier: 0x7A000000,
      background: 0xFF0C0A09,
      foreground: 0xFFFAFAF9,
      primary: 0xFFE7E5E4,
      primaryForeground: 0xFF1C1917,
      secondary: 0xFF292524,
      secondaryForeground: 0xFFFAFAF9,
      muted: 0xFF292524,
      mutedForeground: 0xFFA6A09B,
      destructive: 0xFFFF6467,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFFF6467,
      errorForeground: 0xFFFAFAFA,
      card: 0xFF1C1917,
      border: 0x1AFFFFFF,
    ),
  ),
  zinc(
    light: .new(
      barrier: 0x33000000,
      background: 0xFFFFFFFF,
      foreground: 0xFF09090B,
      primary: 0xFF18181B,
      primaryForeground: 0xFFFAFAFA,
      secondary: 0xFFF4F4F5,
      secondaryForeground: 0xFF18181B,
      muted: 0xFFF4F4F5,
      mutedForeground: 0xFF71717B,
      destructive: 0xFFE7000B,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFE7000B,
      errorForeground: 0xFFFAFAFA,
      card: 0xFFFFFFFF,
      border: 0xFFE4E4E7,
    ),
    dark: .new(
      barrier: 0x7A000000,
      background: 0xFF09090B,
      foreground: 0xFFFAFAFA,
      primary: 0xFFE4E4E7,
      primaryForeground: 0xFF18181B,
      secondary: 0xFF27272A,
      secondaryForeground: 0xFFFAFAFA,
      muted: 0xFF27272A,
      mutedForeground: 0xFF9F9FA9,
      destructive: 0xFFFF6467,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFFF6467,
      errorForeground: 0xFFFAFAFA,
      card: 0xFF18181B,
      border: 0x1AFFFFFF,
    ),
  ),
  mauve(
    light: .new(
      barrier: 0x33000000,
      background: 0xFFFFFFFF,
      foreground: 0xFF0C090C,
      primary: 0xFF1D161E,
      primaryForeground: 0xFFFAFAFA,
      secondary: 0xFFF3F1F3,
      secondaryForeground: 0xFF1D161E,
      muted: 0xFFF3F1F3,
      mutedForeground: 0xFF79697B,
      destructive: 0xFFE7000B,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFE7000B,
      errorForeground: 0xFFFAFAFA,
      card: 0xFFFFFFFF,
      border: 0xFFE7E4E7,
    ),
    dark: .new(
      barrier: 0x7A000000,
      background: 0xFF0C090C,
      foreground: 0xFFFAFAFA,
      primary: 0xFFE7E4E7,
      primaryForeground: 0xFF1D161E,
      secondary: 0xFF2A212C,
      secondaryForeground: 0xFFFAFAFA,
      muted: 0xFF2A212C,
      mutedForeground: 0xFFA89EA9,
      destructive: 0xFFFF6467,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFFF6467,
      errorForeground: 0xFFFAFAFA,
      card: 0xFF1D161E,
      border: 0x1AFFFFFF,
    ),
  ),
  olive(
    light: .new(
      barrier: 0x33000000,
      background: 0xFFFFFFFF,
      foreground: 0xFF0C0C09,
      primary: 0xFF1D1D16,
      primaryForeground: 0xFFFBFBF9,
      secondary: 0xFFF4F4F0,
      secondaryForeground: 0xFF1D1D16,
      muted: 0xFFF4F4F0,
      mutedForeground: 0xFF7C7C67,
      destructive: 0xFFE7000B,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFE7000B,
      errorForeground: 0xFFFAFAFA,
      card: 0xFFFFFFFF,
      border: 0xFFE8E8E3,
    ),
    dark: .new(
      barrier: 0x7A000000,
      background: 0xFF0C0C09,
      foreground: 0xFFFBFBF9,
      primary: 0xFFE8E8E3,
      primaryForeground: 0xFF1D1D16,
      secondary: 0xFF2B2B22,
      secondaryForeground: 0xFFFBFBF9,
      muted: 0xFF2B2B22,
      mutedForeground: 0xFFABAB9C,
      destructive: 0xFFFF6467,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFFF6467,
      errorForeground: 0xFFFAFAFA,
      card: 0xFF1D1D16,
      border: 0x1AFFFFFF,
    ),
  ),
  mist(
    light: .new(
      barrier: 0x33000000,
      background: 0xFFFFFFFF,
      foreground: 0xFF090B0C,
      primary: 0xFF161B1D,
      primaryForeground: 0xFFF9FBFB,
      secondary: 0xFFF1F3F3,
      secondaryForeground: 0xFF161B1D,
      muted: 0xFFF1F3F3,
      mutedForeground: 0xFF67787C,
      destructive: 0xFFE7000B,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFE7000B,
      errorForeground: 0xFFFAFAFA,
      card: 0xFFFFFFFF,
      border: 0xFFE3E7E8,
    ),
    dark: .new(
      barrier: 0x7A000000,
      background: 0xFF090B0C,
      foreground: 0xFFF9FBFB,
      primary: 0xFFE3E7E8,
      primaryForeground: 0xFF161B1D,
      secondary: 0xFF22292B,
      secondaryForeground: 0xFFF9FBFB,
      muted: 0xFF22292B,
      mutedForeground: 0xFF9CA8AB,
      destructive: 0xFFFF6467,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFFF6467,
      errorForeground: 0xFFFAFAFA,
      card: 0xFF161B1D,
      border: 0x1AFFFFFF,
    ),
  ),
  taupe(
    light: .new(
      barrier: 0x33000000,
      background: 0xFFFFFFFF,
      foreground: 0xFF0C0A09,
      primary: 0xFF1D1816,
      primaryForeground: 0xFFFBFAF9,
      secondary: 0xFFF3F1F1,
      secondaryForeground: 0xFF1D1816,
      muted: 0xFFF3F1F1,
      mutedForeground: 0xFF7C6D67,
      destructive: 0xFFE7000B,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFE7000B,
      errorForeground: 0xFFFAFAFA,
      card: 0xFFFFFFFF,
      border: 0xFFE8E4E3,
    ),
    dark: .new(
      barrier: 0x7A000000,
      background: 0xFF0C0A09,
      foreground: 0xFFFBFAF9,
      primary: 0xFFE8E4E3,
      primaryForeground: 0xFF1D1816,
      secondary: 0xFF2B2422,
      secondaryForeground: 0xFFFBFAF9,
      muted: 0xFF2B2422,
      mutedForeground: 0xFFABA09C,
      destructive: 0xFFFF6467,
      destructiveForeground: 0xFFFAFAFA,
      error: 0xFFFF6467,
      errorForeground: 0xFFFAFAFA,
      card: 0xFF1D1816,
      border: 0x1AFFFFFF,
    ),
  );

  @override
  final BaseColors light;
  @override
  final BaseColors dark;

  new({required this.light, required this.dark});

  FThemeData withPrimaryAndMode({
    required PresetPrimaryColor primaryColor,
    required ThemeMode mode,
    bool isTouch = false,
  }) {
    final isDark = switch (mode) {
      ThemeMode.system =>
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            .dark,
      ThemeMode.light => false,
      ThemeMode.dark => true,
    };

    final base = isDark ? dark : light;
    final primary = isDark ? primaryColor.dark : primaryColor.light;

    final colors = FColors(
      brightness: isDark ? .dark : .light,
      systemOverlayStyle: isDark ? .light : .dark,
      barrier: Color(base.barrier),
      background: Color(base.background),
      foreground: Color(base.foreground),
      primary: Color(primary.primary),
      primaryForeground: Color(primary.primaryForeground),
      secondary: Color(base.secondary),
      secondaryForeground: Color(base.secondaryForeground),
      muted: Color(base.muted),
      mutedForeground: Color(base.mutedForeground),
      destructive: Color(base.destructive),
      destructiveForeground: Color(base.destructiveForeground),
      error: Color(base.error),
      errorForeground: Color(base.errorForeground),
      card: Color(base.card),
      border: Color(base.border),
    );

    final typography = _typography(colors: colors, touch: isTouch);
    return FThemeData(
      colors: colors,
      typography: typography,
      icons: _icons(),
      style: _style(colors: colors, typography: typography, touch: isTouch),
      touch: isTouch,
    );
  }

  @override
  String getDisplayName(BuildContext context) =>
      'appearance_preset_base_colors.$name'.tr(context: context);

  @override
  BaseColors getByThemeMode(ThemeMode mode) {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return switch (mode) {
      .system => brightness == .dark ? dark : light,
      .light => light,
      .dark => dark,
    };
  }
}

enum PresetPrimaryColor implements PresetColors<PrimaryColors> {
  neutral(
    light: .new(primary: 0xFF171717, primaryForeground: 0xFFFAFAFA),
    dark: .new(primary: 0xFFE5E5E5, primaryForeground: 0xFF171717),
  ),
  amber(
    light: .new(primary: 0xFFBB4D00, primaryForeground: 0xFFFFFBEB),
    dark: .new(primary: 0xFF973C00, primaryForeground: 0xFFFFFBEB),
  ),
  blue(
    light: .new(primary: 0xFF1447E6, primaryForeground: 0xFFEFF6FF),
    dark: .new(primary: 0xFF193CB8, primaryForeground: 0xFFEFF6FF),
  ),
  cyan(
    light: .new(primary: 0xFF007595, primaryForeground: 0xFFECFEFF),
    dark: .new(primary: 0xFF005F78, primaryForeground: 0xFFECFEFF),
  ),
  emerald(
    light: .new(primary: 0xFF007A55, primaryForeground: 0xFFECFDF5),
    dark: .new(primary: 0xFF006045, primaryForeground: 0xFFECFDF5),
  ),
  fuchsia(
    light: .new(primary: 0xFFA800B7, primaryForeground: 0xFFFDF4FF),
    dark: .new(primary: 0xFF8A0194, primaryForeground: 0xFFFDF4FF),
  ),
  green(
    light: .new(primary: 0xFF008236, primaryForeground: 0xFFF0FDF4),
    dark: .new(primary: 0xFF016630, primaryForeground: 0xFFF0FDF4),
  ),
  indigo(
    light: .new(primary: 0xFF432DD7, primaryForeground: 0xFFEEF2FF),
    dark: .new(primary: 0xFF372AAC, primaryForeground: 0xFFEEF2FF),
  ),
  lime(
    light: .new(primary: 0xFF9AE600, primaryForeground: 0xFF35530E),
    dark: .new(primary: 0xFF7CCF00, primaryForeground: 0xFF35530E),
  ),
  orange(
    light: .new(primary: 0xFFCA3500, primaryForeground: 0xFFFFF7ED),
    dark: .new(primary: 0xFF9F2D00, primaryForeground: 0xFFFFF7ED),
  ),
  pink(
    light: .new(primary: 0xFFC6005C, primaryForeground: 0xFFFDF2F8),
    dark: .new(primary: 0xFFA3004C, primaryForeground: 0xFFFDF2F8),
  ),
  purple(
    light: .new(primary: 0xFF8200DB, primaryForeground: 0xFFFAF5FF),
    dark: .new(primary: 0xFF6E11B0, primaryForeground: 0xFFFAF5FF),
  ),
  red(
    light: .new(primary: 0xFFC10007, primaryForeground: 0xFFFEF2F2),
    dark: .new(primary: 0xFF9F0712, primaryForeground: 0xFFFEF2F2),
  ),
  rose(
    light: .new(primary: 0xFFC70036, primaryForeground: 0xFFFFF1F2),
    dark: .new(primary: 0xFFA50036, primaryForeground: 0xFFFFF1F2),
  ),
  sky(
    light: .new(primary: 0xFF0069A8, primaryForeground: 0xFFF0F9FF),
    dark: .new(primary: 0xFF00598A, primaryForeground: 0xFFF0F9FF),
  ),
  teal(
    light: .new(primary: 0xFF00786F, primaryForeground: 0xFFF0FDFA),
    dark: .new(primary: 0xFF005F5A, primaryForeground: 0xFFF0FDFA),
  ),
  violet(
    light: .new(primary: 0xFF7008E7, primaryForeground: 0xFFF5F3FF),
    dark: .new(primary: 0xFF5D0EC0, primaryForeground: 0xFFF5F3FF),
  ),
  yellow(
    light: .new(primary: 0xFFFDC700, primaryForeground: 0xFF733E0A),
    dark: .new(primary: 0xFFF0B100, primaryForeground: 0xFF733E0A),
  );

  @override
  final PrimaryColors light;
  @override
  final PrimaryColors dark;

  new({required this.light, required this.dark});

  @override
  String getDisplayName(BuildContext context) =>
      'appearance_preset_primary_colors.$name'.tr(context: context);

  @override
  PrimaryColors getByThemeMode(ThemeMode mode) {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return switch (mode) {
      .system => brightness == .dark ? dark : light,
      .light => light,
      .dark => dark,
    };
  }
}

FIcons _icons() => const FIcons(
  arrowLeft: FIcon(LucideIcons.arrowLeft),
  calendar: FIcon(LucideIcons.calendar),
  check: FIcon(LucideIcons.check),
  chevronDown: FIcon(LucideIcons.chevronDown),
  chevronLeft: FIcon(LucideIcons.chevronLeft),
  chevronRight: FIcon(LucideIcons.chevronRight),
  chevronUp: FIcon(LucideIcons.chevronUp),
  chevronsUpDown: FIcon(LucideIcons.chevronsUpDown),
  circleAlert: FIcon(LucideIcons.circleAlert),
  clock4: FIcon(LucideIcons.clock4),
  ellipsis: FIcon(LucideIcons.ellipsis),
  error: FIcon(LucideIcons.circleAlert),
  eye: FIcon(LucideIcons.eye),
  eyeClosed: FIcon(LucideIcons.eyeClosed),
  gripHorizontal: FIcon(LucideIcons.gripHorizontal),
  gripVertical: FIcon(LucideIcons.gripVertical),
  loader: FIcon(LucideIcons.loader),
  loaderCircle: FIcon(LucideIcons.loaderCircle),
  loaderPinwheel: FIcon(LucideIcons.loaderPinwheel),
  search: FIcon(LucideIcons.search),
  userRound: FIcon(LucideIcons.userRound),
  x: FIcon(LucideIcons.x),
);
