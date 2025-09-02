import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widget_previews.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

part 'blur_container.preview.dart';
part 'button.preview.dart';
part 'card.preview.dart';
part 'chip.preview.dart';
part 'header.preview.dart';
part 'icon_button.preview.dart';

Widget previewWrapper(Widget child) =>
    CliqTheme(data: CliqThemes.standard.light, child: child);

const Size previewSize = Size(400, 300);
