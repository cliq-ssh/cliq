// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class CustomTerminalThemes extends Table
    with TableInfo<CustomTerminalThemes, CustomTerminalTheme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CustomTerminalThemes(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<Color, int> blackColor =
      GeneratedColumn<int>(
        'black_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterblackColor);
  late final GeneratedColumnWithTypeConverter<Color, int> redColor =
      GeneratedColumn<int>(
        'red_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterredColor);
  late final GeneratedColumnWithTypeConverter<Color, int> greenColor =
      GeneratedColumn<int>(
        'green_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$convertergreenColor);
  late final GeneratedColumnWithTypeConverter<Color, int> yellowColor =
      GeneratedColumn<int>(
        'yellow_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converteryellowColor);
  late final GeneratedColumnWithTypeConverter<Color, int> blueColor =
      GeneratedColumn<int>(
        'blue_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterblueColor);
  late final GeneratedColumnWithTypeConverter<Color, int> purpleColor =
      GeneratedColumn<int>(
        'purple_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterpurpleColor);
  late final GeneratedColumnWithTypeConverter<Color, int> cyanColor =
      GeneratedColumn<int>(
        'cyan_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$convertercyanColor);
  late final GeneratedColumnWithTypeConverter<Color, int> whiteColor =
      GeneratedColumn<int>(
        'white_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterwhiteColor);
  late final GeneratedColumnWithTypeConverter<Color, int> brightBlackColor =
      GeneratedColumn<int>(
        'bright_black_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightBlackColor);
  late final GeneratedColumnWithTypeConverter<Color, int> brightRedColor =
      GeneratedColumn<int>(
        'bright_red_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightRedColor);
  late final GeneratedColumnWithTypeConverter<Color, int> brightGreenColor =
      GeneratedColumn<int>(
        'bright_green_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightGreenColor);
  late final GeneratedColumnWithTypeConverter<Color, int> brightYellowColor =
      GeneratedColumn<int>(
        'bright_yellow_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightYellowColor);
  late final GeneratedColumnWithTypeConverter<Color, int> brightBlueColor =
      GeneratedColumn<int>(
        'bright_blue_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightBlueColor);
  late final GeneratedColumnWithTypeConverter<Color, int> brightPurpleColor =
      GeneratedColumn<int>(
        'bright_purple_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightPurpleColor);
  late final GeneratedColumnWithTypeConverter<Color, int> brightCyanColor =
      GeneratedColumn<int>(
        'bright_cyan_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightCyanColor);
  late final GeneratedColumnWithTypeConverter<Color, int> brightWhiteColor =
      GeneratedColumn<int>(
        'bright_white_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightWhiteColor);
  late final GeneratedColumnWithTypeConverter<Color, int> backgroundColor =
      GeneratedColumn<int>(
        'background_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbackgroundColor);
  late final GeneratedColumnWithTypeConverter<Color, int> foregroundColor =
      GeneratedColumn<int>(
        'foreground_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterforegroundColor);
  late final GeneratedColumnWithTypeConverter<Color, int> cursorColor =
      GeneratedColumn<int>(
        'cursor_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$convertercursorColor);
  late final GeneratedColumnWithTypeConverter<Color, int>
  selectionBackgroundColor =
      GeneratedColumn<int>(
        'selection_background_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(
        CustomTerminalThemes.$converterselectionBackgroundColor,
      );
  late final GeneratedColumnWithTypeConverter<Color?, int>
  selectionForegroundColor =
      GeneratedColumn<int>(
        'selection_foreground_color',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Color?>(
        CustomTerminalThemes.$converterselectionForegroundColorn,
      );
  late final GeneratedColumnWithTypeConverter<Color?, int> cursorTextColor =
      GeneratedColumn<int>(
        'cursor_text_color',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Color?>(CustomTerminalThemes.$convertercursorTextColorn);
  @override
  List<GeneratedColumn> get $columns => [
    name,
    author,
    blackColor,
    redColor,
    greenColor,
    yellowColor,
    blueColor,
    purpleColor,
    cyanColor,
    whiteColor,
    brightBlackColor,
    brightRedColor,
    brightGreenColor,
    brightYellowColor,
    brightBlueColor,
    brightPurpleColor,
    brightCyanColor,
    brightWhiteColor,
    backgroundColor,
    foregroundColor,
    cursorColor,
    selectionBackgroundColor,
    selectionForegroundColor,
    cursorTextColor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_terminal_themes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomTerminalTheme> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  CustomTerminalTheme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomTerminalTheme(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      blackColor: CustomTerminalThemes.$converterblackColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}black_color'],
        )!,
      ),
      redColor: CustomTerminalThemes.$converterredColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}red_color'],
        )!,
      ),
      greenColor: CustomTerminalThemes.$convertergreenColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}green_color'],
        )!,
      ),
      yellowColor: CustomTerminalThemes.$converteryellowColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}yellow_color'],
        )!,
      ),
      blueColor: CustomTerminalThemes.$converterblueColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}blue_color'],
        )!,
      ),
      purpleColor: CustomTerminalThemes.$converterpurpleColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}purple_color'],
        )!,
      ),
      cyanColor: CustomTerminalThemes.$convertercyanColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cyan_color'],
        )!,
      ),
      whiteColor: CustomTerminalThemes.$converterwhiteColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}white_color'],
        )!,
      ),
      brightBlackColor: CustomTerminalThemes.$converterbrightBlackColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_black_color'],
        )!,
      ),
      brightRedColor: CustomTerminalThemes.$converterbrightRedColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_red_color'],
        )!,
      ),
      brightGreenColor: CustomTerminalThemes.$converterbrightGreenColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_green_color'],
        )!,
      ),
      brightYellowColor: CustomTerminalThemes.$converterbrightYellowColor
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}bright_yellow_color'],
            )!,
          ),
      brightBlueColor: CustomTerminalThemes.$converterbrightBlueColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_blue_color'],
        )!,
      ),
      brightPurpleColor: CustomTerminalThemes.$converterbrightPurpleColor
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}bright_purple_color'],
            )!,
          ),
      brightCyanColor: CustomTerminalThemes.$converterbrightCyanColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_cyan_color'],
        )!,
      ),
      brightWhiteColor: CustomTerminalThemes.$converterbrightWhiteColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_white_color'],
        )!,
      ),
      backgroundColor: CustomTerminalThemes.$converterbackgroundColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}background_color'],
        )!,
      ),
      foregroundColor: CustomTerminalThemes.$converterforegroundColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}foreground_color'],
        )!,
      ),
      cursorColor: CustomTerminalThemes.$convertercursorColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cursor_color'],
        )!,
      ),
      selectionBackgroundColor: CustomTerminalThemes
          .$converterselectionBackgroundColor
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}selection_background_color'],
            )!,
          ),
      selectionForegroundColor: CustomTerminalThemes
          .$converterselectionForegroundColorn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}selection_foreground_color'],
            ),
          ),
      cursorTextColor: CustomTerminalThemes.$convertercursorTextColorn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cursor_text_color'],
        ),
      ),
    );
  }

  @override
  CustomTerminalThemes createAlias(String alias) {
    return CustomTerminalThemes(attachedDatabase, alias);
  }

  static TypeConverter<Color, int> $converterblackColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterredColor = const ColorConverter();
  static TypeConverter<Color, int> $convertergreenColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converteryellowColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterblueColor = const ColorConverter();
  static TypeConverter<Color, int> $converterpurpleColor =
      const ColorConverter();
  static TypeConverter<Color, int> $convertercyanColor = const ColorConverter();
  static TypeConverter<Color, int> $converterwhiteColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightBlackColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightRedColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightGreenColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightYellowColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightBlueColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightPurpleColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightCyanColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightWhiteColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbackgroundColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterforegroundColor =
      const ColorConverter();
  static TypeConverter<Color, int> $convertercursorColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterselectionBackgroundColor =
      const ColorConverter();
  static TypeConverter<Color, int> $converterselectionForegroundColor =
      const ColorConverter();
  static TypeConverter<Color?, int?> $converterselectionForegroundColorn =
      NullAwareTypeConverter.wrap($converterselectionForegroundColor);
  static TypeConverter<Color, int> $convertercursorTextColor =
      const ColorConverter();
  static TypeConverter<Color?, int?> $convertercursorTextColorn =
      NullAwareTypeConverter.wrap($convertercursorTextColor);
  @override
  bool get dontWriteConstraints => true;
}

