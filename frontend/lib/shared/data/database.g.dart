// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class KnownHosts extends Table with TableInfo<KnownHosts, KnownHost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  KnownHosts(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _hostKeyMeta = const VerificationMeta(
    'hostKey',
  );
  late final GeneratedColumn<Uint8List> hostKey = GeneratedColumn<Uint8List>(
    'hostKey',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
    defaultValue: const CustomExpression('CURRENT_TIMESTAMP'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, host, hostKey, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'known_hosts';
  @override
  VerificationContext validateIntegrity(
    Insertable<KnownHost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('hostKey')) {
      context.handle(
        _hostKeyMeta,
        hostKey.isAcceptableOrUnknown(data['hostKey']!, _hostKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_hostKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KnownHost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KnownHost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      hostKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}hostKey'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  KnownHosts createAlias(String alias) {
    return KnownHosts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class KnownHost extends DataClass implements Insertable<KnownHost> {
  final int id;
  final String host;
  final Uint8List hostKey;
  final DateTime createdAt;
  const KnownHost({
    required this.id,
    required this.host,
    required this.hostKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['host'] = Variable<String>(host);
    map['hostKey'] = Variable<Uint8List>(hostKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  KnownHostsCompanion toCompanion(bool nullToAbsent) {
    return KnownHostsCompanion(
      id: Value(id),
      host: Value(host),
      hostKey: Value(hostKey),
      createdAt: Value(createdAt),
    );
  }

  factory KnownHost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KnownHost(
      id: serializer.fromJson<int>(json['id']),
      host: serializer.fromJson<String>(json['host']),
      hostKey: serializer.fromJson<Uint8List>(json['hostKey']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'host': serializer.toJson<String>(host),
      'hostKey': serializer.toJson<Uint8List>(hostKey),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  KnownHost copyWith({
    int? id,
    String? host,
    Uint8List? hostKey,
    DateTime? createdAt,
  }) => KnownHost(
    id: id ?? this.id,
    host: host ?? this.host,
    hostKey: hostKey ?? this.hostKey,
    createdAt: createdAt ?? this.createdAt,
  );
  KnownHost copyWithCompanion(KnownHostsCompanion data) {
    return KnownHost(
      id: data.id.present ? data.id.value : this.id,
      host: data.host.present ? data.host.value : this.host,
      hostKey: data.hostKey.present ? data.hostKey.value : this.hostKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KnownHost(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('hostKey: $hostKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, host, $driftBlobEquality.hash(hostKey), createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KnownHost &&
          other.id == this.id &&
          other.host == this.host &&
          $driftBlobEquality.equals(other.hostKey, this.hostKey) &&
          other.createdAt == this.createdAt);
}

class KnownHostsCompanion extends UpdateCompanion<KnownHost> {
  final Value<int> id;
  final Value<String> host;
  final Value<Uint8List> hostKey;
  final Value<DateTime> createdAt;
  const KnownHostsCompanion({
    this.id = const Value.absent(),
    this.host = const Value.absent(),
    this.hostKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  KnownHostsCompanion.insert({
    this.id = const Value.absent(),
    required String host,
    required Uint8List hostKey,
    this.createdAt = const Value.absent(),
  }) : host = Value(host),
       hostKey = Value(hostKey);
  static Insertable<KnownHost> custom({
    Expression<int>? id,
    Expression<String>? host,
    Expression<Uint8List>? hostKey,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (hostKey != null) 'hostKey': hostKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  KnownHostsCompanion copyWith({
    Value<int>? id,
    Value<String>? host,
    Value<Uint8List>? hostKey,
    Value<DateTime>? createdAt,
  }) {
    return KnownHostsCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
      hostKey: hostKey ?? this.hostKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (hostKey.present) {
      map['hostKey'] = Variable<Uint8List>(hostKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KnownHostsCompanion(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('hostKey: $hostKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class CustomTerminalThemes extends Table
    with TableInfo<CustomTerminalThemes, CustomTerminalTheme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CustomTerminalThemes(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
    id,
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name},
  ];
  @override
  CustomTerminalTheme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomTerminalTheme(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
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
  List<String> get customConstraints => const ['UNIQUE(name)'];
  @override
  bool get dontWriteConstraints => true;
}

class CustomTerminalTheme extends DataClass
    implements Insertable<CustomTerminalTheme> {
  final int id;
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
    required this.id,
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
    map['id'] = Variable<int>(id);
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
      id: Value(id),
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
      id: serializer.fromJson<int>(json['id']),
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
      'id': serializer.toJson<int>(id),
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
    int? id,
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
    id: id ?? this.id,
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
      id: data.id.present ? data.id.value : this.id,
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
          ..write('id: $id, ')
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
    id,
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
          other.id == this.id &&
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
  final Value<int> id;
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
  const CustomTerminalThemesCompanion({
    this.id = const Value.absent(),
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
  });
  CustomTerminalThemesCompanion.insert({
    this.id = const Value.absent(),
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
    Expression<int>? id,
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
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
    });
  }

  CustomTerminalThemesCompanion copyWith({
    Value<int>? id,
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
  }) {
    return CustomTerminalThemesCompanion(
      id: id ?? this.id,
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
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomTerminalThemesCompanion(')
          ..write('id: $id, ')
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
}

class Keys extends Table with TableInfo<Keys, Key> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Keys(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _privatePemMeta = const VerificationMeta(
    'privatePem',
  );
  late final GeneratedColumn<String> privatePem = GeneratedColumn<String>(
    'private_pem',
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
  List<GeneratedColumn> get $columns => [id, label, privatePem, passphrase];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'keys';
  @override
  VerificationContext validateIntegrity(
    Insertable<Key> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('private_pem')) {
      context.handle(
        _privatePemMeta,
        privatePem.isAcceptableOrUnknown(data['private_pem']!, _privatePemMeta),
      );
    } else if (isInserting) {
      context.missing(_privatePemMeta);
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
  Key map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Key(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      privatePem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}private_pem'],
      )!,
      passphrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passphrase'],
      ),
    );
  }

  @override
  Keys createAlias(String alias) {
    return Keys(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Key extends DataClass implements Insertable<Key> {
  final int id;
  final String label;
  final String privatePem;
  final String? passphrase;
  const Key({
    required this.id,
    required this.label,
    required this.privatePem,
    this.passphrase,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['private_pem'] = Variable<String>(privatePem);
    if (!nullToAbsent || passphrase != null) {
      map['passphrase'] = Variable<String>(passphrase);
    }
    return map;
  }

  KeysCompanion toCompanion(bool nullToAbsent) {
    return KeysCompanion(
      id: Value(id),
      label: Value(label),
      privatePem: Value(privatePem),
      passphrase: passphrase == null && nullToAbsent
          ? const Value.absent()
          : Value(passphrase),
    );
  }

  factory Key.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Key(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      privatePem: serializer.fromJson<String>(json['private_pem']),
      passphrase: serializer.fromJson<String?>(json['passphrase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'private_pem': serializer.toJson<String>(privatePem),
      'passphrase': serializer.toJson<String?>(passphrase),
    };
  }

  Key copyWith({
    int? id,
    String? label,
    String? privatePem,
    Value<String?> passphrase = const Value.absent(),
  }) => Key(
    id: id ?? this.id,
    label: label ?? this.label,
    privatePem: privatePem ?? this.privatePem,
    passphrase: passphrase.present ? passphrase.value : this.passphrase,
  );
  Key copyWithCompanion(KeysCompanion data) {
    return Key(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      privatePem: data.privatePem.present
          ? data.privatePem.value
          : this.privatePem,
      passphrase: data.passphrase.present
          ? data.passphrase.value
          : this.passphrase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Key(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('privatePem: $privatePem, ')
          ..write('passphrase: $passphrase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, privatePem, passphrase);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Key &&
          other.id == this.id &&
          other.label == this.label &&
          other.privatePem == this.privatePem &&
          other.passphrase == this.passphrase);
}

class KeysCompanion extends UpdateCompanion<Key> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> privatePem;
  final Value<String?> passphrase;
  const KeysCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.privatePem = const Value.absent(),
    this.passphrase = const Value.absent(),
  });
  KeysCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String privatePem,
    this.passphrase = const Value.absent(),
  }) : label = Value(label),
       privatePem = Value(privatePem);
  static Insertable<Key> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? privatePem,
    Expression<String>? passphrase,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (privatePem != null) 'private_pem': privatePem,
      if (passphrase != null) 'passphrase': passphrase,
    });
  }

  KeysCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? privatePem,
    Value<String?>? passphrase,
  }) {
    return KeysCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      privatePem: privatePem ?? this.privatePem,
      passphrase: passphrase ?? this.passphrase,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (privatePem.present) {
      map['private_pem'] = Variable<String>(privatePem.value);
    }
    if (passphrase.present) {
      map['passphrase'] = Variable<String>(passphrase.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeysCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('privatePem: $privatePem, ')
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
  @override
  List<GeneratedColumn> get $columns => [id, label, username];
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
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
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
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
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
  final String label;
  final String username;
  const Identity({
    required this.id,
    required this.label,
    required this.username,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['username'] = Variable<String>(username);
    return map;
  }

  IdentitiesCompanion toCompanion(bool nullToAbsent) {
    return IdentitiesCompanion(
      id: Value(id),
      label: Value(label),
      username: Value(username),
    );
  }

  factory Identity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Identity(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      username: serializer.fromJson<String>(json['username']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'username': serializer.toJson<String>(username),
    };
  }

  Identity copyWith({int? id, String? label, String? username}) => Identity(
    id: id ?? this.id,
    label: label ?? this.label,
    username: username ?? this.username,
  );
  Identity copyWithCompanion(IdentitiesCompanion data) {
    return Identity(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      username: data.username.present ? data.username.value : this.username,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Identity(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('username: $username')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, username);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Identity &&
          other.id == this.id &&
          other.label == this.label &&
          other.username == this.username);
}

class IdentitiesCompanion extends UpdateCompanion<Identity> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> username;
  const IdentitiesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.username = const Value.absent(),
  });
  IdentitiesCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String username,
  }) : label = Value(label),
       username = Value(username);
  static Insertable<Identity> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? username,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (username != null) 'username': username,
    });
  }

  IdentitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? username,
  }) {
    return IdentitiesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      username: username ?? this.username,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentitiesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('username: $username')
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
  late final GeneratedColumnWithTypeConverter<CredentialType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<CredentialType>(Credentials.$convertertype);
  static const VerificationMeta _keyIdMeta = const VerificationMeta('keyId');
  late final GeneratedColumn<int> keyId = GeneratedColumn<int>(
    'key_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES keys(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CONSTRAINT password_or_key_id CHECK ((type = \'password\' AND password IS NOT NULL AND key_id IS NULL)OR(type = \'key\' AND key_id IS NOT NULL AND password IS NULL))',
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, keyId, password];
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
    if (data.containsKey('key_id')) {
      context.handle(
        _keyIdMeta,
        keyId.isAcceptableOrUnknown(data['key_id']!, _keyIdMeta),
      );
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
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
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      keyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_id'],
      ),
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      ),
    );
  }

  @override
  Credentials createAlias(String alias) {
    return Credentials(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CredentialType, String, String> $convertertype =
      const EnumNameConverter<CredentialType>(CredentialType.values);
  @override
  bool get dontWriteConstraints => true;
}

class Credential extends DataClass implements Insertable<Credential> {
  final int id;
  final CredentialType type;
  final int? keyId;
  final String? password;
  const Credential({
    required this.id,
    required this.type,
    this.keyId,
    this.password,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<String>(Credentials.$convertertype.toSql(type));
    }
    if (!nullToAbsent || keyId != null) {
      map['key_id'] = Variable<int>(keyId);
    }
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    return map;
  }

  CredentialsCompanion toCompanion(bool nullToAbsent) {
    return CredentialsCompanion(
      id: Value(id),
      type: Value(type),
      keyId: keyId == null && nullToAbsent
          ? const Value.absent()
          : Value(keyId),
      password: password == null && nullToAbsent
          ? const Value.absent()
          : Value(password),
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
        serializer.fromJson<String>(json['type']),
      ),
      keyId: serializer.fromJson<int?>(json['key_id']),
      password: serializer.fromJson<String?>(json['password']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(
        Credentials.$convertertype.toJson(type),
      ),
      'key_id': serializer.toJson<int?>(keyId),
      'password': serializer.toJson<String?>(password),
    };
  }

  Credential copyWith({
    int? id,
    CredentialType? type,
    Value<int?> keyId = const Value.absent(),
    Value<String?> password = const Value.absent(),
  }) => Credential(
    id: id ?? this.id,
    type: type ?? this.type,
    keyId: keyId.present ? keyId.value : this.keyId,
    password: password.present ? password.value : this.password,
  );
  Credential copyWithCompanion(CredentialsCompanion data) {
    return Credential(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      keyId: data.keyId.present ? data.keyId.value : this.keyId,
      password: data.password.present ? data.password.value : this.password,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Credential(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('keyId: $keyId, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, keyId, password);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Credential &&
          other.id == this.id &&
          other.type == this.type &&
          other.keyId == this.keyId &&
          other.password == this.password);
}

class CredentialsCompanion extends UpdateCompanion<Credential> {
  final Value<int> id;
  final Value<CredentialType> type;
  final Value<int?> keyId;
  final Value<String?> password;
  const CredentialsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.keyId = const Value.absent(),
    this.password = const Value.absent(),
  });
  CredentialsCompanion.insert({
    this.id = const Value.absent(),
    required CredentialType type,
    this.keyId = const Value.absent(),
    this.password = const Value.absent(),
  }) : type = Value(type);
  static Insertable<Credential> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? keyId,
    Expression<String>? password,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (keyId != null) 'key_id': keyId,
      if (password != null) 'password': password,
    });
  }

  CredentialsCompanion copyWith({
    Value<int>? id,
    Value<CredentialType>? type,
    Value<int?>? keyId,
    Value<String?>? password,
  }) {
    return CredentialsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      keyId: keyId ?? this.keyId,
      password: password ?? this.password,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        Credentials.$convertertype.toSql(type.value),
      );
    }
    if (keyId.present) {
      map['key_id'] = Variable<int>(keyId.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CredentialsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('keyId: $keyId, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }
}

class IdentityCredentials extends Table
    with TableInfo<IdentityCredentials, IdentityCredential> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  IdentityCredentials(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _identityIdMeta = const VerificationMeta(
    'identityId',
  );
  late final GeneratedColumn<int> identityId = GeneratedColumn<int>(
    'identity_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES identities(id)ON DELETE CASCADE',
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
    $customConstraints: 'NOT NULL REFERENCES credentials(id)ON DELETE CASCADE',
  );
  @override
  List<GeneratedColumn> get $columns => [identityId, credentialId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identity_credentials';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdentityCredential> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('identity_id')) {
      context.handle(
        _identityIdMeta,
        identityId.isAcceptableOrUnknown(data['identity_id']!, _identityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_identityIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {identityId, credentialId};
  @override
  IdentityCredential map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentityCredential(
      identityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}identity_id'],
      )!,
      credentialId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credential_id'],
      )!,
    );
  }

  @override
  IdentityCredentials createAlias(String alias) {
    return IdentityCredentials(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(identity_id, credential_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class IdentityCredential extends DataClass
    implements Insertable<IdentityCredential> {
  final int identityId;
  final int credentialId;
  const IdentityCredential({
    required this.identityId,
    required this.credentialId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['identity_id'] = Variable<int>(identityId);
    map['credential_id'] = Variable<int>(credentialId);
    return map;
  }

  IdentityCredentialsCompanion toCompanion(bool nullToAbsent) {
    return IdentityCredentialsCompanion(
      identityId: Value(identityId),
      credentialId: Value(credentialId),
    );
  }

  factory IdentityCredential.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentityCredential(
      identityId: serializer.fromJson<int>(json['identity_id']),
      credentialId: serializer.fromJson<int>(json['credential_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identity_id': serializer.toJson<int>(identityId),
      'credential_id': serializer.toJson<int>(credentialId),
    };
  }

  IdentityCredential copyWith({int? identityId, int? credentialId}) =>
      IdentityCredential(
        identityId: identityId ?? this.identityId,
        credentialId: credentialId ?? this.credentialId,
      );
  IdentityCredential copyWithCompanion(IdentityCredentialsCompanion data) {
    return IdentityCredential(
      identityId: data.identityId.present
          ? data.identityId.value
          : this.identityId,
      credentialId: data.credentialId.present
          ? data.credentialId.value
          : this.credentialId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdentityCredential(')
          ..write('identityId: $identityId, ')
          ..write('credentialId: $credentialId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(identityId, credentialId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentityCredential &&
          other.identityId == this.identityId &&
          other.credentialId == this.credentialId);
}

class IdentityCredentialsCompanion extends UpdateCompanion<IdentityCredential> {
  final Value<int> identityId;
  final Value<int> credentialId;
  final Value<int> rowid;
  const IdentityCredentialsCompanion({
    this.identityId = const Value.absent(),
    this.credentialId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdentityCredentialsCompanion.insert({
    required int identityId,
    required int credentialId,
    this.rowid = const Value.absent(),
  }) : identityId = Value(identityId),
       credentialId = Value(credentialId);
  static Insertable<IdentityCredential> custom({
    Expression<int>? identityId,
    Expression<int>? credentialId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (identityId != null) 'identity_id': identityId,
      if (credentialId != null) 'credential_id': credentialId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdentityCredentialsCompanion copyWith({
    Value<int>? identityId,
    Value<int>? credentialId,
    Value<int>? rowid,
  }) {
    return IdentityCredentialsCompanion(
      identityId: identityId ?? this.identityId,
      credentialId: credentialId ?? this.credentialId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (identityId.present) {
      map['identity_id'] = Variable<int>(identityId.value);
    }
    if (credentialId.present) {
      map['credential_id'] = Variable<int>(credentialId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentityCredentialsCompanion(')
          ..write('identityId: $identityId, ')
          ..write('credentialId: $credentialId, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
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
    $customConstraints: 'REFERENCES identities(id)ON DELETE SET NULL',
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
  late final GeneratedColumnWithTypeConverter<Color, int> iconColor =
      GeneratedColumn<int>(
        'icon_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(Connections.$convertericonColor);
  late final GeneratedColumnWithTypeConverter<Color, int> iconBackgroundColor =
      GeneratedColumn<int>(
        'icon_background_color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(Connections.$convertericonBackgroundColor);
  static const VerificationMeta _isIconAutoDetectMeta = const VerificationMeta(
    'isIconAutoDetect',
  );
  late final GeneratedColumn<bool> isIconAutoDetect = GeneratedColumn<bool>(
    'is_icon_auto_detect',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT TRUE',
    defaultValue: const CustomExpression('TRUE'),
  );
  late final GeneratedColumnWithTypeConverter<TerminalTypography?, String>
  terminalTypographyOverride =
      GeneratedColumn<String>(
        'terminal_typography_override',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<TerminalTypography?>(
        Connections.$converterterminalTypographyOverriden,
      );
  static const VerificationMeta _terminalThemeOverrideIdMeta =
      const VerificationMeta('terminalThemeOverrideId');
  late final GeneratedColumn<int> terminalThemeOverrideId =
      GeneratedColumn<int>(
        'terminal_theme_override_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints:
            'REFERENCES custom_terminal_themes(id)ON DELETE SET NULL',
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    address,
    port,
    identityId,
    username,
    groupName,
    icon,
    iconColor,
    iconBackgroundColor,
    isIconAutoDetect,
    terminalTypographyOverride,
    terminalThemeOverrideId,
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
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
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
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    }
    if (data.containsKey('is_icon_auto_detect')) {
      context.handle(
        _isIconAutoDetectMeta,
        isIconAutoDetect.isAcceptableOrUnknown(
          data['is_icon_auto_detect']!,
          _isIconAutoDetectMeta,
        ),
      );
    }
    if (data.containsKey('terminal_theme_override_id')) {
      context.handle(
        _terminalThemeOverrideIdMeta,
        terminalThemeOverrideId.isAcceptableOrUnknown(
          data['terminal_theme_override_id']!,
          _terminalThemeOverrideIdMeta,
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
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
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
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      ),
      icon: Connections.$convertericon.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}icon'],
        )!,
      ),
      iconColor: Connections.$convertericonColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}icon_color'],
        )!,
      ),
      iconBackgroundColor: Connections.$convertericonBackgroundColor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}icon_background_color'],
        )!,
      ),
      isIconAutoDetect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_icon_auto_detect'],
      )!,
      terminalTypographyOverride: Connections
          .$converterterminalTypographyOverriden
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}terminal_typography_override'],
            ),
          ),
      terminalThemeOverrideId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}terminal_theme_override_id'],
      ),
    );
  }

  @override
  Connections createAlias(String alias) {
    return Connections(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ConnectionIcon, int, int> $convertericon =
      const EnumIndexConverter<ConnectionIcon>(ConnectionIcon.values);
  static TypeConverter<Color, int> $convertericonColor = const ColorConverter();
  static TypeConverter<Color, int> $convertericonBackgroundColor =
      const ColorConverter();
  static TypeConverter<TerminalTypography, String>
  $converterterminalTypographyOverride = const TerminalTypographyConverter();
  static TypeConverter<TerminalTypography?, String?>
  $converterterminalTypographyOverriden = NullAwareTypeConverter.wrap(
    $converterterminalTypographyOverride,
  );
  @override
  List<String> get customConstraints => const [
    'CONSTRAINT username_or_identity_id CHECK((identity_id IS NOT NULL AND username IS NULL)OR(identity_id IS NULL AND username IS NOT NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Connection extends DataClass implements Insertable<Connection> {
  final int id;
  final String label;
  final String address;
  final int port;
  final int? identityId;
  final String? username;
  final String? groupName;
  final ConnectionIcon icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final bool isIconAutoDetect;
  final TerminalTypography? terminalTypographyOverride;
  final int? terminalThemeOverrideId;
  const Connection({
    required this.id,
    required this.label,
    required this.address,
    required this.port,
    this.identityId,
    this.username,
    this.groupName,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.isIconAutoDetect,
    this.terminalTypographyOverride,
    this.terminalThemeOverrideId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['address'] = Variable<String>(address);
    map['port'] = Variable<int>(port);
    if (!nullToAbsent || identityId != null) {
      map['identity_id'] = Variable<int>(identityId);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    {
      map['icon'] = Variable<int>(Connections.$convertericon.toSql(icon));
    }
    {
      map['icon_color'] = Variable<int>(
        Connections.$convertericonColor.toSql(iconColor),
      );
    }
    {
      map['icon_background_color'] = Variable<int>(
        Connections.$convertericonBackgroundColor.toSql(iconBackgroundColor),
      );
    }
    map['is_icon_auto_detect'] = Variable<bool>(isIconAutoDetect);
    if (!nullToAbsent || terminalTypographyOverride != null) {
      map['terminal_typography_override'] = Variable<String>(
        Connections.$converterterminalTypographyOverriden.toSql(
          terminalTypographyOverride,
        ),
      );
    }
    if (!nullToAbsent || terminalThemeOverrideId != null) {
      map['terminal_theme_override_id'] = Variable<int>(
        terminalThemeOverrideId,
      );
    }
    return map;
  }

  ConnectionsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionsCompanion(
      id: Value(id),
      label: Value(label),
      address: Value(address),
      port: Value(port),
      identityId: identityId == null && nullToAbsent
          ? const Value.absent()
          : Value(identityId),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
      icon: Value(icon),
      iconColor: Value(iconColor),
      iconBackgroundColor: Value(iconBackgroundColor),
      isIconAutoDetect: Value(isIconAutoDetect),
      terminalTypographyOverride:
          terminalTypographyOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(terminalTypographyOverride),
      terminalThemeOverrideId: terminalThemeOverrideId == null && nullToAbsent
          ? const Value.absent()
          : Value(terminalThemeOverrideId),
    );
  }

  factory Connection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Connection(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      address: serializer.fromJson<String>(json['address']),
      port: serializer.fromJson<int>(json['port']),
      identityId: serializer.fromJson<int?>(json['identity_id']),
      username: serializer.fromJson<String?>(json['username']),
      groupName: serializer.fromJson<String?>(json['group_name']),
      icon: Connections.$convertericon.fromJson(
        serializer.fromJson<int>(json['icon']),
      ),
      iconColor: serializer.fromJson<Color>(json['icon_color']),
      iconBackgroundColor: serializer.fromJson<Color>(
        json['icon_background_color'],
      ),
      isIconAutoDetect: serializer.fromJson<bool>(json['is_icon_auto_detect']),
      terminalTypographyOverride: serializer.fromJson<TerminalTypography?>(
        json['terminal_typography_override'],
      ),
      terminalThemeOverrideId: serializer.fromJson<int?>(
        json['terminal_theme_override_id'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'address': serializer.toJson<String>(address),
      'port': serializer.toJson<int>(port),
      'identity_id': serializer.toJson<int?>(identityId),
      'username': serializer.toJson<String?>(username),
      'group_name': serializer.toJson<String?>(groupName),
      'icon': serializer.toJson<int>(Connections.$convertericon.toJson(icon)),
      'icon_color': serializer.toJson<Color>(iconColor),
      'icon_background_color': serializer.toJson<Color>(iconBackgroundColor),
      'is_icon_auto_detect': serializer.toJson<bool>(isIconAutoDetect),
      'terminal_typography_override': serializer.toJson<TerminalTypography?>(
        terminalTypographyOverride,
      ),
      'terminal_theme_override_id': serializer.toJson<int?>(
        terminalThemeOverrideId,
      ),
    };
  }

  Connection copyWith({
    int? id,
    String? label,
    String? address,
    int? port,
    Value<int?> identityId = const Value.absent(),
    Value<String?> username = const Value.absent(),
    Value<String?> groupName = const Value.absent(),
    ConnectionIcon? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    bool? isIconAutoDetect,
    Value<TerminalTypography?> terminalTypographyOverride =
        const Value.absent(),
    Value<int?> terminalThemeOverrideId = const Value.absent(),
  }) => Connection(
    id: id ?? this.id,
    label: label ?? this.label,
    address: address ?? this.address,
    port: port ?? this.port,
    identityId: identityId.present ? identityId.value : this.identityId,
    username: username.present ? username.value : this.username,
    groupName: groupName.present ? groupName.value : this.groupName,
    icon: icon ?? this.icon,
    iconColor: iconColor ?? this.iconColor,
    iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
    isIconAutoDetect: isIconAutoDetect ?? this.isIconAutoDetect,
    terminalTypographyOverride: terminalTypographyOverride.present
        ? terminalTypographyOverride.value
        : this.terminalTypographyOverride,
    terminalThemeOverrideId: terminalThemeOverrideId.present
        ? terminalThemeOverrideId.value
        : this.terminalThemeOverrideId,
  );
  Connection copyWithCompanion(ConnectionsCompanion data) {
    return Connection(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      address: data.address.present ? data.address.value : this.address,
      port: data.port.present ? data.port.value : this.port,
      identityId: data.identityId.present
          ? data.identityId.value
          : this.identityId,
      username: data.username.present ? data.username.value : this.username,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      icon: data.icon.present ? data.icon.value : this.icon,
      iconColor: data.iconColor.present ? data.iconColor.value : this.iconColor,
      iconBackgroundColor: data.iconBackgroundColor.present
          ? data.iconBackgroundColor.value
          : this.iconBackgroundColor,
      isIconAutoDetect: data.isIconAutoDetect.present
          ? data.isIconAutoDetect.value
          : this.isIconAutoDetect,
      terminalTypographyOverride: data.terminalTypographyOverride.present
          ? data.terminalTypographyOverride.value
          : this.terminalTypographyOverride,
      terminalThemeOverrideId: data.terminalThemeOverrideId.present
          ? data.terminalThemeOverrideId.value
          : this.terminalThemeOverrideId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Connection(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('address: $address, ')
          ..write('port: $port, ')
          ..write('identityId: $identityId, ')
          ..write('username: $username, ')
          ..write('groupName: $groupName, ')
          ..write('icon: $icon, ')
          ..write('iconColor: $iconColor, ')
          ..write('iconBackgroundColor: $iconBackgroundColor, ')
          ..write('isIconAutoDetect: $isIconAutoDetect, ')
          ..write('terminalTypographyOverride: $terminalTypographyOverride, ')
          ..write('terminalThemeOverrideId: $terminalThemeOverrideId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    address,
    port,
    identityId,
    username,
    groupName,
    icon,
    iconColor,
    iconBackgroundColor,
    isIconAutoDetect,
    terminalTypographyOverride,
    terminalThemeOverrideId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Connection &&
          other.id == this.id &&
          other.label == this.label &&
          other.address == this.address &&
          other.port == this.port &&
          other.identityId == this.identityId &&
          other.username == this.username &&
          other.groupName == this.groupName &&
          other.icon == this.icon &&
          other.iconColor == this.iconColor &&
          other.iconBackgroundColor == this.iconBackgroundColor &&
          other.isIconAutoDetect == this.isIconAutoDetect &&
          other.terminalTypographyOverride == this.terminalTypographyOverride &&
          other.terminalThemeOverrideId == this.terminalThemeOverrideId);
}

class ConnectionsCompanion extends UpdateCompanion<Connection> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> address;
  final Value<int> port;
  final Value<int?> identityId;
  final Value<String?> username;
  final Value<String?> groupName;
  final Value<ConnectionIcon> icon;
  final Value<Color> iconColor;
  final Value<Color> iconBackgroundColor;
  final Value<bool> isIconAutoDetect;
  final Value<TerminalTypography?> terminalTypographyOverride;
  final Value<int?> terminalThemeOverrideId;
  const ConnectionsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.address = const Value.absent(),
    this.port = const Value.absent(),
    this.identityId = const Value.absent(),
    this.username = const Value.absent(),
    this.groupName = const Value.absent(),
    this.icon = const Value.absent(),
    this.iconColor = const Value.absent(),
    this.iconBackgroundColor = const Value.absent(),
    this.isIconAutoDetect = const Value.absent(),
    this.terminalTypographyOverride = const Value.absent(),
    this.terminalThemeOverrideId = const Value.absent(),
  });
  ConnectionsCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String address,
    required int port,
    this.identityId = const Value.absent(),
    this.username = const Value.absent(),
    this.groupName = const Value.absent(),
    this.icon = const Value.absent(),
    required Color iconColor,
    required Color iconBackgroundColor,
    this.isIconAutoDetect = const Value.absent(),
    this.terminalTypographyOverride = const Value.absent(),
    this.terminalThemeOverrideId = const Value.absent(),
  }) : label = Value(label),
       address = Value(address),
       port = Value(port),
       iconColor = Value(iconColor),
       iconBackgroundColor = Value(iconBackgroundColor);
  static Insertable<Connection> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? address,
    Expression<int>? port,
    Expression<int>? identityId,
    Expression<String>? username,
    Expression<String>? groupName,
    Expression<int>? icon,
    Expression<int>? iconColor,
    Expression<int>? iconBackgroundColor,
    Expression<bool>? isIconAutoDetect,
    Expression<String>? terminalTypographyOverride,
    Expression<int>? terminalThemeOverrideId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (address != null) 'address': address,
      if (port != null) 'port': port,
      if (identityId != null) 'identity_id': identityId,
      if (username != null) 'username': username,
      if (groupName != null) 'group_name': groupName,
      if (icon != null) 'icon': icon,
      if (iconColor != null) 'icon_color': iconColor,
      if (iconBackgroundColor != null)
        'icon_background_color': iconBackgroundColor,
      if (isIconAutoDetect != null) 'is_icon_auto_detect': isIconAutoDetect,
      if (terminalTypographyOverride != null)
        'terminal_typography_override': terminalTypographyOverride,
      if (terminalThemeOverrideId != null)
        'terminal_theme_override_id': terminalThemeOverrideId,
    });
  }

  ConnectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? address,
    Value<int>? port,
    Value<int?>? identityId,
    Value<String?>? username,
    Value<String?>? groupName,
    Value<ConnectionIcon>? icon,
    Value<Color>? iconColor,
    Value<Color>? iconBackgroundColor,
    Value<bool>? isIconAutoDetect,
    Value<TerminalTypography?>? terminalTypographyOverride,
    Value<int?>? terminalThemeOverrideId,
  }) {
    return ConnectionsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      port: port ?? this.port,
      identityId: identityId ?? this.identityId,
      username: username ?? this.username,
      groupName: groupName ?? this.groupName,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      isIconAutoDetect: isIconAutoDetect ?? this.isIconAutoDetect,
      terminalTypographyOverride:
          terminalTypographyOverride ?? this.terminalTypographyOverride,
      terminalThemeOverrideId:
          terminalThemeOverrideId ?? this.terminalThemeOverrideId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
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
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (icon.present) {
      map['icon'] = Variable<int>(Connections.$convertericon.toSql(icon.value));
    }
    if (iconColor.present) {
      map['icon_color'] = Variable<int>(
        Connections.$convertericonColor.toSql(iconColor.value),
      );
    }
    if (iconBackgroundColor.present) {
      map['icon_background_color'] = Variable<int>(
        Connections.$convertericonBackgroundColor.toSql(
          iconBackgroundColor.value,
        ),
      );
    }
    if (isIconAutoDetect.present) {
      map['is_icon_auto_detect'] = Variable<bool>(isIconAutoDetect.value);
    }
    if (terminalTypographyOverride.present) {
      map['terminal_typography_override'] = Variable<String>(
        Connections.$converterterminalTypographyOverriden.toSql(
          terminalTypographyOverride.value,
        ),
      );
    }
    if (terminalThemeOverrideId.present) {
      map['terminal_theme_override_id'] = Variable<int>(
        terminalThemeOverrideId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('address: $address, ')
          ..write('port: $port, ')
          ..write('identityId: $identityId, ')
          ..write('username: $username, ')
          ..write('groupName: $groupName, ')
          ..write('icon: $icon, ')
          ..write('iconColor: $iconColor, ')
          ..write('iconBackgroundColor: $iconBackgroundColor, ')
          ..write('isIconAutoDetect: $isIconAutoDetect, ')
          ..write('terminalTypographyOverride: $terminalTypographyOverride, ')
          ..write('terminalThemeOverrideId: $terminalThemeOverrideId')
          ..write(')'))
        .toString();
  }
}

class ConnectionCredentials extends Table
    with TableInfo<ConnectionCredentials, ConnectionCredential> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ConnectionCredentials(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  late final GeneratedColumn<int> connectionId = GeneratedColumn<int>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES connections(id)ON DELETE CASCADE',
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
    $customConstraints: 'NOT NULL REFERENCES credentials(id)ON DELETE CASCADE',
  );
  @override
  List<GeneratedColumn> get $columns => [connectionId, credentialId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connection_credentials';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConnectionCredential> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {connectionId, credentialId};
  @override
  ConnectionCredential map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConnectionCredential(
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}connection_id'],
      )!,
      credentialId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credential_id'],
      )!,
    );
  }

  @override
  ConnectionCredentials createAlias(String alias) {
    return ConnectionCredentials(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(connection_id, credential_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ConnectionCredential extends DataClass
    implements Insertable<ConnectionCredential> {
  final int connectionId;
  final int credentialId;
  const ConnectionCredential({
    required this.connectionId,
    required this.credentialId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['connection_id'] = Variable<int>(connectionId);
    map['credential_id'] = Variable<int>(credentialId);
    return map;
  }

  ConnectionCredentialsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionCredentialsCompanion(
      connectionId: Value(connectionId),
      credentialId: Value(credentialId),
    );
  }

  factory ConnectionCredential.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConnectionCredential(
      connectionId: serializer.fromJson<int>(json['connection_id']),
      credentialId: serializer.fromJson<int>(json['credential_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'connection_id': serializer.toJson<int>(connectionId),
      'credential_id': serializer.toJson<int>(credentialId),
    };
  }

  ConnectionCredential copyWith({int? connectionId, int? credentialId}) =>
      ConnectionCredential(
        connectionId: connectionId ?? this.connectionId,
        credentialId: credentialId ?? this.credentialId,
      );
  ConnectionCredential copyWithCompanion(ConnectionCredentialsCompanion data) {
    return ConnectionCredential(
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      credentialId: data.credentialId.present
          ? data.credentialId.value
          : this.credentialId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionCredential(')
          ..write('connectionId: $connectionId, ')
          ..write('credentialId: $credentialId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(connectionId, credentialId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectionCredential &&
          other.connectionId == this.connectionId &&
          other.credentialId == this.credentialId);
}

class ConnectionCredentialsCompanion
    extends UpdateCompanion<ConnectionCredential> {
  final Value<int> connectionId;
  final Value<int> credentialId;
  final Value<int> rowid;
  const ConnectionCredentialsCompanion({
    this.connectionId = const Value.absent(),
    this.credentialId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConnectionCredentialsCompanion.insert({
    required int connectionId,
    required int credentialId,
    this.rowid = const Value.absent(),
  }) : connectionId = Value(connectionId),
       credentialId = Value(credentialId);
  static Insertable<ConnectionCredential> custom({
    Expression<int>? connectionId,
    Expression<int>? credentialId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (connectionId != null) 'connection_id': connectionId,
      if (credentialId != null) 'credential_id': credentialId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConnectionCredentialsCompanion copyWith({
    Value<int>? connectionId,
    Value<int>? credentialId,
    Value<int>? rowid,
  }) {
    return ConnectionCredentialsCompanion(
      connectionId: connectionId ?? this.connectionId,
      credentialId: credentialId ?? this.credentialId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (connectionId.present) {
      map['connection_id'] = Variable<int>(connectionId.value);
    }
    if (credentialId.present) {
      map['credential_id'] = Variable<int>(credentialId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionCredentialsCompanion(')
          ..write('connectionId: $connectionId, ')
          ..write('credentialId: $credentialId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CliqDatabase extends GeneratedDatabase {
  _$CliqDatabase(QueryExecutor e) : super(e);
  $CliqDatabaseManager get managers => $CliqDatabaseManager(this);
  late final KnownHosts knownHosts = KnownHosts(this);
  late final CustomTerminalThemes customTerminalThemes = CustomTerminalThemes(
    this,
  );
  late final Keys keys = Keys(this);
  late final Identities identities = Identities(this);
  late final Credentials credentials = Credentials(this);
  late final IdentityCredentials identityCredentials = IdentityCredentials(
    this,
  );
  late final Connections connections = Connections(this);
  late final ConnectionCredentials connectionCredentials =
      ConnectionCredentials(this);
  Selectable<KnownHost> findKnownHostByHost(String var1) {
    return customSelect(
      'SELECT * FROM known_hosts WHERE host = ?1',
      variables: [Variable<String>(var1)],
      readsFrom: {knownHosts},
    ).asyncMap(knownHosts.mapFromRow);
  }

  Selectable<int> findAllKeyIds() {
    return customSelect(
      'SELECT id FROM keys',
      variables: [],
      readsFrom: {keys},
    ).map((QueryRow row) => row.read<int>('id'));
  }

  Selectable<Key> findKeyByIds(List<int> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT * FROM keys WHERE id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<int>($)],
      readsFrom: {keys},
    ).asyncMap(keys.mapFromRow);
  }

  Selectable<FindAllIdentityFullResult> findAllIdentityFull() {
    return customSelect(
      'SELECT"i"."id" AS "nested_0.id", "i"."label" AS "nested_0.label", "i"."username" AS "nested_0.username", i.id AS "\$n_0" FROM identities AS i',
      variables: [],
      readsFrom: {credentials, identityCredentials, identities},
    ).asyncMap(
      (QueryRow row) async => FindAllIdentityFullResult(
        identity: await identities.mapFromRow(row, tablePrefix: 'nested_0'),
        identityCredentials: await customSelect(
          'SELECT credentials.id FROM identity_credentials JOIN credentials ON credentials.id = identity_credentials.credential_id WHERE identity_credentials.identity_id = ?1 ORDER BY credentials.id',
          variables: [Variable<int>(row.read('\$n_0'))],
          readsFrom: {credentials, identityCredentials, identities},
        ).map((QueryRow row) => row.read<int>('id')).get(),
      ),
    );
  }

  Selectable<FindCredentialFullByIdsResult> findCredentialFullByIds(
    List<int> var1,
  ) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT"c"."id" AS "nested_0.id", "c"."type" AS "nested_0.type", "c"."key_id" AS "nested_0.key_id", "c"."password" AS "nested_0.password","k"."id" AS "nested_1.id", "k"."label" AS "nested_1.label", "k"."private_pem" AS "nested_1.private_pem", "k"."passphrase" AS "nested_1.passphrase" FROM credentials AS c LEFT JOIN keys AS k ON c.key_id = k.id WHERE c.id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<int>($)],
      readsFrom: {credentials, keys},
    ).asyncMap(
      (QueryRow row) async => FindCredentialFullByIdsResult(
        credential: await credentials.mapFromRow(row, tablePrefix: 'nested_0'),
        credentialKey: await keys.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_1',
        ),
      ),
    );
  }

  Selectable<FindAllConnectionFullResult> findAllConnectionFull() {
    return customSelect(
      'SELECT"c"."id" AS "nested_0.id", "c"."label" AS "nested_0.label", "c"."address" AS "nested_0.address", "c"."port" AS "nested_0.port", "c"."identity_id" AS "nested_0.identity_id", "c"."username" AS "nested_0.username", "c"."group_name" AS "nested_0.group_name", "c"."icon" AS "nested_0.icon", "c"."icon_color" AS "nested_0.icon_color", "c"."icon_background_color" AS "nested_0.icon_background_color", "c"."is_icon_auto_detect" AS "nested_0.is_icon_auto_detect", "c"."terminal_typography_override" AS "nested_0.terminal_typography_override", "c"."terminal_theme_override_id" AS "nested_0.terminal_theme_override_id","i"."id" AS "nested_1.id", "i"."label" AS "nested_1.label", "i"."username" AS "nested_1.username","t"."id" AS "nested_2.id", "t"."name" AS "nested_2.name", "t"."author" AS "nested_2.author", "t"."black_color" AS "nested_2.black_color", "t"."red_color" AS "nested_2.red_color", "t"."green_color" AS "nested_2.green_color", "t"."yellow_color" AS "nested_2.yellow_color", "t"."blue_color" AS "nested_2.blue_color", "t"."purple_color" AS "nested_2.purple_color", "t"."cyan_color" AS "nested_2.cyan_color", "t"."white_color" AS "nested_2.white_color", "t"."bright_black_color" AS "nested_2.bright_black_color", "t"."bright_red_color" AS "nested_2.bright_red_color", "t"."bright_green_color" AS "nested_2.bright_green_color", "t"."bright_yellow_color" AS "nested_2.bright_yellow_color", "t"."bright_blue_color" AS "nested_2.bright_blue_color", "t"."bright_purple_color" AS "nested_2.bright_purple_color", "t"."bright_cyan_color" AS "nested_2.bright_cyan_color", "t"."bright_white_color" AS "nested_2.bright_white_color", "t"."background_color" AS "nested_2.background_color", "t"."foreground_color" AS "nested_2.foreground_color", "t"."cursor_color" AS "nested_2.cursor_color", "t"."selection_background_color" AS "nested_2.selection_background_color", "t"."selection_foreground_color" AS "nested_2.selection_foreground_color", "t"."cursor_text_color" AS "nested_2.cursor_text_color", c.id AS "\$n_0", i.id AS "\$n_1" FROM connections AS c LEFT JOIN identities AS i ON c.identity_id = i.id LEFT JOIN custom_terminal_themes AS t ON c.terminal_theme_override_id = t.id',
      variables: [],
      readsFrom: {
        credentials,
        connectionCredentials,
        connections,
        identityCredentials,
        identities,
        customTerminalThemes,
      },
    ).asyncMap(
      (QueryRow row) async => FindAllConnectionFullResult(
        connection: await connections.mapFromRow(row, tablePrefix: 'nested_0'),
        identity: await identities.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_1',
        ),
        terminalThemeOverride: await customTerminalThemes.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_2',
        ),
        connectionCredentials: await customSelect(
          'SELECT credentials.id FROM connection_credentials JOIN credentials ON credentials.id = connection_credentials.credential_id WHERE connection_credentials.connection_id = ?1 ORDER BY credentials.id',
          variables: [Variable<int>(row.read('\$n_0'))],
          readsFrom: {credentials, connectionCredentials, connections},
        ).map((QueryRow row) => row.read<int>('id')).get(),
        identityCredentials: await customSelect(
          'SELECT credentials.id FROM identity_credentials JOIN credentials ON credentials.id = identity_credentials.credential_id WHERE identity_credentials.identity_id = ?1 ORDER BY credentials.id',
          variables: [Variable<int>(row.read('\$n_1'))],
          readsFrom: {credentials, identityCredentials, identities},
        ).map((QueryRow row) => row.read<int>('id')).get(),
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
    knownHosts,
    customTerminalThemes,
    keys,
    identities,
    credentials,
    identityCredentials,
    connections,
    connectionCredentials,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'keys',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credentials', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'identities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('identity_credentials', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'credentials',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('identity_credentials', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'identities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('connections', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'custom_terminal_themes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('connections', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'connections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('connection_credentials', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'credentials',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('connection_credentials', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $KnownHostsCreateCompanionBuilder =
    KnownHostsCompanion Function({
      Value<int> id,
      required String host,
      required Uint8List hostKey,
      Value<DateTime> createdAt,
    });
typedef $KnownHostsUpdateCompanionBuilder =
    KnownHostsCompanion Function({
      Value<int> id,
      Value<String> host,
      Value<Uint8List> hostKey,
      Value<DateTime> createdAt,
    });

class $KnownHostsFilterComposer extends Composer<_$CliqDatabase, KnownHosts> {
  $KnownHostsFilterComposer({
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

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get hostKey => $composableBuilder(
    column: $table.hostKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $KnownHostsOrderingComposer extends Composer<_$CliqDatabase, KnownHosts> {
  $KnownHostsOrderingComposer({
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

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get hostKey => $composableBuilder(
    column: $table.hostKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $KnownHostsAnnotationComposer
    extends Composer<_$CliqDatabase, KnownHosts> {
  $KnownHostsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<Uint8List> get hostKey =>
      $composableBuilder(column: $table.hostKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $KnownHostsTableManager
    extends
        RootTableManager<
          _$CliqDatabase,
          KnownHosts,
          KnownHost,
          $KnownHostsFilterComposer,
          $KnownHostsOrderingComposer,
          $KnownHostsAnnotationComposer,
          $KnownHostsCreateCompanionBuilder,
          $KnownHostsUpdateCompanionBuilder,
          (KnownHost, BaseReferences<_$CliqDatabase, KnownHosts, KnownHost>),
          KnownHost,
          PrefetchHooks Function()
        > {
  $KnownHostsTableManager(_$CliqDatabase db, KnownHosts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $KnownHostsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $KnownHostsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $KnownHostsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<Uint8List> hostKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => KnownHostsCompanion(
                id: id,
                host: host,
                hostKey: hostKey,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String host,
                required Uint8List hostKey,
                Value<DateTime> createdAt = const Value.absent(),
              }) => KnownHostsCompanion.insert(
                id: id,
                host: host,
                hostKey: hostKey,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $KnownHostsProcessedTableManager =
    ProcessedTableManager<
      _$CliqDatabase,
      KnownHosts,
      KnownHost,
      $KnownHostsFilterComposer,
      $KnownHostsOrderingComposer,
      $KnownHostsAnnotationComposer,
      $KnownHostsCreateCompanionBuilder,
      $KnownHostsUpdateCompanionBuilder,
      (KnownHost, BaseReferences<_$CliqDatabase, KnownHosts, KnownHost>),
      KnownHost,
      PrefetchHooks Function()
    >;
typedef $CustomTerminalThemesCreateCompanionBuilder =
    CustomTerminalThemesCompanion Function({
      Value<int> id,
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
    });
typedef $CustomTerminalThemesUpdateCompanionBuilder =
    CustomTerminalThemesCompanion Function({
      Value<int> id,
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
      db.customTerminalThemes.id,
      db.connections.terminalThemeOverrideId,
    ),
  );

  $ConnectionsProcessedTableManager get connectionsRefs {
    final manager = $ConnectionsTableManager($_db, $_db.connections).filter(
      (f) => f.terminalThemeOverrideId.id.sqlEquals($_itemColumn<int>('id')!),
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

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
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.terminalThemeOverrideId,
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

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
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.terminalThemeOverrideId,
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
                Value<int> id = const Value.absent(),
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
              }) => CustomTerminalThemesCompanion(
                id: id,
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
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
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
              }) => CustomTerminalThemesCompanion.insert(
                id: id,
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
                            (e) => e.terminalThemeOverrideId == item.id,
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
typedef $KeysCreateCompanionBuilder =
    KeysCompanion Function({
      Value<int> id,
      required String label,
      required String privatePem,
      Value<String?> passphrase,
    });
typedef $KeysUpdateCompanionBuilder =
    KeysCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String> privatePem,
      Value<String?> passphrase,
    });

final class $KeysReferences extends BaseReferences<_$CliqDatabase, Keys, Key> {
  $KeysReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Credentials, List<Credential>>
  _credentialsRefsTable(_$CliqDatabase db) => MultiTypedResultKey.fromTable(
    db.credentials,
    aliasName: $_aliasNameGenerator(db.keys.id, db.credentials.keyId),
  );

  $CredentialsProcessedTableManager get credentialsRefs {
    final manager = $CredentialsTableManager(
      $_db,
      $_db.credentials,
    ).filter((f) => f.keyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_credentialsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $KeysFilterComposer extends Composer<_$CliqDatabase, Keys> {
  $KeysFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privatePem => $composableBuilder(
    column: $table.privatePem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> credentialsRefs(
    Expression<bool> Function($CredentialsFilterComposer f) f,
  ) {
    final $CredentialsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credentials,
      getReferencedColumn: (t) => t.keyId,
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
    return f(composer);
  }
}

class $KeysOrderingComposer extends Composer<_$CliqDatabase, Keys> {
  $KeysOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privatePem => $composableBuilder(
    column: $table.privatePem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => ColumnOrderings(column),
  );
}

class $KeysAnnotationComposer extends Composer<_$CliqDatabase, Keys> {
  $KeysAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get privatePem => $composableBuilder(
    column: $table.privatePem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => column,
  );

  Expression<T> credentialsRefs<T extends Object>(
    Expression<T> Function($CredentialsAnnotationComposer a) f,
  ) {
    final $CredentialsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credentials,
      getReferencedColumn: (t) => t.keyId,
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
    return f(composer);
  }
}

class $KeysTableManager
    extends
        RootTableManager<
          _$CliqDatabase,
          Keys,
          Key,
          $KeysFilterComposer,
          $KeysOrderingComposer,
          $KeysAnnotationComposer,
          $KeysCreateCompanionBuilder,
          $KeysUpdateCompanionBuilder,
          (Key, $KeysReferences),
          Key,
          PrefetchHooks Function({bool credentialsRefs})
        > {
  $KeysTableManager(_$CliqDatabase db, Keys table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $KeysFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $KeysOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $KeysAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> privatePem = const Value.absent(),
                Value<String?> passphrase = const Value.absent(),
              }) => KeysCompanion(
                id: id,
                label: label,
                privatePem: privatePem,
                passphrase: passphrase,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String privatePem,
                Value<String?> passphrase = const Value.absent(),
              }) => KeysCompanion.insert(
                id: id,
                label: label,
                privatePem: privatePem,
                passphrase: passphrase,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $KeysReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({credentialsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (credentialsRefs) db.credentials],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (credentialsRefs)
                    await $_getPrefetchedData<Key, Keys, Credential>(
                      currentTable: table,
                      referencedTable: $KeysReferences._credentialsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $KeysReferences(db, table, p0).credentialsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.keyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $KeysProcessedTableManager =
    ProcessedTableManager<
      _$CliqDatabase,
      Keys,
      Key,
      $KeysFilterComposer,
      $KeysOrderingComposer,
      $KeysAnnotationComposer,
      $KeysCreateCompanionBuilder,
      $KeysUpdateCompanionBuilder,
      (Key, $KeysReferences),
      Key,
      PrefetchHooks Function({bool credentialsRefs})
    >;
typedef $IdentitiesCreateCompanionBuilder =
    IdentitiesCompanion Function({
      Value<int> id,
      required String label,
      required String username,
    });
typedef $IdentitiesUpdateCompanionBuilder =
    IdentitiesCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String> username,
    });

final class $IdentitiesReferences
    extends BaseReferences<_$CliqDatabase, Identities, Identity> {
  $IdentitiesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<IdentityCredentials, List<IdentityCredential>>
  _identityCredentialsRefsTable(_$CliqDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.identityCredentials,
        aliasName: $_aliasNameGenerator(
          db.identities.id,
          db.identityCredentials.identityId,
        ),
      );

  $IdentityCredentialsProcessedTableManager get identityCredentialsRefs {
    final manager = $IdentityCredentialsTableManager(
      $_db,
      $_db.identityCredentials,
    ).filter((f) => f.identityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _identityCredentialsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> identityCredentialsRefs(
    Expression<bool> Function($IdentityCredentialsFilterComposer f) f,
  ) {
    final $IdentityCredentialsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.identityCredentials,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IdentityCredentialsFilterComposer(
            $db: $db,
            $table: $db.identityCredentials,
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  Expression<T> identityCredentialsRefs<T extends Object>(
    Expression<T> Function($IdentityCredentialsAnnotationComposer a) f,
  ) {
    final $IdentityCredentialsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.identityCredentials,
      getReferencedColumn: (t) => t.identityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IdentityCredentialsAnnotationComposer(
            $db: $db,
            $table: $db.identityCredentials,
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
          PrefetchHooks Function({
            bool identityCredentialsRefs,
            bool connectionsRefs,
          })
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
                Value<String> label = const Value.absent(),
                Value<String> username = const Value.absent(),
              }) =>
                  IdentitiesCompanion(id: id, label: label, username: username),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String username,
              }) => IdentitiesCompanion.insert(
                id: id,
                label: label,
                username: username,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $IdentitiesReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({identityCredentialsRefs = false, connectionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (identityCredentialsRefs) db.identityCredentials,
                    if (connectionsRefs) db.connections,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (identityCredentialsRefs)
                        await $_getPrefetchedData<
                          Identity,
                          Identities,
                          IdentityCredential
                        >(
                          currentTable: table,
                          referencedTable: $IdentitiesReferences
                              ._identityCredentialsRefsTable(db),
                          managerFromTypedResult: (p0) => $IdentitiesReferences(
                            db,
                            table,
                            p0,
                          ).identityCredentialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.identityId == item.id,
                              ),
                          typedResults: items,
                        ),
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
      PrefetchHooks Function({
        bool identityCredentialsRefs,
        bool connectionsRefs,
      })
    >;
typedef $CredentialsCreateCompanionBuilder =
    CredentialsCompanion Function({
      Value<int> id,
      required CredentialType type,
      Value<int?> keyId,
      Value<String?> password,
    });
typedef $CredentialsUpdateCompanionBuilder =
    CredentialsCompanion Function({
      Value<int> id,
      Value<CredentialType> type,
      Value<int?> keyId,
      Value<String?> password,
    });

final class $CredentialsReferences
    extends BaseReferences<_$CliqDatabase, Credentials, Credential> {
  $CredentialsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Keys _keyIdTable(_$CliqDatabase db) => db.keys.createAlias(
    $_aliasNameGenerator(db.credentials.keyId, db.keys.id),
  );

  $KeysProcessedTableManager? get keyId {
    final $_column = $_itemColumn<int>('key_id');
    if ($_column == null) return null;
    final manager = $KeysTableManager(
      $_db,
      $_db.keys,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_keyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<IdentityCredentials, List<IdentityCredential>>
  _identityCredentialsRefsTable(_$CliqDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.identityCredentials,
        aliasName: $_aliasNameGenerator(
          db.credentials.id,
          db.identityCredentials.credentialId,
        ),
      );

  $IdentityCredentialsProcessedTableManager get identityCredentialsRefs {
    final manager = $IdentityCredentialsTableManager(
      $_db,
      $_db.identityCredentials,
    ).filter((f) => f.credentialId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _identityCredentialsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ConnectionCredentials, List<ConnectionCredential>>
  _connectionCredentialsRefsTable(_$CliqDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.connectionCredentials,
        aliasName: $_aliasNameGenerator(
          db.credentials.id,
          db.connectionCredentials.credentialId,
        ),
      );

  $ConnectionCredentialsProcessedTableManager get connectionCredentialsRefs {
    final manager = $ConnectionCredentialsTableManager(
      $_db,
      $_db.connectionCredentials,
    ).filter((f) => f.credentialId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _connectionCredentialsRefsTable($_db),
    );
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

  ColumnWithTypeConverterFilters<CredentialType, CredentialType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  $KeysFilterComposer get keyId {
    final $KeysFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.keyId,
      referencedTable: $db.keys,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $KeysFilterComposer(
            $db: $db,
            $table: $db.keys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> identityCredentialsRefs(
    Expression<bool> Function($IdentityCredentialsFilterComposer f) f,
  ) {
    final $IdentityCredentialsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.identityCredentials,
      getReferencedColumn: (t) => t.credentialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IdentityCredentialsFilterComposer(
            $db: $db,
            $table: $db.identityCredentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> connectionCredentialsRefs(
    Expression<bool> Function($ConnectionCredentialsFilterComposer f) f,
  ) {
    final $ConnectionCredentialsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connectionCredentials,
      getReferencedColumn: (t) => t.credentialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionCredentialsFilterComposer(
            $db: $db,
            $table: $db.connectionCredentials,
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  $KeysOrderingComposer get keyId {
    final $KeysOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.keyId,
      referencedTable: $db.keys,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $KeysOrderingComposer(
            $db: $db,
            $table: $db.keys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumnWithTypeConverter<CredentialType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  $KeysAnnotationComposer get keyId {
    final $KeysAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.keyId,
      referencedTable: $db.keys,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $KeysAnnotationComposer(
            $db: $db,
            $table: $db.keys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> identityCredentialsRefs<T extends Object>(
    Expression<T> Function($IdentityCredentialsAnnotationComposer a) f,
  ) {
    final $IdentityCredentialsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.identityCredentials,
      getReferencedColumn: (t) => t.credentialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IdentityCredentialsAnnotationComposer(
            $db: $db,
            $table: $db.identityCredentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> connectionCredentialsRefs<T extends Object>(
    Expression<T> Function($ConnectionCredentialsAnnotationComposer a) f,
  ) {
    final $ConnectionCredentialsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connectionCredentials,
      getReferencedColumn: (t) => t.credentialId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionCredentialsAnnotationComposer(
            $db: $db,
            $table: $db.connectionCredentials,
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
          PrefetchHooks Function({
            bool keyId,
            bool identityCredentialsRefs,
            bool connectionCredentialsRefs,
          })
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
                Value<int?> keyId = const Value.absent(),
                Value<String?> password = const Value.absent(),
              }) => CredentialsCompanion(
                id: id,
                type: type,
                keyId: keyId,
                password: password,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required CredentialType type,
                Value<int?> keyId = const Value.absent(),
                Value<String?> password = const Value.absent(),
              }) => CredentialsCompanion.insert(
                id: id,
                type: type,
                keyId: keyId,
                password: password,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $CredentialsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                keyId = false,
                identityCredentialsRefs = false,
                connectionCredentialsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (identityCredentialsRefs) db.identityCredentials,
                    if (connectionCredentialsRefs) db.connectionCredentials,
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
                        if (keyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.keyId,
                                    referencedTable: $CredentialsReferences
                                        ._keyIdTable(db),
                                    referencedColumn: $CredentialsReferences
                                        ._keyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (identityCredentialsRefs)
                        await $_getPrefetchedData<
                          Credential,
                          Credentials,
                          IdentityCredential
                        >(
                          currentTable: table,
                          referencedTable: $CredentialsReferences
                              ._identityCredentialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $CredentialsReferences(
                                db,
                                table,
                                p0,
                              ).identityCredentialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.credentialId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (connectionCredentialsRefs)
                        await $_getPrefetchedData<
                          Credential,
                          Credentials,
                          ConnectionCredential
                        >(
                          currentTable: table,
                          referencedTable: $CredentialsReferences
                              ._connectionCredentialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $CredentialsReferences(
                                db,
                                table,
                                p0,
                              ).connectionCredentialsRefs,
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
      PrefetchHooks Function({
        bool keyId,
        bool identityCredentialsRefs,
        bool connectionCredentialsRefs,
      })
    >;
typedef $IdentityCredentialsCreateCompanionBuilder =
    IdentityCredentialsCompanion Function({
      required int identityId,
      required int credentialId,
      Value<int> rowid,
    });
typedef $IdentityCredentialsUpdateCompanionBuilder =
    IdentityCredentialsCompanion Function({
      Value<int> identityId,
      Value<int> credentialId,
      Value<int> rowid,
    });

final class $IdentityCredentialsReferences
    extends
        BaseReferences<
          _$CliqDatabase,
          IdentityCredentials,
          IdentityCredential
        > {
  $IdentityCredentialsReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Identities _identityIdTable(_$CliqDatabase db) =>
      db.identities.createAlias(
        $_aliasNameGenerator(
          db.identityCredentials.identityId,
          db.identities.id,
        ),
      );

  $IdentitiesProcessedTableManager get identityId {
    final $_column = $_itemColumn<int>('identity_id')!;

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
        $_aliasNameGenerator(
          db.identityCredentials.credentialId,
          db.credentials.id,
        ),
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
}

class $IdentityCredentialsFilterComposer
    extends Composer<_$CliqDatabase, IdentityCredentials> {
  $IdentityCredentialsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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
}

class $IdentityCredentialsOrderingComposer
    extends Composer<_$CliqDatabase, IdentityCredentials> {
  $IdentityCredentialsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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
}

class $IdentityCredentialsAnnotationComposer
    extends Composer<_$CliqDatabase, IdentityCredentials> {
  $IdentityCredentialsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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
}

class $IdentityCredentialsTableManager
    extends
        RootTableManager<
          _$CliqDatabase,
          IdentityCredentials,
          IdentityCredential,
          $IdentityCredentialsFilterComposer,
          $IdentityCredentialsOrderingComposer,
          $IdentityCredentialsAnnotationComposer,
          $IdentityCredentialsCreateCompanionBuilder,
          $IdentityCredentialsUpdateCompanionBuilder,
          (IdentityCredential, $IdentityCredentialsReferences),
          IdentityCredential,
          PrefetchHooks Function({bool identityId, bool credentialId})
        > {
  $IdentityCredentialsTableManager(_$CliqDatabase db, IdentityCredentials table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $IdentityCredentialsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $IdentityCredentialsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $IdentityCredentialsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> identityId = const Value.absent(),
                Value<int> credentialId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdentityCredentialsCompanion(
                identityId: identityId,
                credentialId: credentialId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int identityId,
                required int credentialId,
                Value<int> rowid = const Value.absent(),
              }) => IdentityCredentialsCompanion.insert(
                identityId: identityId,
                credentialId: credentialId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $IdentityCredentialsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({identityId = false, credentialId = false}) {
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
                                referencedTable: $IdentityCredentialsReferences
                                    ._identityIdTable(db),
                                referencedColumn: $IdentityCredentialsReferences
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
                                referencedTable: $IdentityCredentialsReferences
                                    ._credentialIdTable(db),
                                referencedColumn: $IdentityCredentialsReferences
                                    ._credentialIdTable(db)
                                    .id,
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

typedef $IdentityCredentialsProcessedTableManager =
    ProcessedTableManager<
      _$CliqDatabase,
      IdentityCredentials,
      IdentityCredential,
      $IdentityCredentialsFilterComposer,
      $IdentityCredentialsOrderingComposer,
      $IdentityCredentialsAnnotationComposer,
      $IdentityCredentialsCreateCompanionBuilder,
      $IdentityCredentialsUpdateCompanionBuilder,
      (IdentityCredential, $IdentityCredentialsReferences),
      IdentityCredential,
      PrefetchHooks Function({bool identityId, bool credentialId})
    >;
typedef $ConnectionsCreateCompanionBuilder =
    ConnectionsCompanion Function({
      Value<int> id,
      required String label,
      required String address,
      required int port,
      Value<int?> identityId,
      Value<String?> username,
      Value<String?> groupName,
      Value<ConnectionIcon> icon,
      required Color iconColor,
      required Color iconBackgroundColor,
      Value<bool> isIconAutoDetect,
      Value<TerminalTypography?> terminalTypographyOverride,
      Value<int?> terminalThemeOverrideId,
    });
typedef $ConnectionsUpdateCompanionBuilder =
    ConnectionsCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String> address,
      Value<int> port,
      Value<int?> identityId,
      Value<String?> username,
      Value<String?> groupName,
      Value<ConnectionIcon> icon,
      Value<Color> iconColor,
      Value<Color> iconBackgroundColor,
      Value<bool> isIconAutoDetect,
      Value<TerminalTypography?> terminalTypographyOverride,
      Value<int?> terminalThemeOverrideId,
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

  static CustomTerminalThemes _terminalThemeOverrideIdTable(
    _$CliqDatabase db,
  ) => db.customTerminalThemes.createAlias(
    $_aliasNameGenerator(
      db.connections.terminalThemeOverrideId,
      db.customTerminalThemes.id,
    ),
  );

  $CustomTerminalThemesProcessedTableManager? get terminalThemeOverrideId {
    final $_column = $_itemColumn<int>('terminal_theme_override_id');
    if ($_column == null) return null;
    final manager = $CustomTerminalThemesTableManager(
      $_db,
      $_db.customTerminalThemes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _terminalThemeOverrideIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<ConnectionCredentials, List<ConnectionCredential>>
  _connectionCredentialsRefsTable(_$CliqDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.connectionCredentials,
        aliasName: $_aliasNameGenerator(
          db.connections.id,
          db.connectionCredentials.connectionId,
        ),
      );

  $ConnectionCredentialsProcessedTableManager get connectionCredentialsRefs {
    final manager = $ConnectionCredentialsTableManager(
      $_db,
      $_db.connectionCredentials,
    ).filter((f) => f.connectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _connectionCredentialsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
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

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ConnectionIcon, ConnectionIcon, int>
  get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Color, Color, int> get iconColor =>
      $composableBuilder(
        column: $table.iconColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get iconBackgroundColor =>
      $composableBuilder(
        column: $table.iconBackgroundColor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isIconAutoDetect => $composableBuilder(
    column: $table.isIconAutoDetect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TerminalTypography?,
    TerminalTypography,
    String
  >
  get terminalTypographyOverride => $composableBuilder(
    column: $table.terminalTypographyOverride,
    builder: (column) => ColumnWithTypeConverterFilters(column),
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

  $CustomTerminalThemesFilterComposer get terminalThemeOverrideId {
    final $CustomTerminalThemesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terminalThemeOverrideId,
      referencedTable: $db.customTerminalThemes,
      getReferencedColumn: (t) => t.id,
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

  Expression<bool> connectionCredentialsRefs(
    Expression<bool> Function($ConnectionCredentialsFilterComposer f) f,
  ) {
    final $ConnectionCredentialsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connectionCredentials,
      getReferencedColumn: (t) => t.connectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionCredentialsFilterComposer(
            $db: $db,
            $table: $db.connectionCredentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
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

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconColor => $composableBuilder(
    column: $table.iconColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconBackgroundColor => $composableBuilder(
    column: $table.iconBackgroundColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIconAutoDetect => $composableBuilder(
    column: $table.isIconAutoDetect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terminalTypographyOverride => $composableBuilder(
    column: $table.terminalTypographyOverride,
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

  $CustomTerminalThemesOrderingComposer get terminalThemeOverrideId {
    final $CustomTerminalThemesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terminalThemeOverrideId,
      referencedTable: $db.customTerminalThemes,
      getReferencedColumn: (t) => t.id,
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

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ConnectionIcon, int> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get iconColor =>
      $composableBuilder(column: $table.iconColor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get iconBackgroundColor =>
      $composableBuilder(
        column: $table.iconBackgroundColor,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isIconAutoDetect => $composableBuilder(
    column: $table.isIconAutoDetect,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TerminalTypography?, String>
  get terminalTypographyOverride => $composableBuilder(
    column: $table.terminalTypographyOverride,
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

  $CustomTerminalThemesAnnotationComposer get terminalThemeOverrideId {
    final $CustomTerminalThemesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terminalThemeOverrideId,
      referencedTable: $db.customTerminalThemes,
      getReferencedColumn: (t) => t.id,
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

  Expression<T> connectionCredentialsRefs<T extends Object>(
    Expression<T> Function($ConnectionCredentialsAnnotationComposer a) f,
  ) {
    final $ConnectionCredentialsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connectionCredentials,
      getReferencedColumn: (t) => t.connectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionCredentialsAnnotationComposer(
            $db: $db,
            $table: $db.connectionCredentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
            bool terminalThemeOverrideId,
            bool connectionCredentialsRefs,
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
                Value<String> label = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<int?> identityId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<ConnectionIcon> icon = const Value.absent(),
                Value<Color> iconColor = const Value.absent(),
                Value<Color> iconBackgroundColor = const Value.absent(),
                Value<bool> isIconAutoDetect = const Value.absent(),
                Value<TerminalTypography?> terminalTypographyOverride =
                    const Value.absent(),
                Value<int?> terminalThemeOverrideId = const Value.absent(),
              }) => ConnectionsCompanion(
                id: id,
                label: label,
                address: address,
                port: port,
                identityId: identityId,
                username: username,
                groupName: groupName,
                icon: icon,
                iconColor: iconColor,
                iconBackgroundColor: iconBackgroundColor,
                isIconAutoDetect: isIconAutoDetect,
                terminalTypographyOverride: terminalTypographyOverride,
                terminalThemeOverrideId: terminalThemeOverrideId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String address,
                required int port,
                Value<int?> identityId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<ConnectionIcon> icon = const Value.absent(),
                required Color iconColor,
                required Color iconBackgroundColor,
                Value<bool> isIconAutoDetect = const Value.absent(),
                Value<TerminalTypography?> terminalTypographyOverride =
                    const Value.absent(),
                Value<int?> terminalThemeOverrideId = const Value.absent(),
              }) => ConnectionsCompanion.insert(
                id: id,
                label: label,
                address: address,
                port: port,
                identityId: identityId,
                username: username,
                groupName: groupName,
                icon: icon,
                iconColor: iconColor,
                iconBackgroundColor: iconBackgroundColor,
                isIconAutoDetect: isIconAutoDetect,
                terminalTypographyOverride: terminalTypographyOverride,
                terminalThemeOverrideId: terminalThemeOverrideId,
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
                terminalThemeOverrideId = false,
                connectionCredentialsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (connectionCredentialsRefs) db.connectionCredentials,
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
                        if (terminalThemeOverrideId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.terminalThemeOverrideId,
                                    referencedTable: $ConnectionsReferences
                                        ._terminalThemeOverrideIdTable(db),
                                    referencedColumn: $ConnectionsReferences
                                        ._terminalThemeOverrideIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (connectionCredentialsRefs)
                        await $_getPrefetchedData<
                          Connection,
                          Connections,
                          ConnectionCredential
                        >(
                          currentTable: table,
                          referencedTable: $ConnectionsReferences
                              ._connectionCredentialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ConnectionsReferences(
                                db,
                                table,
                                p0,
                              ).connectionCredentialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.connectionId == item.id,
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
        bool terminalThemeOverrideId,
        bool connectionCredentialsRefs,
      })
    >;
typedef $ConnectionCredentialsCreateCompanionBuilder =
    ConnectionCredentialsCompanion Function({
      required int connectionId,
      required int credentialId,
      Value<int> rowid,
    });
typedef $ConnectionCredentialsUpdateCompanionBuilder =
    ConnectionCredentialsCompanion Function({
      Value<int> connectionId,
      Value<int> credentialId,
      Value<int> rowid,
    });

final class $ConnectionCredentialsReferences
    extends
        BaseReferences<
          _$CliqDatabase,
          ConnectionCredentials,
          ConnectionCredential
        > {
  $ConnectionCredentialsReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Connections _connectionIdTable(_$CliqDatabase db) =>
      db.connections.createAlias(
        $_aliasNameGenerator(
          db.connectionCredentials.connectionId,
          db.connections.id,
        ),
      );

  $ConnectionsProcessedTableManager get connectionId {
    final $_column = $_itemColumn<int>('connection_id')!;

    final manager = $ConnectionsTableManager(
      $_db,
      $_db.connections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_connectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Credentials _credentialIdTable(_$CliqDatabase db) =>
      db.credentials.createAlias(
        $_aliasNameGenerator(
          db.connectionCredentials.credentialId,
          db.credentials.id,
        ),
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
}

class $ConnectionCredentialsFilterComposer
    extends Composer<_$CliqDatabase, ConnectionCredentials> {
  $ConnectionCredentialsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $ConnectionsFilterComposer get connectionId {
    final $ConnectionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
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
}

class $ConnectionCredentialsOrderingComposer
    extends Composer<_$CliqDatabase, ConnectionCredentials> {
  $ConnectionCredentialsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $ConnectionsOrderingComposer get connectionId {
    final $ConnectionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ConnectionsOrderingComposer(
            $db: $db,
            $table: $db.connections,
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
}

class $ConnectionCredentialsAnnotationComposer
    extends Composer<_$CliqDatabase, ConnectionCredentials> {
  $ConnectionCredentialsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $ConnectionsAnnotationComposer get connectionId {
    final $ConnectionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
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
}

class $ConnectionCredentialsTableManager
    extends
        RootTableManager<
          _$CliqDatabase,
          ConnectionCredentials,
          ConnectionCredential,
          $ConnectionCredentialsFilterComposer,
          $ConnectionCredentialsOrderingComposer,
          $ConnectionCredentialsAnnotationComposer,
          $ConnectionCredentialsCreateCompanionBuilder,
          $ConnectionCredentialsUpdateCompanionBuilder,
          (ConnectionCredential, $ConnectionCredentialsReferences),
          ConnectionCredential,
          PrefetchHooks Function({bool connectionId, bool credentialId})
        > {
  $ConnectionCredentialsTableManager(
    _$CliqDatabase db,
    ConnectionCredentials table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ConnectionCredentialsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ConnectionCredentialsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ConnectionCredentialsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> connectionId = const Value.absent(),
                Value<int> credentialId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionCredentialsCompanion(
                connectionId: connectionId,
                credentialId: credentialId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int connectionId,
                required int credentialId,
                Value<int> rowid = const Value.absent(),
              }) => ConnectionCredentialsCompanion.insert(
                connectionId: connectionId,
                credentialId: credentialId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $ConnectionCredentialsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({connectionId = false, credentialId = false}) {
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
                        if (connectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.connectionId,
                                    referencedTable:
                                        $ConnectionCredentialsReferences
                                            ._connectionIdTable(db),
                                    referencedColumn:
                                        $ConnectionCredentialsReferences
                                            ._connectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (credentialId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.credentialId,
                                    referencedTable:
                                        $ConnectionCredentialsReferences
                                            ._credentialIdTable(db),
                                    referencedColumn:
                                        $ConnectionCredentialsReferences
                                            ._credentialIdTable(db)
                                            .id,
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

typedef $ConnectionCredentialsProcessedTableManager =
    ProcessedTableManager<
      _$CliqDatabase,
      ConnectionCredentials,
      ConnectionCredential,
      $ConnectionCredentialsFilterComposer,
      $ConnectionCredentialsOrderingComposer,
      $ConnectionCredentialsAnnotationComposer,
      $ConnectionCredentialsCreateCompanionBuilder,
      $ConnectionCredentialsUpdateCompanionBuilder,
      (ConnectionCredential, $ConnectionCredentialsReferences),
      ConnectionCredential,
      PrefetchHooks Function({bool connectionId, bool credentialId})
    >;

class $CliqDatabaseManager {
  final _$CliqDatabase _db;
  $CliqDatabaseManager(this._db);
  $KnownHostsTableManager get knownHosts =>
      $KnownHostsTableManager(_db, _db.knownHosts);
  $CustomTerminalThemesTableManager get customTerminalThemes =>
      $CustomTerminalThemesTableManager(_db, _db.customTerminalThemes);
  $KeysTableManager get keys => $KeysTableManager(_db, _db.keys);
  $IdentitiesTableManager get identities =>
      $IdentitiesTableManager(_db, _db.identities);
  $CredentialsTableManager get credentials =>
      $CredentialsTableManager(_db, _db.credentials);
  $IdentityCredentialsTableManager get identityCredentials =>
      $IdentityCredentialsTableManager(_db, _db.identityCredentials);
  $ConnectionsTableManager get connections =>
      $ConnectionsTableManager(_db, _db.connections);
  $ConnectionCredentialsTableManager get connectionCredentials =>
      $ConnectionCredentialsTableManager(_db, _db.connectionCredentials);
}

class FindAllIdentityFullResult {
  final Identity identity;
  final List<int> identityCredentials;
  FindAllIdentityFullResult({
    required this.identity,
    required this.identityCredentials,
  });
}

class FindCredentialFullByIdsResult {
  final Credential credential;
  final Key? credentialKey;
  FindCredentialFullByIdsResult({required this.credential, this.credentialKey});
}

class FindAllConnectionFullResult {
  final Connection connection;
  final Identity? identity;
  final CustomTerminalTheme? terminalThemeOverride;
  final List<int> connectionCredentials;
  final List<int> identityCredentials;
  FindAllConnectionFullResult({
    required this.connection,
    this.identity,
    this.terminalThemeOverride,
    required this.connectionCredentials,
    required this.identityCredentials,
  });
}