class CustomTerminalTheme extends DataClass
    implements Insertable<CustomTerminalTheme> {
  final String name;
  final String? author;
  final Color blackColor;
  final Color redColor;
  final Color greenColor;
  final Color yellowColor;
  final Color blueColor;
  final Color purpleColor;
  final Color cyanColor;
  final Color whiteColor;
  final Color brightBlackColor;
  final Color brightRedColor;
  final Color brightGreenColor;
  final Color brightYellowColor;
  final Color brightBlueColor;
  final Color brightPurpleColor;
  final Color brightCyanColor;
  final Color brightWhiteColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color cursorColor;
  final Color selectionBackgroundColor;
  final Color? selectionForegroundColor;
  final Color? cursorTextColor;
  const CustomTerminalTheme({
    required this.name,
    this.author,
    required this.blackColor,
    required this.redColor,
    required this.greenColor,
    required this.yellowColor,
    required this.blueColor,
    required this.purpleColor,
    required this.cyanColor,
    required this.whiteColor,
    required this.brightBlackColor,
    required this.brightRedColor,
    required this.brightGreenColor,
    required this.brightYellowColor,
    required this.brightBlueColor,
    required this.brightPurpleColor,
    required this.brightCyanColor,
    required this.brightWhiteColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.cursorColor,
    required this.selectionBackgroundColor,
    this.selectionForegroundColor,
    this.cursorTextColor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    {
      map['black_color'] = Variable<int>(
        CustomTerminalThemes.$converterblackColor.toSql(blackColor),
      );
    }
    {
      map['red_color'] = Variable<int>(
        CustomTerminalThemes.$converterredColor.toSql(redColor),
      );
    }
    {
      map['green_color'] = Variable<int>(
        CustomTerminalThemes.$convertergreenColor.toSql(greenColor),
      );
    }
    {
      map['yellow_color'] = Variable<int>(
        CustomTerminalThemes.$converteryellowColor.toSql(yellowColor),
      );
    }
    {
      map['blue_color'] = Variable<int>(
        CustomTerminalThemes.$converterblueColor.toSql(blueColor),
      );
    }
    {
      map['purple_color'] = Variable<int>(
        CustomTerminalThemes.$converterpurpleColor.toSql(purpleColor),
      );
    }
    {
      map['cyan_color'] = Variable<int>(
        CustomTerminalThemes.$convertercyanColor.toSql(cyanColor),
      );
    }
    {
      map['white_color'] = Variable<int>(
        CustomTerminalThemes.$converterwhiteColor.toSql(whiteColor),
      );
    }
    {
      map['bright_black_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightBlackColor.toSql(brightBlackColor),
      );
    }
    {
      map['bright_red_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightRedColor.toSql(brightRedColor),
      );
    }
    {
      map['bright_green_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightGreenColor.toSql(brightGreenColor),
      );
    }
    {
      map['bright_yellow_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightYellowColor.toSql(
          brightYellowColor,
        ),
      );
    }
    {
      map['bright_blue_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightBlueColor.toSql(brightBlueColor),
      );
    }
    {
      map['bright_purple_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightPurpleColor.toSql(
          brightPurpleColor,
        ),
      );
    }
    {
      map['bright_cyan_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightCyanColor.toSql(brightCyanColor),
      );
    }
    {
      map['bright_white_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightWhiteColor.toSql(brightWhiteColor),
      );
    }
    {
      map['background_color'] = Variable<int>(
        CustomTerminalThemes.$converterbackgroundColor.toSql(backgroundColor),
      );
    }
    {
      map['foreground_color'] = Variable<int>(
        CustomTerminalThemes.$converterforegroundColor.toSql(foregroundColor),
      );
    }
    {
      map['cursor_color'] = Variable<int>(
        CustomTerminalThemes.$convertercursorColor.toSql(cursorColor),
      );
    }
    {
      map['selection_background_color'] = Variable<int>(
        CustomTerminalThemes.$converterselectionBackgroundColor.toSql(
          selectionBackgroundColor,
        ),
      );
    }
    if (!nullToAbsent || selectionForegroundColor != null) {
      map['selection_foreground_color'] = Variable<int>(
        CustomTerminalThemes.$converterselectionForegroundColorn.toSql(
          selectionForegroundColor,
        ),
      );
    }
    if (!nullToAbsent || cursorTextColor != null) {
      map['cursor_text_color'] = Variable<int>(
        CustomTerminalThemes.$convertercursorTextColorn.toSql(cursorTextColor),
      );
    }
    return map;
  }

  CustomTerminalThemesCompanion toCompanion(bool nullToAbsent) {
    return CustomTerminalThemesCompanion(
      name: Value(name),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      blackColor: Value(blackColor),
      redColor: Value(redColor),
      greenColor: Value(greenColor),
      yellowColor: Value(yellowColor),
      blueColor: Value(blueColor),
      purpleColor: Value(purpleColor),
      cyanColor: Value(cyanColor),
      whiteColor: Value(whiteColor),
      brightBlackColor: Value(brightBlackColor),
      brightRedColor: Value(brightRedColor),
      brightGreenColor: Value(brightGreenColor),
      brightYellowColor: Value(brightYellowColor),
      brightBlueColor: Value(brightBlueColor),
      brightPurpleColor: Value(brightPurpleColor),
      brightCyanColor: Value(brightCyanColor),
      brightWhiteColor: Value(brightWhiteColor),
      backgroundColor: Value(backgroundColor),
      foregroundColor: Value(foregroundColor),
      cursorColor: Value(cursorColor),
      selectionBackgroundColor: Value(selectionBackgroundColor),
      selectionForegroundColor: selectionForegroundColor == null && nullToAbsent
          ? const Value.absent()
          : Value(selectionForegroundColor),
      cursorTextColor: cursorTextColor == null && nullToAbsent
          ? const Value.absent()
          : Value(cursorTextColor),
    );
  }

  factory CustomTerminalTheme.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomTerminalTheme(
      name: serializer.fromJson<String>(json['name']),
      author: serializer.fromJson<String?>(json['author']),
      blackColor: serializer.fromJson<Color>(json['black_color']),
      redColor: serializer.fromJson<Color>(json['red_color']),
      greenColor: serializer.fromJson<Color>(json['green_color']),
      yellowColor: serializer.fromJson<Color>(json['yellow_color']),
      blueColor: serializer.fromJson<Color>(json['blue_color']),
      purpleColor: serializer.fromJson<Color>(json['purple_color']),
      cyanColor: serializer.fromJson<Color>(json['cyan_color']),
      whiteColor: serializer.fromJson<Color>(json['white_color']),
      brightBlackColor: serializer.fromJson<Color>(json['bright_black_color']),
      brightRedColor: serializer.fromJson<Color>(json['bright_red_color']),
      brightGreenColor: serializer.fromJson<Color>(json['bright_green_color']),
      brightYellowColor: serializer.fromJson<Color>(
        json['bright_yellow_color'],
      ),
      brightBlueColor: serializer.fromJson<Color>(json['bright_blue_color']),
      brightPurpleColor: serializer.fromJson<Color>(
        json['bright_purple_color'],
      ),
      brightCyanColor: serializer.fromJson<Color>(json['bright_cyan_color']),
      brightWhiteColor: serializer.fromJson<Color>(json['bright_white_color']),
      backgroundColor: serializer.fromJson<Color>(json['background_color']),
      foregroundColor: serializer.fromJson<Color>(json['foreground_color']),
      cursorColor: serializer.fromJson<Color>(json['cursor_color']),
      selectionBackgroundColor: serializer.fromJson<Color>(
        json['selection_background_color'],
      ),
      selectionForegroundColor: serializer.fromJson<Color?>(
        json['selection_foreground_color'],
      ),
      cursorTextColor: serializer.fromJson<Color?>(json['cursor_text_color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'author': serializer.toJson<String?>(author),
      'black_color': serializer.toJson<Color>(blackColor),
      'red_color': serializer.toJson<Color>(redColor),
      'green_color': serializer.toJson<Color>(greenColor),
      'yellow_color': serializer.toJson<Color>(yellowColor),
      'blue_color': serializer.toJson<Color>(blueColor),
      'purple_color': serializer.toJson<Color>(purpleColor),
      'cyan_color': serializer.toJson<Color>(cyanColor),
      'white_color': serializer.toJson<Color>(whiteColor),
      'bright_black_color': serializer.toJson<Color>(brightBlackColor),
      'bright_red_color': serializer.toJson<Color>(brightRedColor),
      'bright_green_color': serializer.toJson<Color>(brightGreenColor),
      'bright_yellow_color': serializer.toJson<Color>(brightYellowColor),
      'bright_blue_color': serializer.toJson<Color>(brightBlueColor),
      'bright_purple_color': serializer.toJson<Color>(brightPurpleColor),
      'bright_cyan_color': serializer.toJson<Color>(brightCyanColor),
      'bright_white_color': serializer.toJson<Color>(brightWhiteColor),
      'background_color': serializer.toJson<Color>(backgroundColor),
      'foreground_color': serializer.toJson<Color>(foregroundColor),
      'cursor_color': serializer.toJson<Color>(cursorColor),
      'selection_background_color': serializer.toJson<Color>(
        selectionBackgroundColor,
      ),
      'selection_foreground_color': serializer.toJson<Color?>(
        selectionForegroundColor,
      ),
      'cursor_text_color': serializer.toJson<Color?>(cursorTextColor),
    };
  }

  CustomTerminalTheme copyWith({
    String? name,
    Value<String?> author = const Value.absent(),
    Color? blackColor,
    Color? redColor,
    Color? greenColor,
    Color? yellowColor,
    Color? blueColor,
    Color? purpleColor,
    Color? cyanColor,
    Color? whiteColor,
    Color? brightBlackColor,
    Color? brightRedColor,
    Color? brightGreenColor,
    Color? brightYellowColor,
    Color? brightBlueColor,
    Color? brightPurpleColor,
    Color? brightCyanColor,
    Color? brightWhiteColor,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? cursorColor,
    Color? selectionBackgroundColor,
    Value<Color?> selectionForegroundColor = const Value.absent(),
    Value<Color?> cursorTextColor = const Value.absent(),
  }) => CustomTerminalTheme(
    name: name ?? this.name,
    author: author.present ? author.value : this.author,
    blackColor: blackColor ?? this.blackColor,
    redColor: redColor ?? this.redColor,
    greenColor: greenColor ?? this.greenColor,
    yellowColor: yellowColor ?? this.yellowColor,
    blueColor: blueColor ?? this.blueColor,
    purpleColor: purpleColor ?? this.purpleColor,
    cyanColor: cyanColor ?? this.cyanColor,
    whiteColor: whiteColor ?? this.whiteColor,
    brightBlackColor: brightBlackColor ?? this.brightBlackColor,
    brightRedColor: brightRedColor ?? this.brightRedColor,
    brightGreenColor: brightGreenColor ?? this.brightGreenColor,
    brightYellowColor: brightYellowColor ?? this.brightYellowColor,
    brightBlueColor: brightBlueColor ?? this.brightBlueColor,
    brightPurpleColor: brightPurpleColor ?? this.brightPurpleColor,
    brightCyanColor: brightCyanColor ?? this.brightCyanColor,
    brightWhiteColor: brightWhiteColor ?? this.brightWhiteColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    foregroundColor: foregroundColor ?? this.foregroundColor,
    cursorColor: cursorColor ?? this.cursorColor,
    selectionBackgroundColor:
        selectionBackgroundColor ?? this.selectionBackgroundColor,
    selectionForegroundColor: selectionForegroundColor.present
        ? selectionForegroundColor.value
        : this.selectionForegroundColor,
    cursorTextColor: cursorTextColor.present
        ? cursorTextColor.value
        : this.cursorTextColor,
  );
  CustomTerminalTheme copyWithCompanion(CustomTerminalThemesCompanion data) {
    return CustomTerminalTheme(
      name: data.name.present ? data.name.value : this.name,
      author: data.author.present ? data.author.value : this.author,
      blackColor: data.blackColor.present
          ? data.blackColor.value
          : this.blackColor,
      redColor: data.redColor.present ? data.redColor.value : this.redColor,
      greenColor: data.greenColor.present
          ? data.greenColor.value
          : this.greenColor,
      yellowColor: data.yellowColor.present
          ? data.yellowColor.value
          : this.yellowColor,
      blueColor: data.blueColor.present ? data.blueColor.value : this.blueColor,
      purpleColor: data.purpleColor.present
          ? data.purpleColor.value
          : this.purpleColor,
      cyanColor: data.cyanColor.present ? data.cyanColor.value : this.cyanColor,
      whiteColor: data.whiteColor.present
          ? data.whiteColor.value
          : this.whiteColor,
      brightBlackColor: data.brightBlackColor.present
          ? data.brightBlackColor.value
          : this.brightBlackColor,
      brightRedColor: data.brightRedColor.present
          ? data.brightRedColor.value
          : this.brightRedColor,
      brightGreenColor: data.brightGreenColor.present
          ? data.brightGreenColor.value
          : this.brightGreenColor,
      brightYellowColor: data.brightYellowColor.present
          ? data.brightYellowColor.value
          : this.brightYellowColor,
      brightBlueColor: data.brightBlueColor.present
          ? data.brightBlueColor.value
          : this.brightBlueColor,
      brightPurpleColor: data.brightPurpleColor.present
          ? data.brightPurpleColor.value
          : this.brightPurpleColor,
      brightCyanColor: data.brightCyanColor.present
          ? data.brightCyanColor.value
          : this.brightCyanColor,
      brightWhiteColor: data.brightWhiteColor.present
          ? data.brightWhiteColor.value
          : this.brightWhiteColor,
      backgroundColor: data.backgroundColor.present
          ? data.backgroundColor.value
          : this.backgroundColor,
      foregroundColor: data.foregroundColor.present
          ? data.foregroundColor.value
          : this.foregroundColor,
      cursorColor: data.cursorColor.present
          ? data.cursorColor.value
          : this.cursorColor,
      selectionBackgroundColor: data.selectionBackgroundColor.present
          ? data.selectionBackgroundColor.value
          : this.selectionBackgroundColor,
      selectionForegroundColor: data.selectionForegroundColor.present
          ? data.selectionForegroundColor.value
          : this.selectionForegroundColor,
      cursorTextColor: data.cursorTextColor.present
          ? data.cursorTextColor.value
          : this.cursorTextColor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomTerminalTheme(')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('blackColor: $blackColor, ')
          ..write('redColor: $redColor, ')
          ..write('greenColor: $greenColor, ')
          ..write('yellowColor: $yellowColor, ')
          ..write('blueColor: $blueColor, ')
          ..write('purpleColor: $purpleColor, ')
          ..write('cyanColor: $cyanColor, ')
          ..write('whiteColor: $whiteColor, ')
          ..write('brightBlackColor: $brightBlackColor, ')
          ..write('brightRedColor: $brightRedColor, ')
          ..write('brightGreenColor: $brightGreenColor, ')
          ..write('brightYellowColor: $brightYellowColor, ')
          ..write('brightBlueColor: $brightBlueColor, ')
          ..write('brightPurpleColor: $brightPurpleColor, ')
          ..write('brightCyanColor: $brightCyanColor, ')
          ..write('brightWhiteColor: $brightWhiteColor, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('foregroundColor: $foregroundColor, ')
          ..write('cursorColor: $cursorColor, ')
          ..write('selectionBackgroundColor: $selectionBackgroundColor, ')
          ..write('selectionForegroundColor: $selectionForegroundColor, ')
          ..write('cursorTextColor: $cursorTextColor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    name,
    author,
    blackColor,
    redColor,
    greenColor,
    yellowColor,
    blueColor,
    purpleColor,
    cyanColor,
    whiteColor,
    brightBlackColor,
    brightRedColor,
    brightGreenColor,
    brightYellowColor,
    brightBlueColor,
    brightPurpleColor,
    brightCyanColor,
    brightWhiteColor,
    backgroundColor,
    foregroundColor,
    cursorColor,
    selectionBackgroundColor,
    selectionForegroundColor,
    cursorTextColor,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomTerminalTheme &&
          other.name == this.name &&
          other.author == this.author &&
          other.blackColor == this.blackColor &&
          other.redColor == this.redColor &&
          other.greenColor == this.greenColor &&
          other.yellowColor == this.yellowColor &&
          other.blueColor == this.blueColor &&
          other.purpleColor == this.purpleColor &&
          other.cyanColor == this.cyanColor &&
          other.whiteColor == this.whiteColor &&
          other.brightBlackColor == this.brightBlackColor &&
          other.brightRedColor == this.brightRedColor &&
          other.brightGreenColor == this.brightGreenColor &&
          other.brightYellowColor == this.brightYellowColor &&
          other.brightBlueColor == this.brightBlueColor &&
          other.brightPurpleColor == this.brightPurpleColor &&
          other.brightCyanColor == this.brightCyanColor &&
          other.brightWhiteColor == this.brightWhiteColor &&
          other.backgroundColor == this.backgroundColor &&
          other.foregroundColor == this.foregroundColor &&
          other.cursorColor == this.cursorColor &&
          other.selectionBackgroundColor == this.selectionBackgroundColor &&
          other.selectionForegroundColor == this.selectionForegroundColor &&
          other.cursorTextColor == this.cursorTextColor);
}

class CustomTerminalThemesCompanion
    extends UpdateCompanion<CustomTerminalTheme> {
  final Value<String> name;
  final Value<String?> author;
  final Value<Color> blackColor;
  final Value<Color> redColor;
  final Value<Color> greenColor;
  final Value<Color> yellowColor;
  final Value<Color> blueColor;
  final Value<Color> purpleColor;
  final Value<Color> cyanColor;
  final Value<Color> whiteColor;
  final Value<Color> brightBlackColor;
  final Value<Color> brightRedColor;
  final Value<Color> brightGreenColor;
  final Value<Color> brightYellowColor;
  final Value<Color> brightBlueColor;
  final Value<Color> brightPurpleColor;
  final Value<Color> brightCyanColor;
  final Value<Color> brightWhiteColor;
  final Value<Color> backgroundColor;
  final Value<Color> foregroundColor;
  final Value<Color> cursorColor;
  final Value<Color> selectionBackgroundColor;
  final Value<Color?> selectionForegroundColor;
  final Value<Color?> cursorTextColor;
  final Value<int> rowid;
  const CustomTerminalThemesCompanion({
    this.name = const Value.absent(),
    this.author = const Value.absent(),
    this.blackColor = const Value.absent(),
    this.redColor = const Value.absent(),
    this.greenColor = const Value.absent(),
    this.yellowColor = const Value.absent(),
    this.blueColor = const Value.absent(),
    this.purpleColor = const Value.absent(),
    this.cyanColor = const Value.absent(),
    this.whiteColor = const Value.absent(),
    this.brightBlackColor = const Value.absent(),
    this.brightRedColor = const Value.absent(),
    this.brightGreenColor = const Value.absent(),
    this.brightYellowColor = const Value.absent(),
    this.brightBlueColor = const Value.absent(),
    this.brightPurpleColor = const Value.absent(),
    this.brightCyanColor = const Value.absent(),
    this.brightWhiteColor = const Value.absent(),
    this.backgroundColor = const Value.absent(),
    this.foregroundColor = const Value.absent(),
    this.cursorColor = const Value.absent(),
    this.selectionBackgroundColor = const Value.absent(),
    this.selectionForegroundColor = const Value.absent(),
    this.cursorTextColor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomTerminalThemesCompanion.insert({
    required String name,
    this.author = const Value.absent(),
    required Color blackColor,
    required Color redColor,
    required Color greenColor,
    required Color yellowColor,
    required Color blueColor,
    required Color purpleColor,
    required Color cyanColor,
    required Color whiteColor,
    required Color brightBlackColor,
    required Color brightRedColor,
    required Color brightGreenColor,
    required Color brightYellowColor,
    required Color brightBlueColor,
    required Color brightPurpleColor,
    required Color brightCyanColor,
    required Color brightWhiteColor,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color cursorColor,
    required Color selectionBackgroundColor,
    this.selectionForegroundColor = const Value.absent(),
    this.cursorTextColor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       blackColor = Value(blackColor),
       redColor = Value(redColor),
       greenColor = Value(greenColor),
       yellowColor = Value(yellowColor),
       blueColor = Value(blueColor),
       purpleColor = Value(purpleColor),
       cyanColor = Value(cyanColor),
       whiteColor = Value(whiteColor),
       brightBlackColor = Value(brightBlackColor),
       brightRedColor = Value(brightRedColor),
       brightGreenColor = Value(brightGreenColor),
       brightYellowColor = Value(brightYellowColor),
       brightBlueColor = Value(brightBlueColor),
       brightPurpleColor = Value(brightPurpleColor),
       brightCyanColor = Value(brightCyanColor),
       brightWhiteColor = Value(brightWhiteColor),
       backgroundColor = Value(backgroundColor),
       foregroundColor = Value(foregroundColor),
       cursorColor = Value(cursorColor),
       selectionBackgroundColor = Value(selectionBackgroundColor);
  static Insertable<CustomTerminalTheme> custom({
    Expression<String>? name,
    Expression<String>? author,
    Expression<int>? blackColor,
    Expression<int>? redColor,
    Expression<int>? greenColor,
    Expression<int>? yellowColor,
    Expression<int>? blueColor,
    Expression<int>? purpleColor,
    Expression<int>? cyanColor,
    Expression<int>? whiteColor,
    Expression<int>? brightBlackColor,
    Expression<int>? brightRedColor,
    Expression<int>? brightGreenColor,
    Expression<int>? brightYellowColor,
    Expression<int>? brightBlueColor,
    Expression<int>? brightPurpleColor,
    Expression<int>? brightCyanColor,
    Expression<int>? brightWhiteColor,
    Expression<int>? backgroundColor,
    Expression<int>? foregroundColor,
    Expression<int>? cursorColor,
    Expression<int>? selectionBackgroundColor,
    Expression<int>? selectionForegroundColor,
    Expression<int>? cursorTextColor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (author != null) 'author': author,
      if (blackColor != null) 'black_color': blackColor,
      if (redColor != null) 'red_color': redColor,
      if (greenColor != null) 'green_color': greenColor,
      if (yellowColor != null) 'yellow_color': yellowColor,
      if (blueColor != null) 'blue_color': blueColor,
      if (purpleColor != null) 'purple_color': purpleColor,
      if (cyanColor != null) 'cyan_color': cyanColor,
      if (whiteColor != null) 'white_color': whiteColor,
      if (brightBlackColor != null) 'bright_black_color': brightBlackColor,
      if (brightRedColor != null) 'bright_red_color': brightRedColor,
      if (brightGreenColor != null) 'bright_green_color': brightGreenColor,
      if (brightYellowColor != null) 'bright_yellow_color': brightYellowColor,
      if (brightBlueColor != null) 'bright_blue_color': brightBlueColor,
      if (brightPurpleColor != null) 'bright_purple_color': brightPurpleColor,
      if (brightCyanColor != null) 'bright_cyan_color': brightCyanColor,
      if (brightWhiteColor != null) 'bright_white_color': brightWhiteColor,
      if (backgroundColor != null) 'background_color': backgroundColor,
      if (foregroundColor != null) 'foreground_color': foregroundColor,
      if (cursorColor != null) 'cursor_color': cursorColor,
      if (selectionBackgroundColor != null)
        'selection_background_color': selectionBackgroundColor,
      if (selectionForegroundColor != null)
        'selection_foreground_color': selectionForegroundColor,
      if (cursorTextColor != null) 'cursor_text_color': cursorTextColor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomTerminalThemesCompanion copyWith({
    Value<String>? name,
    Value<String?>? author,
    Value<Color>? blackColor,
    Value<Color>? redColor,
    Value<Color>? greenColor,
    Value<Color>? yellowColor,
    Value<Color>? blueColor,
    Value<Color>? purpleColor,
    Value<Color>? cyanColor,
    Value<Color>? whiteColor,
    Value<Color>? brightBlackColor,
    Value<Color>? brightRedColor,
    Value<Color>? brightGreenColor,
    Value<Color>? brightYellowColor,
    Value<Color>? brightBlueColor,
    Value<Color>? brightPurpleColor,
    Value<Color>? brightCyanColor,
    Value<Color>? brightWhiteColor,
    Value<Color>? backgroundColor,
    Value<Color>? foregroundColor,
    Value<Color>? cursorColor,
    Value<Color>? selectionBackgroundColor,
    Value<Color?>? selectionForegroundColor,
    Value<Color?>? cursorTextColor,
    Value<int>? rowid,
  }) {
    return CustomTerminalThemesCompanion(
      name: name ?? this.name,
      author: author ?? this.author,
      blackColor: blackColor ?? this.blackColor,
      redColor: redColor ?? this.redColor,
      greenColor: greenColor ?? this.greenColor,
      yellowColor: yellowColor ?? this.yellowColor,
      blueColor: blueColor ?? this.blueColor,
      purpleColor: purpleColor ?? this.purpleColor,
      cyanColor: cyanColor ?? this.cyanColor,
      whiteColor: whiteColor ?? this.whiteColor,
      brightBlackColor: brightBlackColor ?? this.brightBlackColor,
      brightRedColor: brightRedColor ?? this.brightRedColor,
      brightGreenColor: brightGreenColor ?? this.brightGreenColor,
      brightYellowColor: brightYellowColor ?? this.brightYellowColor,
      brightBlueColor: brightBlueColor ?? this.brightBlueColor,
      brightPurpleColor: brightPurpleColor ?? this.brightPurpleColor,
      brightCyanColor: brightCyanColor ?? this.brightCyanColor,
      brightWhiteColor: brightWhiteColor ?? this.brightWhiteColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      cursorColor: cursorColor ?? this.cursorColor,
      selectionBackgroundColor:
          selectionBackgroundColor ?? this.selectionBackgroundColor,
      selectionForegroundColor:
          selectionForegroundColor ?? this.selectionForegroundColor,
      cursorTextColor: cursorTextColor ?? this.cursorTextColor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (blackColor.present) {
      map['black_color'] = Variable<int>(
        CustomTerminalThemes.$converterblackColor.toSql(blackColor.value),
      );
    }
    if (redColor.present) {
      map['red_color'] = Variable<int>(
        CustomTerminalThemes.$converterredColor.toSql(redColor.value),
      );
    }
    if (greenColor.present) {
      map['green_color'] = Variable<int>(
        CustomTerminalThemes.$convertergreenColor.toSql(greenColor.value),
      );
    }
    if (yellowColor.present) {
      map['yellow_color'] = Variable<int>(
        CustomTerminalThemes.$converteryellowColor.toSql(yellowColor.value),
      );
    }
    if (blueColor.present) {
      map['blue_color'] = Variable<int>(
        CustomTerminalThemes.$converterblueColor.toSql(blueColor.value),
      );
    }
    if (purpleColor.present) {
      map['purple_color'] = Variable<int>(
        CustomTerminalThemes.$converterpurpleColor.toSql(purpleColor.value),
      );
    }
    if (cyanColor.present) {
      map['cyan_color'] = Variable<int>(
        CustomTerminalThemes.$convertercyanColor.toSql(cyanColor.value),
      );
    }
    if (whiteColor.present) {
      map['white_color'] = Variable<int>(
        CustomTerminalThemes.$converterwhiteColor.toSql(whiteColor.value),
      );
    }
    if (brightBlackColor.present) {
      map['bright_black_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightBlackColor.toSql(
          brightBlackColor.value,
        ),
      );
    }
    if (brightRedColor.present) {
      map['bright_red_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightRedColor.toSql(
          brightRedColor.value,
        ),
      );
    }
    if (brightGreenColor.present) {
      map['bright_green_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightGreenColor.toSql(
          brightGreenColor.value,
        ),
      );
    }
    if (brightYellowColor.present) {
      map['bright_yellow_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightYellowColor.toSql(
          brightYellowColor.value,
        ),
      );
    }
    if (brightBlueColor.present) {
      map['bright_blue_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightBlueColor.toSql(
          brightBlueColor.value,
        ),
      );
    }
    if (brightPurpleColor.present) {
      map['bright_purple_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightPurpleColor.toSql(
          brightPurpleColor.value,
        ),
      );
    }
    if (brightCyanColor.present) {
      map['bright_cyan_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightCyanColor.toSql(
          brightCyanColor.value,
        ),
      );
    }
    if (brightWhiteColor.present) {
      map['bright_white_color'] = Variable<int>(
        CustomTerminalThemes.$converterbrightWhiteColor.toSql(
          brightWhiteColor.value,
        ),
      );
    }
    if (backgroundColor.present) {
      map['background_color'] = Variable<int>(
        CustomTerminalThemes.$converterbackgroundColor.toSql(
          backgroundColor.value,
        ),
      );
    }
    if (foregroundColor.present) {
      map['foreground_color'] = Variable<int>(
        CustomTerminalThemes.$converterforegroundColor.toSql(
          foregroundColor.value,
        ),
      );
    }
    if (cursorColor.present) {
      map['cursor_color'] = Variable<int>(
        CustomTerminalThemes.$convertercursorColor.toSql(cursorColor.value),
      );
    }
    if (selectionBackgroundColor.present) {
      map['selection_background_color'] = Variable<int>(
        CustomTerminalThemes.$converterselectionBackgroundColor.toSql(
          selectionBackgroundColor.value,
        ),
      );
    }
    if (selectionForegroundColor.present) {
      map['selection_foreground_color'] = Variable<int>(
        CustomTerminalThemes.$converterselectionForegroundColorn.toSql(
          selectionForegroundColor.value,
        ),
      );
    }
    if (cursorTextColor.present) {
      map['cursor_text_color'] = Variable<int>(
        CustomTerminalThemes.$convertercursorTextColorn.toSql(
          cursorTextColor.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomTerminalThemesCompanion(')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('blackColor: $blackColor, ')
          ..write('redColor: $redColor, ')
          ..write('greenColor: $greenColor, ')
          ..write('yellowColor: $yellowColor, ')
          ..write('blueColor: $blueColor, ')
          ..write('purpleColor: $purpleColor, ')
          ..write('cyanColor: $cyanColor, ')
          ..write('whiteColor: $whiteColor, ')
          ..write('brightBlackColor: $brightBlackColor, ')
          ..write('brightRedColor: $brightRedColor, ')
          ..write('brightGreenColor: $brightGreenColor, ')
          ..write('brightYellowColor: $brightYellowColor, ')
          ..write('brightBlueColor: $brightBlueColor, ')
          ..write('brightPurpleColor: $brightPurpleColor, ')
          ..write('brightCyanColor: $brightCyanColor, ')
          ..write('brightWhiteColor: $brightWhiteColor, ')
          ..write('backgroundColor: $backgroundColor, ')
          ..write('foregroundColor: $foregroundColor, ')
          ..write('cursorColor: $cursorColor, ')
          ..write('selectionBackgroundColor: $selectionBackgroundColor, ')
          ..write('selectionForegroundColor: $selectionForegroundColor, ')
          ..write('cursorTextColor: $cursorTextColor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Credentials extends Table with TableInfo<Credentials, Credential> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Credentials(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumnWithTypeConverter<CredentialType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<CredentialType>(Credentials.$convertertype);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _passphraseMeta = const VerificationMeta(
    'passphrase',
  );
  late final GeneratedColumn<String> passphrase = GeneratedColumn<String>(
    'passphrase',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, data, passphrase];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credentials';
  @override
  VerificationContext validateIntegrity(
    Insertable<Credential> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('passphrase')) {
      context.handle(
        _passphraseMeta,
        passphrase.isAcceptableOrUnknown(data['passphrase']!, _passphraseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Credential map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Credential(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: Credentials.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      passphrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passphrase'],
      ),
    );
  }

  @override
  Credentials createAlias(String alias) {
    return Credentials(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CredentialType, int, int> $convertertype =
      const EnumIndexConverter<CredentialType>(CredentialType.values);
  @override
  bool get dontWriteConstraints => true;
}

class Credential extends DataClass implements Insertable<Credential> {
  final int id;
  final CredentialType type;
  final String data;
  final String? passphrase;
  const Credential({
    required this.id,
    required this.type,
    required this.data,
    this.passphrase,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<int>(Credentials.$convertertype.toSql(type));
    }
    map['data'] = Variable<String>(data);
    if (!nullToAbsent || passphrase != null) {
      map['passphrase'] = Variable<String>(passphrase);
    }
    return map;
  }

  CredentialsCompanion toCompanion(bool nullToAbsent) {
    return CredentialsCompanion(
      id: Value(id),
      type: Value(type),
      data: Value(data),
      passphrase: passphrase == null && nullToAbsent
          ? const Value.absent()
          : Value(passphrase),
    );
  }

  factory Credential.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Credential(
      id: serializer.fromJson<int>(json['id']),
      type: Credentials.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      data: serializer.fromJson<String>(json['data']),
      passphrase: serializer.fromJson<String?>(json['passphrase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<int>(Credentials.$convertertype.toJson(type)),
      'data': serializer.toJson<String>(data),
      'passphrase': serializer.toJson<String?>(passphrase),
    };
  }

  Credential copyWith({
    int? id,
    CredentialType? type,
    String? data,
    Value<String?> passphrase = const Value.absent(),
  }) => Credential(
    id: id ?? this.id,
    type: type ?? this.type,
    data: data ?? this.data,
    passphrase: passphrase.present ? passphrase.value : this.passphrase,
  );
  Credential copyWithCompanion(CredentialsCompanion data) {
    return Credential(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      data: data.data.present ? data.data.value : this.data,
      passphrase: data.passphrase.present
          ? data.passphrase.value
          : this.passphrase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Credential(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('data: $data, ')
          ..write('passphrase: $passphrase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, data, passphrase);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Credential &&
          other.id == this.id &&
          other.type == this.type &&
          other.data == this.data &&
          other.passphrase == this.passphrase);
}

class CredentialsCompanion extends UpdateCompanion<Credential> {
  final Value<int> id;
  final Value<CredentialType> type;
  final Value<String> data;
  final Value<String?> passphrase;
  const CredentialsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.data = const Value.absent(),
    this.passphrase = const Value.absent(),
  });
  CredentialsCompanion.insert({
    this.id = const Value.absent(),
    required CredentialType type,
    required String data,
    this.passphrase = const Value.absent(),
  }) : type = Value(type),
       data = Value(data);
  static Insertable<Credential> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<String>? data,
    Expression<String>? passphrase,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (data != null) 'data': data,
      if (passphrase != null) 'passphrase': passphrase,
    });
  }

  CredentialsCompanion copyWith({
    Value<int>? id,
    Value<CredentialType>? type,
    Value<String>? data,
    Value<String?>? passphrase,
  }) {
    return CredentialsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      passphrase: passphrase ?? this.passphrase,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(Credentials.$convertertype.toSql(type.value));
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (passphrase.present) {
      map['passphrase'] = Variable<String>(passphrase.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CredentialsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('data: $data, ')
          ..write('passphrase: $passphrase')
          ..write(')'))
        .toString();
  }
}

class Identities extends Table with TableInfo<Identities, Identity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Identities(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _credentialIdMeta = const VerificationMeta(
    'credentialId',
  );
  late final GeneratedColumn<int> credentialId = GeneratedColumn<int>(
    'credential_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES credentials(id)ON DELETE CASCADE NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, username, credentialId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Identity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('credential_id')) {
      context.handle(
        _credentialIdMeta,
        credentialId.isAcceptableOrUnknown(
          data['credential_id']!,
          _credentialIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_credentialIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Identity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Identity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      credentialId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credential_id'],
      )!,
    );
  }

  @override
  Identities createAlias(String alias) {
    return Identities(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Identity extends DataClass implements Insertable<Identity> {
  final int id;
  final String username;
  final int credentialId;
  const Identity({
    required this.id,
    required this.username,
    required this.credentialId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['credential_id'] = Variable<int>(credentialId);
    return map;
  }

  IdentitiesCompanion toCompanion(bool nullToAbsent) {
    return IdentitiesCompanion(
      id: Value(id),
      username: Value(username),
      credentialId: Value(credentialId),
    );
  }

  factory Identity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Identity(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      credentialId: serializer.fromJson<int>(json['credential_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'credential_id': serializer.toJson<int>(credentialId),
    };
  }

  Identity copyWith({int? id, String? username, int? credentialId}) => Identity(
    id: id ?? this.id,
    username: username ?? this.username,
    credentialId: credentialId ?? this.credentialId,
  );
  Identity copyWithCompanion(IdentitiesCompanion data) {
    return Identity(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      credentialId: data.credentialId.present
          ? data.credentialId.value
          : this.credentialId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Identity(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('credentialId: $credentialId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, credentialId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Identity &&
          other.id == this.id &&
          other.username == this.username &&
          other.credentialId == this.credentialId);
}

class IdentitiesCompanion extends UpdateCompanion<Identity> {
  final Value<int> id;
  final Value<String> username;
  final Value<int> credentialId;
  const IdentitiesCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.credentialId = const Value.absent(),
  });
  IdentitiesCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required int credentialId,
  }) : username = Value(username),
       credentialId = Value(credentialId);
  static Insertable<Identity> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<int>? credentialId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (credentialId != null) 'credential_id': credentialId,
    });
  }

  IdentitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<int>? credentialId,
  }) {
    return IdentitiesCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      credentialId: credentialId ?? this.credentialId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (credentialId.present) {
      map['credential_id'] = Variable<int>(credentialId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentitiesCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('credentialId: $credentialId')
          ..write(')'))
        .toString();
  }
}

class Connections extends Table with TableInfo<Connections, Connection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Connections(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _identityIdMeta = const VerificationMeta(
    'identityId',
  );
  late final GeneratedColumn<int> identityId = GeneratedColumn<int>(
    'identity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES identities(id)',
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _credentialIdMeta = const VerificationMeta(
    'credentialId',
  );
  late final GeneratedColumn<int> credentialId = GeneratedColumn<int>(
    'credential_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES credentials(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<ConnectionIcon, int> icon =
      GeneratedColumn<int>(
        'icon',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT \'unknown\'',
        defaultValue: const CustomExpression('\'unknown\''),
      ).withConverter<ConnectionIcon>(Connections.$convertericon);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _terminalFontSizeOverrideMeta =
      const VerificationMeta('terminalFontSizeOverride');
  late final GeneratedColumn<int> terminalFontSizeOverride =
      GeneratedColumn<int>(
        'terminal_font_size_override',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _terminalFontFamilyOverrideMeta =
      const VerificationMeta('terminalFontFamilyOverride');
  late final GeneratedColumn<String> terminalFontFamilyOverride =
      GeneratedColumn<String>(
        'terminal_font_family_override',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _terminalThemeOverrideNameMeta =
      const VerificationMeta('terminalThemeOverrideName');
  late final GeneratedColumn<String> terminalThemeOverrideName =
      GeneratedColumn<String>(
        'terminal_theme_override_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints:
            'REFERENCES custom_terminal_themes(name)ON DELETE SET NULL',
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    address,
    port,
    identityId,
    username,
    credentialId,
    label,
    icon,
    color,
    groupName,
    terminalFontSizeOverride,
    terminalFontFamilyOverride,
    terminalThemeOverrideName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Connection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('identity_id')) {
      context.handle(
        _identityIdMeta,
        identityId.isAcceptableOrUnknown(data['identity_id']!, _identityIdMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('credential_id')) {
      context.handle(
        _credentialIdMeta,
        credentialId.isAcceptableOrUnknown(
          data['credential_id']!,
          _credentialIdMeta,
        ),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    }
    if (data.containsKey('terminal_font_size_override')) {
      context.handle(
        _terminalFontSizeOverrideMeta,
        terminalFontSizeOverride.isAcceptableOrUnknown(
          data['terminal_font_size_override']!,
          _terminalFontSizeOverrideMeta,
        ),
      );
    }
    if (data.containsKey('terminal_font_family_override')) {
      context.handle(
        _terminalFontFamilyOverrideMeta,
        terminalFontFamilyOverride.isAcceptableOrUnknown(
          data['terminal_font_family_override']!,
          _terminalFontFamilyOverrideMeta,
        ),
      );
    }
    if (data.containsKey('terminal_theme_override_name')) {
      context.handle(
        _terminalThemeOverrideNameMeta,
        terminalThemeOverrideName.isAcceptableOrUnknown(
          data['terminal_theme_override_name']!,
          _terminalThemeOverrideNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Connection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Connection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      identityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}identity_id'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      credentialId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credential_id'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      icon: Connections.$convertericon.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}icon'],
        )!,
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      ),
      terminalFontSizeOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}terminal_font_size_override'],
      ),
      terminalFontFamilyOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terminal_font_family_override'],
      ),
      terminalThemeOverrideName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terminal_theme_override_name'],
      ),
    );
  }

  @override
  Connections createAlias(String alias) {
    return Connections(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ConnectionIcon, int, int> $convertericon =
      const EnumIndexConverter<ConnectionIcon>(ConnectionIcon.values);
  @override
  bool get dontWriteConstraints => true;
}

class Connection extends DataClass implements Insertable<Connection> {
  final int id;
  final String address;
  final int port;
  final int? identityId;
  final String? username;
  final int? credentialId;
  final String? label;
  final ConnectionIcon icon;
  final String? color;
  final String? groupName;
  final int? terminalFontSizeOverride;
  final String? terminalFontFamilyOverride;
  final String? terminalThemeOverrideName;
  const Connection({
    required this.id,
    required this.address,
    required this.port,
    this.identityId,
    this.username,
    this.credentialId,
    this.label,
    required this.icon,
    this.color,
    this.groupName,
    this.terminalFontSizeOverride,
    this.terminalFontFamilyOverride,
    this.terminalThemeOverrideName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['address'] = Variable<String>(address);
    map['port'] = Variable<int>(port);
    if (!nullToAbsent || identityId != null) {
      map['identity_id'] = Variable<int>(identityId);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || credentialId != null) {
      map['credential_id'] = Variable<int>(credentialId);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    {
      map['icon'] = Variable<int>(Connections.$convertericon.toSql(icon));
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    if (!nullToAbsent || terminalFontSizeOverride != null) {
      map['terminal_font_size_override'] = Variable<int>(
        terminalFontSizeOverride,
      );
    }
    if (!nullToAbsent || terminalFontFamilyOverride != null) {
      map['terminal_font_family_override'] = Variable<String>(
        terminalFontFamilyOverride,
      );
    }
    if (!nullToAbsent || terminalThemeOverrideName != null) {
      map['terminal_theme_override_name'] = Variable<String>(
        terminalThemeOverrideName,
      );
    }
    return map;
  }

  ConnectionsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionsCompanion(
      id: Value(id),
      address: Value(address),
      port: Value(port),
      identityId: identityId == null && nullToAbsent
          ? const Value.absent()
          : Value(identityId),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      credentialId: credentialId == null && nullToAbsent
          ? const Value.absent()
          : Value(credentialId),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      icon: Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
      terminalFontSizeOverride: terminalFontSizeOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(terminalFontSizeOverride),
      terminalFontFamilyOverride:
          terminalFontFamilyOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(terminalFontFamilyOverride),
      terminalThemeOverrideName:
          terminalThemeOverrideName == null && nullToAbsent
          ? const Value.absent()
          : Value(terminalThemeOverrideName),
    );
  }

  factory Connection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Connection(
      id: serializer.fromJson<int>(json['id']),
      address: serializer.fromJson<String>(json['address']),
      port: serializer.fromJson<int>(json['port']),
      identityId: serializer.fromJson<int?>(json['identity_id']),
      username: serializer.fromJson<String?>(json['username']),
      credentialId: serializer.fromJson<int?>(json['credential_id']),
      label: serializer.fromJson<String?>(json['label']),
      icon: Connections.$convertericon.fromJson(
        serializer.fromJson<int>(json['icon']),
      ),
      color: serializer.fromJson<String?>(json['color']),
      groupName: serializer.fromJson<String?>(json['group_name']),
      terminalFontSizeOverride: serializer.fromJson<int?>(
        json['terminal_font_size_override'],
      ),
      terminalFontFamilyOverride: serializer.fromJson<String?>(
        json['terminal_font_family_override'],
      ),
      terminalThemeOverrideName: serializer.fromJson<String?>(
        json['terminal_theme_override_name'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'address': serializer.toJson<String>(address),
      'port': serializer.toJson<int>(port),
      'identity_id': serializer.toJson<int?>(identityId),
      'username': serializer.toJson<String?>(username),
      'credential_id': serializer.toJson<int?>(credentialId),
      'label': serializer.toJson<String?>(label),
      'icon': serializer.toJson<int>(Connections.$convertericon.toJson(icon)),
      'color': serializer.toJson<String?>(color),
      'group_name': serializer.toJson<String?>(groupName),
      'terminal_font_size_override': serializer.toJson<int?>(
        terminalFontSizeOverride,
      ),
      'terminal_font_family_override': serializer.toJson<String?>(
        terminalFontFamilyOverride,
      ),
      'terminal_theme_override_name': serializer.toJson<String?>(
        terminalThemeOverrideName,
      ),
    };
  }

  Connection copyWith({
    int? id,
    String? address,
    int? port,
    Value<int?> identityId = const Value.absent(),
    Value<String?> username = const Value.absent(),
    Value<int?> credentialId = const Value.absent(),
    Value<String?> label = const Value.absent(),
    ConnectionIcon? icon,
    Value<String?> color = const Value.absent(),
    Value<String?> groupName = const Value.absent(),
    Value<int?> terminalFontSizeOverride = const Value.absent(),
    Value<String?> terminalFontFamilyOverride = const Value.absent(),
    Value<String?> terminalThemeOverrideName = const Value.absent(),
  }) => Connection(
    id: id ?? this.id,
    address: address ?? this.address,
    port: port ?? this.port,
    identityId: identityId.present ? identityId.value : this.identityId,
    username: username.present ? username.value : this.username,
    credentialId: credentialId.present ? credentialId.value : this.credentialId,
    label: label.present ? label.value : this.label,
    icon: icon ?? this.icon,
    color: color.present ? color.value : this.color,
    groupName: groupName.present ? groupName.value : this.groupName,
    terminalFontSizeOverride: terminalFontSizeOverride.present
        ? terminalFontSizeOverride.value
        : this.terminalFontSizeOverride,
    terminalFontFamilyOverride: terminalFontFamilyOverride.present
        ? terminalFontFamilyOverride.value
        : this.terminalFontFamilyOverride,
    terminalThemeOverrideName: terminalThemeOverrideName.present
        ? terminalThemeOverrideName.value
        : this.terminalThemeOverrideName,
  );
  Connection copyWithCompanion(ConnectionsCompanion data) {
    return Connection(
      id: data.id.present ? data.id.value : this.id,
      address: data.address.present ? data.address.value : this.address,
      port: data.port.present ? data.port.value : this.port,
      identityId: data.identityId.present
          ? data.identityId.value
          : this.identityId,
      username: data.username.present ? data.username.value : this.username,
      credentialId: data.credentialId.present
          ? data.credentialId.value
          : this.credentialId,
      label: data.label.present ? data.label.value : this.label,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      terminalFontSizeOverride: data.terminalFontSizeOverride.present
          ? data.terminalFontSizeOverride.value
          : this.terminalFontSizeOverride,
      terminalFontFamilyOverride: data.terminalFontFamilyOverride.present
          ? data.terminalFontFamilyOverride.value
          : this.terminalFontFamilyOverride,
      terminalThemeOverrideName: data.terminalThemeOverrideName.present
          ? data.terminalThemeOverrideName.value
          : this.terminalThemeOverrideName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Connection(')
          ..write('id: $id, ')
          ..write('address: $address, ')
          ..write('port: $port, ')
          ..write('identityId: $identityId, ')
          ..write('username: $username, ')
          ..write('credentialId: $credentialId, ')
          ..write('label: $label, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('groupName: $groupName, ')
          ..write('terminalFontSizeOverride: $terminalFontSizeOverride, ')
          ..write('terminalFontFamilyOverride: $terminalFontFamilyOverride, ')
          ..write('terminalThemeOverrideName: $terminalThemeOverrideName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    address,
    port,
    identityId,
    username,
    credentialId,
    label,
    icon,
    color,
    groupName,
    terminalFontSizeOverride,
    terminalFontFamilyOverride,
    terminalThemeOverrideName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Connection &&
          other.id == this.id &&
          other.address == this.address &&
          other.port == this.port &&
          other.identityId == this.identityId &&
          other.username == this.username &&
          other.credentialId == this.credentialId &&
          other.label == this.label &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.groupName == this.groupName &&
          other.terminalFontSizeOverride == this.terminalFontSizeOverride &&
          other.terminalFontFamilyOverride == this.terminalFontFamilyOverride &&
          other.terminalThemeOverrideName == this.terminalThemeOverrideName);
}

class ConnectionsCompanion extends UpdateCompanion<Connection> {
  final Value<int> id;
  final Value<String> address;
  final Value<int> port;
  final Value<int?> identityId;
  final Value<String?> username;
  final Value<int?> credentialId;
  final Value<String?> label;
  final Value<ConnectionIcon> icon;
  final Value<String?> color;
  final Value<String?> groupName;
  final Value<int?> terminalFontSizeOverride;
  final Value<String?> terminalFontFamilyOverride;
  final Value<String?> terminalThemeOverrideName;
  const ConnectionsCompanion({
    this.id = const Value.absent(),
    this.address = const Value.absent(),
    this.port = const Value.absent(),
    this.identityId = const Value.absent(),
    this.username = const Value.absent(),
    this.credentialId = const Value.absent(),
    this.label = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.groupName = const Value.absent(),
    this.terminalFontSizeOverride = const Value.absent(),
    this.terminalFontFamilyOverride = const Value.absent(),
    this.terminalThemeOverrideName = const Value.absent(),
  });
  ConnectionsCompanion.insert({
    this.id = const Value.absent(),
    required String address,
    required int port,
    this.identityId = const Value.absent(),
    this.username = const Value.absent(),
    this.credentialId = const Value.absent(),
    this.label = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.groupName = const Value.absent(),
    this.terminalFontSizeOverride = const Value.absent(),
    this.terminalFontFamilyOverride = const Value.absent(),
    this.terminalThemeOverrideName = const Value.absent(),
  }) : address = Value(address),
       port = Value(port);
  static Insertable<Connection> custom({
    Expression<int>? id,
    Expression<String>? address,
    Expression<int>? port,
    Expression<int>? identityId,
    Expression<String>? username,
    Expression<int>? credentialId,
    Expression<String>? label,
    Expression<int>? icon,
    Expression<String>? color,
    Expression<String>? groupName,
    Expression<int>? terminalFontSizeOverride,
    Expression<String>? terminalFontFamilyOverride,
    Expression<String>? terminalThemeOverrideName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (address != null) 'address': address,
      if (port != null) 'port': port,
      if (identityId != null) 'identity_id': identityId,
      if (username != null) 'username': username,
      if (credentialId != null) 'credential_id': credentialId,
      if (label != null) 'label': label,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (groupName != null) 'group_name': groupName,
      if (terminalFontSizeOverride != null)
        'terminal_font_size_override': terminalFontSizeOverride,
      if (terminalFontFamilyOverride != null)
        'terminal_font_family_override': terminalFontFamilyOverride,
      if (terminalThemeOverrideName != null)
        'terminal_theme_override_name': terminalThemeOverrideName,
    });
  }

  ConnectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? address,
    Value<int>? port,
    Value<int?>? identityId,
    Value<String?>? username,
    Value<int?>? credentialId,
    Value<String?>? label,
    Value<ConnectionIcon>? icon,
    Value<String?>? color,
    Value<String?>? groupName,
    Value<int?>? terminalFontSizeOverride,
    Value<String?>? terminalFontFamilyOverride,
    Value<String?>? terminalThemeOverrideName,
  }) {
    return ConnectionsCompanion(
      id: id ?? this.id,
      address: address ?? this.address,
      port: port ?? this.port,
      identityId: identityId ?? this.identityId,
      username: username ?? this.username,
      credentialId: credentialId ?? this.credentialId,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      groupName: groupName ?? this.groupName,
      terminalFontSizeOverride:
          terminalFontSizeOverride ?? this.terminalFontSizeOverride,
      terminalFontFamilyOverride:
          terminalFontFamilyOverride ?? this.terminalFontFamilyOverride,
      terminalThemeOverrideName:
          terminalThemeOverrideName ?? this.terminalThemeOverrideName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (identityId.present) {
      map['identity_id'] = Variable<int>(identityId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (credentialId.present) {
      map['credential_id'] = Variable<int>(credentialId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (icon.present) {
      map['icon'] = Variable<int>(Connections.$convertericon.toSql(icon.value));
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (terminalFontSizeOverride.present) {
      map['terminal_font_size_override'] = Variable<int>(
        terminalFontSizeOverride.value,
      );
    }
    if (terminalFontFamilyOverride.present) {
      map['terminal_font_family_override'] = Variable<String>(
        terminalFontFamilyOverride.value,
      );
    }
    if (terminalThemeOverrideName.present) {
      map['terminal_theme_override_name'] = Variable<String>(
        terminalThemeOverrideName.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionsCompanion(')
          ..write('id: $id, ')
          ..write('address: $address, ')
          ..write('port: $port, ')
          ..write('identityId: $identityId, ')
          ..write('username: $username, ')
          ..write('credentialId: $credentialId, ')
          ..write('label: $label, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('groupName: $groupName, ')
          ..write('terminalFontSizeOverride: $terminalFontSizeOverride, ')
          ..write('terminalFontFamilyOverride: $terminalFontFamilyOverride, ')
          ..write('terminalThemeOverrideName: $terminalThemeOverrideName')
          ..write(')'))
        .toString();
  }
}

abstract class _$CliqDatabase extends GeneratedDatabase {
  _$CliqDatabase(QueryExecutor e) : super(e);
  $CliqDatabaseManager get managers => $CliqDatabaseManager(this);
  late final CustomTerminalThemes customTerminalThemes = CustomTerminalThemes(
    this,
  );
  late final Credentials credentials = Credentials(this);
  late final Identities identities = Identities(this);
  late final Connections connections = Connections(this);
  Selectable<FindAllConnectionFullResult> findAllConnectionFull() {
    return customSelect(
      'SELECT"c"."id" AS "nested_0.id", "c"."address" AS "nested_0.address", "c"."port" AS "nested_0.port", "c"."identity_id" AS "nested_0.identity_id", "c"."username" AS "nested_0.username", "c"."credential_id" AS "nested_0.credential_id", "c"."label" AS "nested_0.label", "c"."icon" AS "nested_0.icon", "c"."color" AS "nested_0.color", "c"."group_name" AS "nested_0.group_name", "c"."terminal_font_size_override" AS "nested_0.terminal_font_size_override", "c"."terminal_font_family_override" AS "nested_0.terminal_font_family_override", "c"."terminal_theme_override_name" AS "nested_0.terminal_theme_override_name","i"."id" AS "nested_1.id", "i"."username" AS "nested_1.username", "i"."credential_id" AS "nested_1.credential_id","cc"."id" AS "nested_2.id", "cc"."type" AS "nested_2.type", "cc"."data" AS "nested_2.data", "cc"."passphrase" AS "nested_2.passphrase","ci"."id" AS "nested_3.id", "ci"."type" AS "nested_3.type", "ci"."data" AS "nested_3.data", "ci"."passphrase" AS "nested_3.passphrase","t"."name" AS "nested_4.name", "t"."author" AS "nested_4.author", "t"."black_color" AS "nested_4.black_color", "t"."red_color" AS "nested_4.red_color", "t"."green_color" AS "nested_4.green_color", "t"."yellow_color" AS "nested_4.yellow_color", "t"."blue_color" AS "nested_4.blue_color", "t"."purple_color" AS "nested_4.purple_color", "t"."cyan_color" AS "nested_4.cyan_color", "t"."white_color" AS "nested_4.white_color", "t"."bright_black_color" AS "nested_4.bright_black_color", "t"."bright_red_color" AS "nested_4.bright_red_color", "t"."bright_green_color" AS "nested_4.bright_green_color", "t"."bright_yellow_color" AS "nested_4.bright_yellow_color", "t"."bright_blue_color" AS "nested_4.bright_blue_color", "t"."bright_purple_color" AS "nested_4.bright_purple_color", "t"."bright_cyan_color" AS "nested_4.bright_cyan_color", "t"."bright_white_color" AS "nested_4.bright_white_color", "t"."background_color" AS "nested_4.background_color", "t"."foreground_color" AS "nested_4.foreground_color", "t"."cursor_color" AS "nested_4.cursor_color", "t"."selection_background_color" AS "nested_4.selection_background_color", "t"."selection_foreground_color" AS "nested_4.selection_foreground_color", "t"."cursor_text_color" AS "nested_4.cursor_text_color" FROM connections AS c LEFT JOIN identities AS i ON c.identity_id = i.id LEFT JOIN credentials AS cc ON c.credential_id = cc.id LEFT JOIN credentials AS ci ON i.credential_id = ci.id LEFT JOIN custom_terminal_themes AS t ON c.terminal_theme_override_name = t.name',
      variables: [],
      readsFrom: {connections, identities, credentials, customTerminalThemes},
    ).asyncMap(
      (QueryRow row) async => FindAllConnectionFullResult(
        connection: await connections.mapFromRow(row, tablePrefix: 'nested_0'),
        identity: await identities.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_1',
        ),
        credential: await credentials.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_2',
        ),
        identityCredential: await credentials.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_3',
        ),
        terminalThemeOverride: await customTerminalThemes.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_4',
        ),
      ),
    );
  }

  Selectable<String?> findAllConnectionGroupNames() {
    return customSelect(
      'SELECT DISTINCT group_name FROM connections WHERE group_name IS NOT NULL AND group_name != \'\' ORDER BY group_name ASC',
      variables: [],
      readsFrom: {connections},
    ).map((QueryRow row) => row.readNullable<String>('group_name'));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customTerminalThemes,
    credentials,
    identities,
    connections,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'credentials',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('identities', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'credentials',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('connections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'custom_terminal_themes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('connections', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $CustomTerminalThemesCreateCompanionBuilder =
    CustomTerminalThemesCompanion Function({
      required String name,
      Value<String?> author,
      required Color blackColor,
      required Color redColor,
      required Color greenColor,
      required Color yellowColor,
      required Color blueColor,
      required Color purpleColor,
      required Color cyanColor,
      required Color whiteColor,
      required Color brightBlackColor,
      required Color brightRedColor,
      required Color brightGreenColor,
      required Color brightYellowColor,
      required Color brightBlueColor,
      required Color brightPurpleColor,
      required Color brightCyanColor,
      required Color brightWhiteColor,
      required Color backgroundColor,
      required Color foregroundColor,
      required Color cursorColor,
      required Color selectionBackgroundColor,
      Value<Color?> selectionForegroundColor,
      Value<Color?> cursorTextColor,
      Value<int> rowid,
    });
typedef $CustomTerminalThemesUpdateCompanionBuilder =
    CustomTerminalThemesCompanion Function({
      Value<String> name,
      Value<String?> author,
      Value<Color> blackColor,
      Value<Color> redColor,
      Value<Color> greenColor,
      Value<Color> yellowColor,
      Value<Color> blueColor,
      Value<Color> purpleColor,
      Value<Color> cyanColor,
      Value<Color> whiteColor,
      Value<Color> brightBlackColor,
      Value<Color> brightRedColor,
      Value<Color> brightGreenColor,
      Value<Color> brightYellowColor,
      Value<Color> brightBlueColor,
      Value<Color> brightPurpleColor,
      Value<Color> brightCyanColor,
      Value<Color> brightWhiteColor,
      Value<Color> backgroundColor,
      Value<Color> foregroundColor,
      Value<Color> cursorColor,
      Value<Color> selectionBackgroundColor,
      Value<Color?> selectionForegroundColor,
      Value<Color?> cursorTextColor,
      Value<int> rowid,
    });

final class $CustomTerminalThemesReferences
    extends
        BaseReferences<
          _$CliqDatabase,
          CustomTerminalThemes,
          CustomTerminalTheme
        > {
  $CustomTerminalThemesReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<Connections, List<Connection>>
  _connectionsRefsTable(_$CliqDatabase db) => MultiTypedResultKey.fromTable(
    db.connections,
    aliasName: $_aliasNameGenerator(
      db.customTerminalThemes.name,
      db.connections.terminalThemeOverrideName,
    ),
  );

  $ConnectionsProcessedTableManager get connectionsRefs {
    final manager = $ConnectionsTableManager($_db, $_db.connections).filter(
      (f) => f.terminalThemeOverrideName.name.sqlEquals(
        $_itemColumn<String>('name')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_connectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $CustomTerminalThemesFilterComposer
    extends Composer<_$CliqDatabase, CustomTerminalThemes> {
  $CustomTerminalThemesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Color, Color, int> get blackColor =>
      $composableBuilder(
        column: $table.blackColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get redColor =>
      $composableBuilder(
        column: $table.redColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get greenColor =>
      $composableBuilder(
        column: $table.greenColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get yellowColor =>
      $composableBuilder(
        column: $table.yellowColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get blueColor =>
      $composableBuilder(
        column: $table.blueColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get purpleColor =>
      $composableBuilder(
        column: $table.purpleColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get cyanColor =>
      $composableBuilder(
        column: $table.cyanColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get whiteColor =>
      $composableBuilder(
        column: $table.whiteColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightBlackColor =>
      $composableBuilder(
        column: $table.brightBlackColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightRedColor =>
      $composableBuilder(
        column: $table.brightRedColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightGreenColor =>
      $composableBuilder(
        column: $table.brightGreenColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightYellowColor =>
      $composableBuilder(
        column: $table.brightYellowColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightBlueColor =>
      $composableBuilder(
        column: $table.brightBlueColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightPurpleColor =>
      $composableBuilder(
        column: $table.brightPurpleColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightCyanColor =>
      $composableBuilder(
        column: $table.brightCyanColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightWhiteColor =>
      $composableBuilder(
        column: $table.brightWhiteColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get backgroundColor =>
      $composableBuilder(
        column: $table.backgroundColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get foregroundColor =>
      $composableBuilder(
        column: $table.foregroundColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get cursorColor =>
      $composableBuilder(
        column: $table.cursorColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int>
  get selectionBackgroundColor => $composableBuilder(
    column: $table.selectionBackgroundColor,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Color?, Color, int>
  get selectionForegroundColor => $composableBuilder(
    column: $table.selectionForegroundColor,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Color?, Color, int> get cursorTextColor =>
      $composableBuilder(
        column: $table.cursorTextColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> connectionsRefs(
    Expression<bool> Function($ConnectionsFilterComposer f) f,
  ) {
    final $ConnectionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.name,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.terminalThemeOverrideName,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionsFilterComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CustomTerminalThemesOrderingComposer
    extends Composer<_$CliqDatabase, CustomTerminalThemes> {
  $CustomTerminalThemesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blackColor => $composableBuilder(
    column: $table.blackColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get redColor => $composableBuilder(
    column: $table.redColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get greenColor => $composableBuilder(
    column: $table.greenColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yellowColor => $composableBuilder(
    column: $table.yellowColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blueColor => $composableBuilder(
    column: $table.blueColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purpleColor => $composableBuilder(
    column: $table.purpleColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cyanColor => $composableBuilder(
    column: $table.cyanColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get whiteColor => $composableBuilder(
    column: $table.whiteColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightBlackColor => $composableBuilder(
    column: $table.brightBlackColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightRedColor => $composableBuilder(
    column: $table.brightRedColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightGreenColor => $composableBuilder(
    column: $table.brightGreenColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightYellowColor => $composableBuilder(
    column: $table.brightYellowColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightBlueColor => $composableBuilder(
    column: $table.brightBlueColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightPurpleColor => $composableBuilder(
    column: $table.brightPurpleColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightCyanColor => $composableBuilder(
    column: $table.brightCyanColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightWhiteColor => $composableBuilder(
    column: $table.brightWhiteColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backgroundColor => $composableBuilder(
    column: $table.backgroundColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foregroundColor => $composableBuilder(
    column: $table.foregroundColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursorColor => $composableBuilder(
    column: $table.cursorColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectionBackgroundColor => $composableBuilder(
    column: $table.selectionBackgroundColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectionForegroundColor => $composableBuilder(
    column: $table.selectionForegroundColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursorTextColor => $composableBuilder(
    column: $table.cursorTextColor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CustomTerminalThemesAnnotationComposer
    extends Composer<_$CliqDatabase, CustomTerminalThemes> {
  $CustomTerminalThemesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get blackColor =>
      $composableBuilder(
        column: $table.blackColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get redColor =>
      $composableBuilder(column: $table.redColor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get greenColor =>
      $composableBuilder(
        column: $table.greenColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get yellowColor =>
      $composableBuilder(
        column: $table.yellowColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get blueColor =>
      $composableBuilder(column: $table.blueColor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get purpleColor =>
      $composableBuilder(
        column: $table.purpleColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get cyanColor =>
      $composableBuilder(column: $table.cyanColor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get whiteColor =>
      $composableBuilder(
        column: $table.whiteColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightBlackColor =>
      $composableBuilder(
        column: $table.brightBlackColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightRedColor =>
      $composableBuilder(
        column: $table.brightRedColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightGreenColor =>
      $composableBuilder(
        column: $table.brightGreenColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightYellowColor =>
      $composableBuilder(
        column: $table.brightYellowColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightBlueColor =>
      $composableBuilder(
        column: $table.brightBlueColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightPurpleColor =>
      $composableBuilder(
        column: $table.brightPurpleColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightCyanColor =>
      $composableBuilder(
        column: $table.brightCyanColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightWhiteColor =>
      $composableBuilder(
        column: $table.brightWhiteColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get backgroundColor =>
      $composableBuilder(
        column: $table.backgroundColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get foregroundColor =>
      $composableBuilder(
        column: $table.foregroundColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get cursorColor =>
      $composableBuilder(
        column: $table.cursorColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get selectionBackgroundColor =>
      $composableBuilder(
        column: $table.selectionBackgroundColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color?, int> get selectionForegroundColor =>
      $composableBuilder(
        column: $table.selectionForegroundColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color?, int> get cursorTextColor =>
      $composableBuilder(
        column: $table.cursorTextColor,
        builder: (column) => column,
      );

  Expression<T> connectionsRefs<T extends Object>(
    Expression<T> Function($ConnectionsAnnotationComposer a) f,
  ) {
    final $ConnectionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.name,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.terminalThemeOverrideName,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionsAnnotationComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CustomTerminalThemesTableManager
    extends
        RootTableManager<
          _$CliqDatabase,
          CustomTerminalThemes,
          CustomTerminalTheme,
          $CustomTerminalThemesFilterComposer,
          $CustomTerminalThemesOrderingComposer,
          $CustomTerminalThemesAnnotationComposer,
          $CustomTerminalThemesCreateCompanionBuilder,
          $CustomTerminalThemesUpdateCompanionBuilder,
          (CustomTerminalTheme, $CustomTerminalThemesReferences),
          CustomTerminalTheme,
          PrefetchHooks Function({bool connectionsRefs})
        > {
  $CustomTerminalThemesTableManager(
    _$CliqDatabase db,
    CustomTerminalThemes table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CustomTerminalThemesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CustomTerminalThemesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CustomTerminalThemesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<Color> blackColor = const Value.absent(),
                Value<Color> redColor = const Value.absent(),
                Value<Color> greenColor = const Value.absent(),
                Value<Color> yellowColor = const Value.absent(),
                Value<Color> blueColor = const Value.absent(),
                Value<Color> purpleColor = const Value.absent(),
                Value<Color> cyanColor = const Value.absent(),
                Value<Color> whiteColor = const Value.absent(),
                Value<Color> brightBlackColor = const Value.absent(),
                Value<Color> brightRedColor = const Value.absent(),
                Value<Color> brightGreenColor = const Value.absent(),
                Value<Color> brightYellowColor = const Value.absent(),
                Value<Color> brightBlueColor = const Value.absent(),
                Value<Color> brightPurpleColor = const Value.absent(),
                Value<Color> brightCyanColor = const Value.absent(),
                Value<Color> brightWhiteColor = const Value.absent(),
                Value<Color> backgroundColor = const Value.absent(),
                Value<Color> foregroundColor = const Value.absent(),
                Value<Color> cursorColor = const Value.absent(),
                Value<Color> selectionBackgroundColor = const Value.absent(),
                Value<Color?> selectionForegroundColor = const Value.absent(),
                Value<Color?> cursorTextColor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomTerminalThemesCompanion(
                name: name,
                author: author,
                blackColor: blackColor,
                redColor: redColor,
                greenColor: greenColor,
                yellowColor: yellowColor,
                blueColor: blueColor,
                purpleColor: purpleColor,
                cyanColor: cyanColor,
                whiteColor: whiteColor,
                brightBlackColor: brightBlackColor,
                brightRedColor: brightRedColor,
                brightGreenColor: brightGreenColor,
                brightYellowColor: brightYellowColor,
                brightBlueColor: brightBlueColor,
                brightPurpleColor: brightPurpleColor,
                brightCyanColor: brightCyanColor,
                brightWhiteColor: brightWhiteColor,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                cursorColor: cursorColor,
                selectionBackgroundColor: selectionBackgroundColor,
                selectionForegroundColor: selectionForegroundColor,
                cursorTextColor: cursorTextColor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                Value<String?> author = const Value.absent(),
                required Color blackColor,
                required Color redColor,
                required Color greenColor,
                required Color yellowColor,
                required Color blueColor,
                required Color purpleColor,
                required Color cyanColor,
                required Color whiteColor,
                required Color brightBlackColor,
                required Color brightRedColor,
                required Color brightGreenColor,
                required Color brightYellowColor,
                required Color brightBlueColor,
                required Color brightPurpleColor,
                required Color brightCyanColor,
                required Color brightWhiteColor,
                required Color backgroundColor,
                required Color foregroundColor,
                required Color cursorColor,
                required Color selectionBackgroundColor,
                Value<Color?> selectionForegroundColor = const Value.absent(),
                Value<Color?> cursorTextColor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomTerminalThemesCompanion.insert(
                name: name,
                author: author,
                blackColor: blackColor,
                redColor: redColor,
                greenColor: greenColor,
                yellowColor: yellowColor,
                blueColor: blueColor,
                purpleColor: purpleColor,
                cyanColor: cyanColor,
                whiteColor: whiteColor,
                brightBlackColor: brightBlackColor,
                brightRedColor: brightRedColor,
                brightGreenColor: brightGreenColor,
                brightYellowColor: brightYellowColor,
                brightBlueColor: brightBlueColor,
                brightPurpleColor: brightPurpleColor,
                brightCyanColor: brightCyanColor,
                brightWhiteColor: brightWhiteColor,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                cursorColor: cursorColor,
                selectionBackgroundColor: selectionBackgroundColor,
                selectionForegroundColor: selectionForegroundColor,
                cursorTextColor: cursorTextColor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $CustomTerminalThemesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({connectionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (connectionsRefs) db.connections],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (connectionsRefs)
                    await $_getPrefetchedData<
                      CustomTerminalTheme,
                      CustomTerminalThemes,
                      Connection
                    >(
                      currentTable: table,
                      referencedTable: $CustomTerminalThemesReferences
                          ._connectionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $CustomTerminalThemesReferences(
                            db,
                            table,
                            p0,
                          ).connectionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.terminalThemeOverrideName == item.name,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $CustomTerminalThemesProcessedTableManager =
    ProcessedTableManager<
      _$CliqDatabase,
      CustomTerminalThemes,
      CustomTerminalTheme,
      $CustomTerminalThemesFilterComposer,
      $CustomTerminalThemesOrderingComposer,
      $CustomTerminalThemesAnnotationComposer,
      $CustomTerminalThemesCreateCompanionBuilder,
      $CustomTerminalThemesUpdateCompanionBuilder,
      (CustomTerminalTheme, $CustomTerminalThemesReferences),
      CustomTerminalTheme,
      PrefetchHooks Function({bool connectionsRefs})
    >;
typedef $CredentialsCreateCompanionBuilder =
    CredentialsCompanion Function({
      Value<int> id,
      required CredentialType type,
      required String data,
      Value<String?> passphrase,
    });
typedef $CredentialsUpdateCompanionBuilder =
    CredentialsCompanion Function({
      Value<int> id,
      Value<CredentialType> type,
      Value<String> data,
      Value<String?> passphrase,
    });

final class $CredentialsReferences
    extends BaseReferences<_$CliqDatabase, Credentials, Credential> {
  $CredentialsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Identities, List<Identity>> _identitiesRefsTable(
    _$CliqDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.identities,
    aliasName: $_aliasNameGenerator(
      db.credentials.id,
      db.identities.credentialId,
    ),
  );

  $IdentitiesProcessedTableManager get identitiesRefs {
    final manager = $IdentitiesTableManager(
      $_db,
      $_db.identities,
    ).filter((f) => f.credentialId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_identitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Connections, List<Connection>>
  _connectionsRefsTable(_$CliqDatabase db) => MultiTypedResultKey.fromTable(
    db.connections,
    aliasName: $_aliasNameGenerator(
      db.credentials.id,
      db.connections.credentialId,
    ),
  );

  $ConnectionsProcessedTableManager get connectionsRefs {
    final manager = $ConnectionsTableManager(
      $_db,
      $_db.connections,
    ).filter((f) => f.credentialId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_connectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $CredentialsFilterComposer extends Composer<_$CliqDatabase, Credentials> {
  $CredentialsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CredentialType, CredentialType, int>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> identitiesRefs(
    Expression<bool> Function($IdentitiesFilterComposer f) f,
  ) {
    final $IdentitiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.identities,
      getReferencedColumn: (t) => t.credentialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IdentitiesFilterComposer(
            $db: $db,
            $table: $db.identities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> connectionsRefs(
    Expression<bool> Function($ConnectionsFilterComposer f) f,
  ) {
    final $ConnectionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.credentialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionsFilterComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CredentialsOrderingComposer
    extends Composer<_$CliqDatabase, Credentials> {
  $CredentialsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CredentialsAnnotationComposer
    extends Composer<_$CliqDatabase, Credentials> {
  $CredentialsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CredentialType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => column,
  );

  Expression<T> identitiesRefs<T extends Object>(
    Expression<T> Function($IdentitiesAnnotationComposer a) f,
  ) {
    final $IdentitiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.identities,
      getReferencedColumn: (t) => t.credentialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IdentitiesAnnotationComposer(
            $db: $db,
            $table: $db.identities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> connectionsRefs<T extends Object>(
    Expression<T> Function($ConnectionsAnnotationComposer a) f,
  ) {
    final $ConnectionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.credentialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionsAnnotationComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CredentialsTableManager
    extends
        RootTableManager<
          _$CliqDatabase,
          Credentials,
          Credential,
          $CredentialsFilterComposer,
          $CredentialsOrderingComposer,
          $CredentialsAnnotationComposer,
          $CredentialsCreateCompanionBuilder,
          $CredentialsUpdateCompanionBuilder,
          (Credential, $CredentialsReferences),
          Credential,
          PrefetchHooks Function({bool identitiesRefs, bool connectionsRefs})
        > {
  $CredentialsTableManager(_$CliqDatabase db, Credentials table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CredentialsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CredentialsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CredentialsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<CredentialType> type = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<String?> passphrase = const Value.absent(),
              }) => CredentialsCompanion(
                id: id,
                type: type,
                data: data,
                passphrase: passphrase,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required CredentialType type,
                required String data,
                Value<String?> passphrase = const Value.absent(),
              }) => CredentialsCompanion.insert(
                id: id,
                type: type,
                data: data,
                passphrase: passphrase,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $CredentialsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({identitiesRefs = false, connectionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (identitiesRefs) db.identities,
                    if (connectionsRefs) db.connections,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (identitiesRefs)
                        await $_getPrefetchedData<
                          Credential,
                          Credentials,
                          Identity
                        >(
                          currentTable: table,
                          referencedTable: $CredentialsReferences
                              ._identitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $CredentialsReferences(
                                db,
                                table,
                                p0,
                              ).identitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.credentialId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (connectionsRefs)
                        await $_getPrefetchedData<
                          Credential,
                          Credentials,
                          Connection
                        >(
                          currentTable: table,
                          referencedTable: $CredentialsReferences
                              ._connectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $CredentialsReferences(
                                db,
                                table,
                                p0,
                              ).connectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.credentialId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $CredentialsProcessedTableManager =
    ProcessedTableManager<
      _$CliqDatabase,
      Credentials,
      Credential,
      $CredentialsFilterComposer,
      $CredentialsOrderingComposer,
      $CredentialsAnnotationComposer,
      $CredentialsCreateCompanionBuilder,
      $CredentialsUpdateCompanionBuilder,
      (Credential, $CredentialsReferences),
      Credential,
      PrefetchHooks Function({bool identitiesRefs, bool connectionsRefs})
    >;
typedef $IdentitiesCreateCompanionBuilder =
    IdentitiesCompanion Function({
      Value<int> id,
      required String username,
      required int credentialId,
    });
typedef $IdentitiesUpdateCompanionBuilder =
    IdentitiesCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<int> credentialId,
    });

final class $IdentitiesReferences
    extends BaseReferences<_$CliqDatabase, Identities, Identity> {
  $IdentitiesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Credentials _credentialIdTable(_$CliqDatabase db) =>
      db.credentials.createAlias(
        $_aliasNameGenerator(db.identities.credentialId, db.credentials.id),
      );

  $CredentialsProcessedTableManager get credentialId {
    final $_column = $_itemColumn<int>('credential_id')!;

    final manager = $CredentialsTableManager(
      $_db,
      $_db.credentials,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_credentialIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Connections, List<Connection>>
  _connectionsRefsTable(_$CliqDatabase db) => MultiTypedResultKey.fromTable(
    db.connections,
    aliasName: $_aliasNameGenerator(
      db.identities.id,
      db.connections.identityId,
    ),
  );

  $ConnectionsProcessedTableManager get connectionsRefs {
    final manager = $ConnectionsTableManager(
      $_db,
      $_db.connections,
    ).filter((f) => f.identityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_connectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $IdentitiesFilterComposer extends Composer<_$CliqDatabase, Identities> {
  $IdentitiesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  $CredentialsFilterComposer get credentialId {
    final $CredentialsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.credentialId,
      referencedTable: $db.credentials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CredentialsFilterComposer(
            $db: $db,
            $table: $db.credentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> connectionsRefs(
    Expression<bool> Function($ConnectionsFilterComposer f) f,
  ) {
    final $ConnectionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionsFilterComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $IdentitiesOrderingComposer extends Composer<_$CliqDatabase, Identities> {
  $IdentitiesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  $CredentialsOrderingComposer get credentialId {
    final $CredentialsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.credentialId,
      referencedTable: $db.credentials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CredentialsOrderingComposer(
            $db: $db,
            $table: $db.credentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $IdentitiesAnnotationComposer
    extends Composer<_$CliqDatabase, Identities> {
  $IdentitiesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  $CredentialsAnnotationComposer get credentialId {
    final $CredentialsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.credentialId,
      referencedTable: $db.credentials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CredentialsAnnotationComposer(
            $db: $db,
            $table: $db.credentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> connectionsRefs<T extends Object>(
    Expression<T> Function($ConnectionsAnnotationComposer a) f,
  ) {
    final $ConnectionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionsAnnotationComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $IdentitiesTableManager
    extends
        RootTableManager<
          _$CliqDatabase,
          Identities,
          Identity,
          $IdentitiesFilterComposer,
          $IdentitiesOrderingComposer,
          $IdentitiesAnnotationComposer,
          $IdentitiesCreateCompanionBuilder,
          $IdentitiesUpdateCompanionBuilder,
          (Identity, $IdentitiesReferences),
          Identity,
          PrefetchHooks Function({bool credentialId, bool connectionsRefs})
        > {
  $IdentitiesTableManager(_$CliqDatabase db, Identities table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $IdentitiesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $IdentitiesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $IdentitiesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<int> credentialId = const Value.absent(),
              }) => IdentitiesCompanion(
                id: id,
                username: username,
                credentialId: credentialId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required int credentialId,
              }) => IdentitiesCompanion.insert(
                id: id,
                username: username,
                credentialId: credentialId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $IdentitiesReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({credentialId = false, connectionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (connectionsRefs) db.connections,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (credentialId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.credentialId,
                                    referencedTable: $IdentitiesReferences
                                        ._credentialIdTable(db),
                                    referencedColumn: $IdentitiesReferences
                                        ._credentialIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (connectionsRefs)
                        await $_getPrefetchedData<
                          Identity,
                          Identities,
                          Connection
                        >(
                          currentTable: table,
                          referencedTable: $IdentitiesReferences
                              ._connectionsRefsTable(db),
                          managerFromTypedResult: (p0) => $IdentitiesReferences(
                            db,
                            table,
                            p0,
                          ).connectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.identityId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $IdentitiesProcessedTableManager =
    ProcessedTableManager<
      _$CliqDatabase,
      Identities,
      Identity,
      $IdentitiesFilterComposer,
      $IdentitiesOrderingComposer,
      $IdentitiesAnnotationComposer,
      $IdentitiesCreateCompanionBuilder,
      $IdentitiesUpdateCompanionBuilder,
      (Identity, $IdentitiesReferences),
      Identity,
      PrefetchHooks Function({bool credentialId, bool connectionsRefs})
    >;
typedef $ConnectionsCreateCompanionBuilder =
    ConnectionsCompanion Function({
      Value<int> id,
      required String address,
      required int port,
      Value<int?> identityId,
      Value<String?> username,
      Value<int?> credentialId,
      Value<String?> label,
      Value<ConnectionIcon> icon,
      Value<String?> color,
      Value<String?> groupName,
      Value<int?> terminalFontSizeOverride,
      Value<String?> terminalFontFamilyOverride,
      Value<String?> terminalThemeOverrideName,
    });
typedef $ConnectionsUpdateCompanionBuilder =
    ConnectionsCompanion Function({
      Value<int> id,
      Value<String> address,
      Value<int> port,
      Value<int?> identityId,
      Value<String?> username,
      Value<int?> credentialId,
      Value<String?> label,
      Value<ConnectionIcon> icon,
      Value<String?> color,
      Value<String?> groupName,
      Value<int?> terminalFontSizeOverride,
      Value<String?> terminalFontFamilyOverride,
      Value<String?> terminalThemeOverrideName,
    });

final class $ConnectionsReferences
    extends BaseReferences<_$CliqDatabase, Connections, Connection> {
  $ConnectionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Identities _identityIdTable(_$CliqDatabase db) =>
      db.identities.createAlias(
        $_aliasNameGenerator(db.connections.identityId, db.identities.id),
      );

  $IdentitiesProcessedTableManager? get identityId {
    final $_column = $_itemColumn<int>('identity_id');
    if ($_column == null) return null;
    final manager = $IdentitiesTableManager(
      $_db,
      $_db.identities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_identityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Credentials _credentialIdTable(_$CliqDatabase db) =>
      db.credentials.createAlias(
        $_aliasNameGenerator(db.connections.credentialId, db.credentials.id),
      );

  $CredentialsProcessedTableManager? get credentialId {
    final $_column = $_itemColumn<int>('credential_id');
    if ($_column == null) return null;
    final manager = $CredentialsTableManager(
      $_db,
      $_db.credentials,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_credentialIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static CustomTerminalThemes _terminalThemeOverrideNameTable(
    _$CliqDatabase db,
  ) => db.customTerminalThemes.createAlias(
    $_aliasNameGenerator(
      db.connections.terminalThemeOverrideName,
      db.customTerminalThemes.name,
    ),
  );

  $CustomTerminalThemesProcessedTableManager? get terminalThemeOverrideName {
    final $_column = $_itemColumn<String>('terminal_theme_override_name');
    if ($_column == null) return null;
    final manager = $CustomTerminalThemesTableManager(
      $_db,
      $_db.customTerminalThemes,
    ).filter((f) => f.name.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _terminalThemeOverrideNameTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ConnectionsFilterComposer extends Composer<_$CliqDatabase, Connections> {
  $ConnectionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ConnectionIcon, ConnectionIcon, int>
  get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get terminalFontSizeOverride => $composableBuilder(
    column: $table.terminalFontSizeOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get terminalFontFamilyOverride => $composableBuilder(
    column: $table.terminalFontFamilyOverride,
    builder: (column) => ColumnFilters(column),
  );

  $IdentitiesFilterComposer get identityId {
    final $IdentitiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IdentitiesFilterComposer(
            $db: $db,
            $table: $db.identities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CredentialsFilterComposer get credentialId {
    final $CredentialsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.credentialId,
      referencedTable: $db.credentials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CredentialsFilterComposer(
            $db: $db,
            $table: $db.credentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CustomTerminalThemesFilterComposer get terminalThemeOverrideName {
    final $CustomTerminalThemesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terminalThemeOverrideName,
      referencedTable: $db.customTerminalThemes,
      getReferencedColumn: (t) => t.name,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CustomTerminalThemesFilterComposer(
            $db: $db,
            $table: $db.customTerminalThemes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ConnectionsOrderingComposer
    extends Composer<_$CliqDatabase, Connections> {
  $ConnectionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get terminalFontSizeOverride => $composableBuilder(
    column: $table.terminalFontSizeOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terminalFontFamilyOverride => $composableBuilder(
    column: $table.terminalFontFamilyOverride,
    builder: (column) => ColumnOrderings(column),
  );

  $IdentitiesOrderingComposer get identityId {
    final $IdentitiesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IdentitiesOrderingComposer(
            $db: $db,
            $table: $db.identities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CredentialsOrderingComposer get credentialId {
    final $CredentialsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.credentialId,
      referencedTable: $db.credentials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CredentialsOrderingComposer(
            $db: $db,
            $table: $db.credentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CustomTerminalThemesOrderingComposer get terminalThemeOverrideName {
    final $CustomTerminalThemesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terminalThemeOverrideName,
      referencedTable: $db.customTerminalThemes,
      getReferencedColumn: (t) => t.name,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CustomTerminalThemesOrderingComposer(
            $db: $db,
            $table: $db.customTerminalThemes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ConnectionsAnnotationComposer
    extends Composer<_$CliqDatabase, Connections> {
  $ConnectionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ConnectionIcon, int> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<int> get terminalFontSizeOverride => $composableBuilder(
    column: $table.terminalFontSizeOverride,
    builder: (column) => column,
  );

  GeneratedColumn<String> get terminalFontFamilyOverride => $composableBuilder(
    column: $table.terminalFontFamilyOverride,
    builder: (column) => column,
  );

  $IdentitiesAnnotationComposer get identityId {
    final $IdentitiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.identityId,
      referencedTable: $db.identities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IdentitiesAnnotationComposer(
            $db: $db,
            $table: $db.identities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CredentialsAnnotationComposer get credentialId {
    final $CredentialsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.credentialId,
      referencedTable: $db.credentials,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CredentialsAnnotationComposer(
            $db: $db,
            $table: $db.credentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CustomTerminalThemesAnnotationComposer get terminalThemeOverrideName {
    final $CustomTerminalThemesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terminalThemeOverrideName,
      referencedTable: $db.customTerminalThemes,
      getReferencedColumn: (t) => t.name,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CustomTerminalThemesAnnotationComposer(
            $db: $db,
            $table: $db.customTerminalThemes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ConnectionsTableManager
    extends
        RootTableManager<
          _$CliqDatabase,
          Connections,
          Connection,
          $ConnectionsFilterComposer,
          $ConnectionsOrderingComposer,
          $ConnectionsAnnotationComposer,
          $ConnectionsCreateCompanionBuilder,
          $ConnectionsUpdateCompanionBuilder,
          (Connection, $ConnectionsReferences),
          Connection,
          PrefetchHooks Function({
            bool identityId,
            bool credentialId,
            bool terminalThemeOverrideName,
          })
        > {
  $ConnectionsTableManager(_$CliqDatabase db, Connections table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ConnectionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ConnectionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ConnectionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<int?> identityId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<int?> credentialId = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<ConnectionIcon> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<int?> terminalFontSizeOverride = const Value.absent(),
                Value<String?> terminalFontFamilyOverride =
                    const Value.absent(),
                Value<String?> terminalThemeOverrideName = const Value.absent(),
              }) => ConnectionsCompanion(
                id: id,
                address: address,
                port: port,
                identityId: identityId,
                username: username,
                credentialId: credentialId,
                label: label,
                icon: icon,
                color: color,
                groupName: groupName,
                terminalFontSizeOverride: terminalFontSizeOverride,
                terminalFontFamilyOverride: terminalFontFamilyOverride,
                terminalThemeOverrideName: terminalThemeOverrideName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String address,
                required int port,
                Value<int?> identityId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<int?> credentialId = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<ConnectionIcon> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<int?> terminalFontSizeOverride = const Value.absent(),
                Value<String?> terminalFontFamilyOverride =
                    const Value.absent(),
                Value<String?> terminalThemeOverrideName = const Value.absent(),
              }) => ConnectionsCompanion.insert(
                id: id,
                address: address,
                port: port,
                identityId: identityId,
                username: username,
                credentialId: credentialId,
                label: label,
                icon: icon,
                color: color,
                groupName: groupName,
                terminalFontSizeOverride: terminalFontSizeOverride,
                terminalFontFamilyOverride: terminalFontFamilyOverride,
                terminalThemeOverrideName: terminalThemeOverrideName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $ConnectionsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                identityId = false,
                credentialId = false,
                terminalThemeOverrideName = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (identityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.identityId,
                                    referencedTable: $ConnectionsReferences
                                        ._identityIdTable(db),
                                    referencedColumn: $ConnectionsReferences
                                        ._identityIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (credentialId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.credentialId,
                                    referencedTable: $ConnectionsReferences
                                        ._credentialIdTable(db),
                                    referencedColumn: $ConnectionsReferences
                                        ._credentialIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (terminalThemeOverrideName) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.terminalThemeOverrideName,
                                    referencedTable: $ConnectionsReferences
                                        ._terminalThemeOverrideNameTable(db),
                                    referencedColumn: $ConnectionsReferences
                                        ._terminalThemeOverrideNameTable(db)
                                        .name,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $ConnectionsProcessedTableManager =
    ProcessedTableManager<
      _$CliqDatabase,
      Connections,
      Connection,
      $ConnectionsFilterComposer,
      $ConnectionsOrderingComposer,
      $ConnectionsAnnotationComposer,
      $ConnectionsCreateCompanionBuilder,
      $ConnectionsUpdateCompanionBuilder,
      (Connection, $ConnectionsReferences),
      Connection,
      PrefetchHooks Function({
        bool identityId,
        bool credentialId,
        bool terminalThemeOverrideName,
      })
    >;

class $CliqDatabaseManager {
  final _$CliqDatabase _db;
  $CliqDatabaseManager(this._db);
  $CustomTerminalThemesTableManager get customTerminalThemes =>
      $CustomTerminalThemesTableManager(_db, _db.customTerminalThemes);
  $CredentialsTableManager get credentials =>
      $CredentialsTableManager(_db, _db.credentials);
  $IdentitiesTableManager get identities =>
      $IdentitiesTableManager(_db, _db.identities);
  $ConnectionsTableManager get connections =>
      $ConnectionsTableManager(_db, _db.connections);
}

class FindAllConnectionFullResult {
  final Connection connection;
  final Identity? identity;
  final Credential? credential;
  final Credential? identityCredential;
  final CustomTerminalTheme? terminalThemeOverride;
  FindAllConnectionFullResult({
    required this.connection,
    this.identity,
    this.credential,
    this.identityCredential,
    this.terminalThemeOverride,
  });
}
