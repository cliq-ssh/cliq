// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Vaults extends Table with TableInfo<Vaults, Vault> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Vaults(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'UNIQUE',
  );
  @override
  List<GeneratedColumn> get $columns => [id, owner];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaults';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vault> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vault map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vault(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      ),
    );
  }

  @override
  Vaults createAlias(String alias) {
    return Vaults(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Vault extends DataClass implements Insertable<Vault> {
  final String id;
  final String? owner;
  const Vault({required this.id, this.owner});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || owner != null) {
      map['owner'] = Variable<String>(owner);
    }
    return map;
  }

  VaultsCompanion toCompanion(bool nullToAbsent) {
    return VaultsCompanion(
      id: Value(id),
      owner: owner == null && nullToAbsent
          ? const Value.absent()
          : Value(owner),
    );
  }

  factory Vault.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vault(
      id: serializer.fromJson<String>(json['id']),
      owner: serializer.fromJson<String?>(json['owner']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'owner': serializer.toJson<String?>(owner),
    };
  }

  Vault copyWith({String? id, Value<String?> owner = const Value.absent()}) =>
      Vault(id: id ?? this.id, owner: owner.present ? owner.value : this.owner);
  Vault copyWithCompanion(VaultsCompanion data) {
    return Vault(
      id: data.id.present ? data.id.value : this.id,
      owner: data.owner.present ? data.owner.value : this.owner,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vault(')
          ..write('id: $id, ')
          ..write('owner: $owner')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, owner);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vault && other.id == this.id && other.owner == this.owner);
}

class VaultsCompanion extends UpdateCompanion<Vault> {
  final Value<String> id;
  final Value<String?> owner;
  final Value<int> rowid;
  const VaultsCompanion({
    this.id = const Value.absent(),
    this.owner = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultsCompanion.insert({
    this.id = const Value.absent(),
    this.owner = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<Vault> custom({
    Expression<String>? id,
    Expression<String>? owner,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (owner != null) 'owner': owner,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultsCompanion copyWith({
    Value<String>? id,
    Value<String?>? owner,
    Value<int>? rowid,
  }) {
    return VaultsCompanion(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultsCompanion(')
          ..write('id: $id, ')
          ..write('owner: $owner, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _vaultIdMeta = const VerificationMeta(
    'vaultId',
  );
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES vaults(id)ON DELETE CASCADE',
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
  List<GeneratedColumn> get $columns => [id, vaultId, label, username];
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
    if (data.containsKey('vault_id')) {
      context.handle(
        _vaultIdMeta,
        vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vaultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_id'],
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
  final String id;
  final String vaultId;
  final String label;
  final String username;
  const Identity({
    required this.id,
    required this.vaultId,
    required this.label,
    required this.username,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<String>(vaultId);
    map['label'] = Variable<String>(label);
    map['username'] = Variable<String>(username);
    return map;
  }

  IdentitiesCompanion toCompanion(bool nullToAbsent) {
    return IdentitiesCompanion(
      id: Value(id),
      vaultId: Value(vaultId),
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
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<String>(json['vault_id']),
      label: serializer.fromJson<String>(json['label']),
      username: serializer.fromJson<String>(json['username']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vault_id': serializer.toJson<String>(vaultId),
      'label': serializer.toJson<String>(label),
      'username': serializer.toJson<String>(username),
    };
  }

  Identity copyWith({
    String? id,
    String? vaultId,
    String? label,
    String? username,
  }) => Identity(
    id: id ?? this.id,
    vaultId: vaultId ?? this.vaultId,
    label: label ?? this.label,
    username: username ?? this.username,
  );
  Identity copyWithCompanion(IdentitiesCompanion data) {
    return Identity(
      id: data.id.present ? data.id.value : this.id,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      label: data.label.present ? data.label.value : this.label,
      username: data.username.present ? data.username.value : this.username,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Identity(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('label: $label, ')
          ..write('username: $username')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vaultId, label, username);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Identity &&
          other.id == this.id &&
          other.vaultId == this.vaultId &&
          other.label == this.label &&
          other.username == this.username);
}

class IdentitiesCompanion extends UpdateCompanion<Identity> {
  final Value<String> id;
  final Value<String> vaultId;
  final Value<String> label;
  final Value<String> username;
  final Value<int> rowid;
  const IdentitiesCompanion({
    this.id = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.label = const Value.absent(),
    this.username = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdentitiesCompanion.insert({
    this.id = const Value.absent(),
    required String vaultId,
    required String label,
    required String username,
    this.rowid = const Value.absent(),
  }) : vaultId = Value(vaultId),
       label = Value(label),
       username = Value(username);
  static Insertable<Identity> custom({
    Expression<String>? id,
    Expression<String>? vaultId,
    Expression<String>? label,
    Expression<String>? username,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultId != null) 'vault_id': vaultId,
      if (label != null) 'label': label,
      if (username != null) 'username': username,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdentitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? vaultId,
    Value<String>? label,
    Value<String>? username,
    Value<int>? rowid,
  }) {
    return IdentitiesCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      label: label ?? this.label,
      username: username ?? this.username,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<String>(vaultId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentitiesCompanion(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('label: $label, ')
          ..write('username: $username, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
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
  late final GeneratedColumnWithTypeConverter<Color, int> black =
      GeneratedColumn<int>(
        'black',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterblack);
  late final GeneratedColumnWithTypeConverter<Color, int> red =
      GeneratedColumn<int>(
        'red',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterred);
  late final GeneratedColumnWithTypeConverter<Color, int> green =
      GeneratedColumn<int>(
        'green',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$convertergreen);
  late final GeneratedColumnWithTypeConverter<Color, int> yellow =
      GeneratedColumn<int>(
        'yellow',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converteryellow);
  late final GeneratedColumnWithTypeConverter<Color, int> blue =
      GeneratedColumn<int>(
        'blue',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterblue);
  late final GeneratedColumnWithTypeConverter<Color, int> purple =
      GeneratedColumn<int>(
        'purple',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterpurple);
  late final GeneratedColumnWithTypeConverter<Color, int> cyan =
      GeneratedColumn<int>(
        'cyan',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$convertercyan);
  late final GeneratedColumnWithTypeConverter<Color, int> white =
      GeneratedColumn<int>(
        'white',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterwhite);
  late final GeneratedColumnWithTypeConverter<Color, int> brightBlack =
      GeneratedColumn<int>(
        'bright_black',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightBlack);
  late final GeneratedColumnWithTypeConverter<Color, int> brightRed =
      GeneratedColumn<int>(
        'bright_red',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightRed);
  late final GeneratedColumnWithTypeConverter<Color, int> brightGreen =
      GeneratedColumn<int>(
        'bright_green',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightGreen);
  late final GeneratedColumnWithTypeConverter<Color, int> brightYellow =
      GeneratedColumn<int>(
        'bright_yellow',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightYellow);
  late final GeneratedColumnWithTypeConverter<Color, int> brightBlue =
      GeneratedColumn<int>(
        'bright_blue',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightBlue);
  late final GeneratedColumnWithTypeConverter<Color, int> brightPurple =
      GeneratedColumn<int>(
        'bright_purple',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightPurple);
  late final GeneratedColumnWithTypeConverter<Color, int> brightCyan =
      GeneratedColumn<int>(
        'bright_cyan',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightCyan);
  late final GeneratedColumnWithTypeConverter<Color, int> brightWhite =
      GeneratedColumn<int>(
        'bright_white',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbrightWhite);
  late final GeneratedColumnWithTypeConverter<Color, int> background =
      GeneratedColumn<int>(
        'background',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterbackground);
  late final GeneratedColumnWithTypeConverter<Color, int> foreground =
      GeneratedColumn<int>(
        'foreground',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$converterforeground);
  late final GeneratedColumnWithTypeConverter<Color, int> cursor =
      GeneratedColumn<int>(
        'cursor',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$convertercursor);
  late final GeneratedColumnWithTypeConverter<Color, int> cursorText =
      GeneratedColumn<int>(
        'cursor_text',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(CustomTerminalThemes.$convertercursorText);
  late final GeneratedColumnWithTypeConverter<Color, int> selectionBackground =
      GeneratedColumn<int>(
        'selection_background',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(
        CustomTerminalThemes.$converterselectionBackground,
      );
  late final GeneratedColumnWithTypeConverter<Color, int> selectionForeground =
      GeneratedColumn<int>(
        'selection_foreground',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(
        CustomTerminalThemes.$converterselectionForeground,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    black,
    red,
    green,
    yellow,
    blue,
    purple,
    cyan,
    white,
    brightBlack,
    brightRed,
    brightGreen,
    brightYellow,
    brightBlue,
    brightPurple,
    brightCyan,
    brightWhite,
    background,
    foreground,
    cursor,
    cursorText,
    selectionBackground,
    selectionForeground,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {
      name,
      black,
      red,
      green,
      yellow,
      blue,
      purple,
      cyan,
      white,
      brightBlack,
      brightRed,
      brightGreen,
      brightYellow,
      brightBlue,
      brightPurple,
      brightCyan,
      brightWhite,
      background,
      foreground,
      cursor,
      cursorText,
      selectionBackground,
      selectionForeground,
    },
  ];
  @override
  CustomTerminalTheme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomTerminalTheme(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      black: CustomTerminalThemes.$converterblack.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}black'],
        )!,
      ),
      red: CustomTerminalThemes.$converterred.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}red'],
        )!,
      ),
      green: CustomTerminalThemes.$convertergreen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}green'],
        )!,
      ),
      yellow: CustomTerminalThemes.$converteryellow.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}yellow'],
        )!,
      ),
      blue: CustomTerminalThemes.$converterblue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}blue'],
        )!,
      ),
      purple: CustomTerminalThemes.$converterpurple.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}purple'],
        )!,
      ),
      cyan: CustomTerminalThemes.$convertercyan.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cyan'],
        )!,
      ),
      white: CustomTerminalThemes.$converterwhite.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}white'],
        )!,
      ),
      brightBlack: CustomTerminalThemes.$converterbrightBlack.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_black'],
        )!,
      ),
      brightRed: CustomTerminalThemes.$converterbrightRed.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_red'],
        )!,
      ),
      brightGreen: CustomTerminalThemes.$converterbrightGreen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_green'],
        )!,
      ),
      brightYellow: CustomTerminalThemes.$converterbrightYellow.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_yellow'],
        )!,
      ),
      brightBlue: CustomTerminalThemes.$converterbrightBlue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_blue'],
        )!,
      ),
      brightPurple: CustomTerminalThemes.$converterbrightPurple.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_purple'],
        )!,
      ),
      brightCyan: CustomTerminalThemes.$converterbrightCyan.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_cyan'],
        )!,
      ),
      brightWhite: CustomTerminalThemes.$converterbrightWhite.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}bright_white'],
        )!,
      ),
      background: CustomTerminalThemes.$converterbackground.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}background'],
        )!,
      ),
      foreground: CustomTerminalThemes.$converterforeground.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}foreground'],
        )!,
      ),
      cursor: CustomTerminalThemes.$convertercursor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cursor'],
        )!,
      ),
      cursorText: CustomTerminalThemes.$convertercursorText.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cursor_text'],
        )!,
      ),
      selectionBackground: CustomTerminalThemes.$converterselectionBackground
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}selection_background'],
            )!,
          ),
      selectionForeground: CustomTerminalThemes.$converterselectionForeground
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}selection_foreground'],
            )!,
          ),
    );
  }

  @override
  CustomTerminalThemes createAlias(String alias) {
    return CustomTerminalThemes(attachedDatabase, alias);
  }

  static TypeConverter<Color, int> $converterblack = const ColorConverter();
  static TypeConverter<Color, int> $converterred = const ColorConverter();
  static TypeConverter<Color, int> $convertergreen = const ColorConverter();
  static TypeConverter<Color, int> $converteryellow = const ColorConverter();
  static TypeConverter<Color, int> $converterblue = const ColorConverter();
  static TypeConverter<Color, int> $converterpurple = const ColorConverter();
  static TypeConverter<Color, int> $convertercyan = const ColorConverter();
  static TypeConverter<Color, int> $converterwhite = const ColorConverter();
  static TypeConverter<Color, int> $converterbrightBlack =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightRed = const ColorConverter();
  static TypeConverter<Color, int> $converterbrightGreen =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightYellow =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightBlue =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightPurple =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightCyan =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbrightWhite =
      const ColorConverter();
  static TypeConverter<Color, int> $converterbackground =
      const ColorConverter();
  static TypeConverter<Color, int> $converterforeground =
      const ColorConverter();
  static TypeConverter<Color, int> $convertercursor = const ColorConverter();
  static TypeConverter<Color, int> $convertercursorText =
      const ColorConverter();
  static TypeConverter<Color, int> $converterselectionBackground =
      const ColorConverter();
  static TypeConverter<Color, int> $converterselectionForeground =
      const ColorConverter();
  @override
  List<String> get customConstraints => const [
    'UNIQUE(name, black, red, green, yellow, blue, purple, cyan, white, bright_black, bright_red, bright_green, bright_yellow, bright_blue, bright_purple, bright_cyan, bright_white, background, foreground, cursor, cursor_text, selection_background, selection_foreground)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class CustomTerminalTheme extends DataClass
    implements Insertable<CustomTerminalTheme> {
  final String id;
  final String name;
  final Color black;
  final Color red;
  final Color green;
  final Color yellow;
  final Color blue;
  final Color purple;
  final Color cyan;
  final Color white;
  final Color brightBlack;
  final Color brightRed;
  final Color brightGreen;
  final Color brightYellow;
  final Color brightBlue;
  final Color brightPurple;
  final Color brightCyan;
  final Color brightWhite;
  final Color background;
  final Color foreground;
  final Color cursor;
  final Color cursorText;
  final Color selectionBackground;
  final Color selectionForeground;
  const CustomTerminalTheme({
    required this.id,
    required this.name,
    required this.black,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.purple,
    required this.cyan,
    required this.white,
    required this.brightBlack,
    required this.brightRed,
    required this.brightGreen,
    required this.brightYellow,
    required this.brightBlue,
    required this.brightPurple,
    required this.brightCyan,
    required this.brightWhite,
    required this.background,
    required this.foreground,
    required this.cursor,
    required this.cursorText,
    required this.selectionBackground,
    required this.selectionForeground,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['black'] = Variable<int>(
        CustomTerminalThemes.$converterblack.toSql(black),
      );
    }
    {
      map['red'] = Variable<int>(CustomTerminalThemes.$converterred.toSql(red));
    }
    {
      map['green'] = Variable<int>(
        CustomTerminalThemes.$convertergreen.toSql(green),
      );
    }
    {
      map['yellow'] = Variable<int>(
        CustomTerminalThemes.$converteryellow.toSql(yellow),
      );
    }
    {
      map['blue'] = Variable<int>(
        CustomTerminalThemes.$converterblue.toSql(blue),
      );
    }
    {
      map['purple'] = Variable<int>(
        CustomTerminalThemes.$converterpurple.toSql(purple),
      );
    }
    {
      map['cyan'] = Variable<int>(
        CustomTerminalThemes.$convertercyan.toSql(cyan),
      );
    }
    {
      map['white'] = Variable<int>(
        CustomTerminalThemes.$converterwhite.toSql(white),
      );
    }
    {
      map['bright_black'] = Variable<int>(
        CustomTerminalThemes.$converterbrightBlack.toSql(brightBlack),
      );
    }
    {
      map['bright_red'] = Variable<int>(
        CustomTerminalThemes.$converterbrightRed.toSql(brightRed),
      );
    }
    {
      map['bright_green'] = Variable<int>(
        CustomTerminalThemes.$converterbrightGreen.toSql(brightGreen),
      );
    }
    {
      map['bright_yellow'] = Variable<int>(
        CustomTerminalThemes.$converterbrightYellow.toSql(brightYellow),
      );
    }
    {
      map['bright_blue'] = Variable<int>(
        CustomTerminalThemes.$converterbrightBlue.toSql(brightBlue),
      );
    }
    {
      map['bright_purple'] = Variable<int>(
        CustomTerminalThemes.$converterbrightPurple.toSql(brightPurple),
      );
    }
    {
      map['bright_cyan'] = Variable<int>(
        CustomTerminalThemes.$converterbrightCyan.toSql(brightCyan),
      );
    }
    {
      map['bright_white'] = Variable<int>(
        CustomTerminalThemes.$converterbrightWhite.toSql(brightWhite),
      );
    }
    {
      map['background'] = Variable<int>(
        CustomTerminalThemes.$converterbackground.toSql(background),
      );
    }
    {
      map['foreground'] = Variable<int>(
        CustomTerminalThemes.$converterforeground.toSql(foreground),
      );
    }
    {
      map['cursor'] = Variable<int>(
        CustomTerminalThemes.$convertercursor.toSql(cursor),
      );
    }
    {
      map['cursor_text'] = Variable<int>(
        CustomTerminalThemes.$convertercursorText.toSql(cursorText),
      );
    }
    {
      map['selection_background'] = Variable<int>(
        CustomTerminalThemes.$converterselectionBackground.toSql(
          selectionBackground,
        ),
      );
    }
    {
      map['selection_foreground'] = Variable<int>(
        CustomTerminalThemes.$converterselectionForeground.toSql(
          selectionForeground,
        ),
      );
    }
    return map;
  }

  CustomTerminalThemesCompanion toCompanion(bool nullToAbsent) {
    return CustomTerminalThemesCompanion(
      id: Value(id),
      name: Value(name),
      black: Value(black),
      red: Value(red),
      green: Value(green),
      yellow: Value(yellow),
      blue: Value(blue),
      purple: Value(purple),
      cyan: Value(cyan),
      white: Value(white),
      brightBlack: Value(brightBlack),
      brightRed: Value(brightRed),
      brightGreen: Value(brightGreen),
      brightYellow: Value(brightYellow),
      brightBlue: Value(brightBlue),
      brightPurple: Value(brightPurple),
      brightCyan: Value(brightCyan),
      brightWhite: Value(brightWhite),
      background: Value(background),
      foreground: Value(foreground),
      cursor: Value(cursor),
      cursorText: Value(cursorText),
      selectionBackground: Value(selectionBackground),
      selectionForeground: Value(selectionForeground),
    );
  }

  factory CustomTerminalTheme.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomTerminalTheme(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      black: serializer.fromJson<Color>(json['black']),
      red: serializer.fromJson<Color>(json['red']),
      green: serializer.fromJson<Color>(json['green']),
      yellow: serializer.fromJson<Color>(json['yellow']),
      blue: serializer.fromJson<Color>(json['blue']),
      purple: serializer.fromJson<Color>(json['purple']),
      cyan: serializer.fromJson<Color>(json['cyan']),
      white: serializer.fromJson<Color>(json['white']),
      brightBlack: serializer.fromJson<Color>(json['bright_black']),
      brightRed: serializer.fromJson<Color>(json['bright_red']),
      brightGreen: serializer.fromJson<Color>(json['bright_green']),
      brightYellow: serializer.fromJson<Color>(json['bright_yellow']),
      brightBlue: serializer.fromJson<Color>(json['bright_blue']),
      brightPurple: serializer.fromJson<Color>(json['bright_purple']),
      brightCyan: serializer.fromJson<Color>(json['bright_cyan']),
      brightWhite: serializer.fromJson<Color>(json['bright_white']),
      background: serializer.fromJson<Color>(json['background']),
      foreground: serializer.fromJson<Color>(json['foreground']),
      cursor: serializer.fromJson<Color>(json['cursor']),
      cursorText: serializer.fromJson<Color>(json['cursor_text']),
      selectionBackground: serializer.fromJson<Color>(
        json['selection_background'],
      ),
      selectionForeground: serializer.fromJson<Color>(
        json['selection_foreground'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'black': serializer.toJson<Color>(black),
      'red': serializer.toJson<Color>(red),
      'green': serializer.toJson<Color>(green),
      'yellow': serializer.toJson<Color>(yellow),
      'blue': serializer.toJson<Color>(blue),
      'purple': serializer.toJson<Color>(purple),
      'cyan': serializer.toJson<Color>(cyan),
      'white': serializer.toJson<Color>(white),
      'bright_black': serializer.toJson<Color>(brightBlack),
      'bright_red': serializer.toJson<Color>(brightRed),
      'bright_green': serializer.toJson<Color>(brightGreen),
      'bright_yellow': serializer.toJson<Color>(brightYellow),
      'bright_blue': serializer.toJson<Color>(brightBlue),
      'bright_purple': serializer.toJson<Color>(brightPurple),
      'bright_cyan': serializer.toJson<Color>(brightCyan),
      'bright_white': serializer.toJson<Color>(brightWhite),
      'background': serializer.toJson<Color>(background),
      'foreground': serializer.toJson<Color>(foreground),
      'cursor': serializer.toJson<Color>(cursor),
      'cursor_text': serializer.toJson<Color>(cursorText),
      'selection_background': serializer.toJson<Color>(selectionBackground),
      'selection_foreground': serializer.toJson<Color>(selectionForeground),
    };
  }

  CustomTerminalTheme copyWith({
    String? id,
    String? name,
    Color? black,
    Color? red,
    Color? green,
    Color? yellow,
    Color? blue,
    Color? purple,
    Color? cyan,
    Color? white,
    Color? brightBlack,
    Color? brightRed,
    Color? brightGreen,
    Color? brightYellow,
    Color? brightBlue,
    Color? brightPurple,
    Color? brightCyan,
    Color? brightWhite,
    Color? background,
    Color? foreground,
    Color? cursor,
    Color? cursorText,
    Color? selectionBackground,
    Color? selectionForeground,
  }) => CustomTerminalTheme(
    id: id ?? this.id,
    name: name ?? this.name,
    black: black ?? this.black,
    red: red ?? this.red,
    green: green ?? this.green,
    yellow: yellow ?? this.yellow,
    blue: blue ?? this.blue,
    purple: purple ?? this.purple,
    cyan: cyan ?? this.cyan,
    white: white ?? this.white,
    brightBlack: brightBlack ?? this.brightBlack,
    brightRed: brightRed ?? this.brightRed,
    brightGreen: brightGreen ?? this.brightGreen,
    brightYellow: brightYellow ?? this.brightYellow,
    brightBlue: brightBlue ?? this.brightBlue,
    brightPurple: brightPurple ?? this.brightPurple,
    brightCyan: brightCyan ?? this.brightCyan,
    brightWhite: brightWhite ?? this.brightWhite,
    background: background ?? this.background,
    foreground: foreground ?? this.foreground,
    cursor: cursor ?? this.cursor,
    cursorText: cursorText ?? this.cursorText,
    selectionBackground: selectionBackground ?? this.selectionBackground,
    selectionForeground: selectionForeground ?? this.selectionForeground,
  );
  CustomTerminalTheme copyWithCompanion(CustomTerminalThemesCompanion data) {
    return CustomTerminalTheme(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      black: data.black.present ? data.black.value : this.black,
      red: data.red.present ? data.red.value : this.red,
      green: data.green.present ? data.green.value : this.green,
      yellow: data.yellow.present ? data.yellow.value : this.yellow,
      blue: data.blue.present ? data.blue.value : this.blue,
      purple: data.purple.present ? data.purple.value : this.purple,
      cyan: data.cyan.present ? data.cyan.value : this.cyan,
      white: data.white.present ? data.white.value : this.white,
      brightBlack: data.brightBlack.present
          ? data.brightBlack.value
          : this.brightBlack,
      brightRed: data.brightRed.present ? data.brightRed.value : this.brightRed,
      brightGreen: data.brightGreen.present
          ? data.brightGreen.value
          : this.brightGreen,
      brightYellow: data.brightYellow.present
          ? data.brightYellow.value
          : this.brightYellow,
      brightBlue: data.brightBlue.present
          ? data.brightBlue.value
          : this.brightBlue,
      brightPurple: data.brightPurple.present
          ? data.brightPurple.value
          : this.brightPurple,
      brightCyan: data.brightCyan.present
          ? data.brightCyan.value
          : this.brightCyan,
      brightWhite: data.brightWhite.present
          ? data.brightWhite.value
          : this.brightWhite,
      background: data.background.present
          ? data.background.value
          : this.background,
      foreground: data.foreground.present
          ? data.foreground.value
          : this.foreground,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      cursorText: data.cursorText.present
          ? data.cursorText.value
          : this.cursorText,
      selectionBackground: data.selectionBackground.present
          ? data.selectionBackground.value
          : this.selectionBackground,
      selectionForeground: data.selectionForeground.present
          ? data.selectionForeground.value
          : this.selectionForeground,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomTerminalTheme(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('black: $black, ')
          ..write('red: $red, ')
          ..write('green: $green, ')
          ..write('yellow: $yellow, ')
          ..write('blue: $blue, ')
          ..write('purple: $purple, ')
          ..write('cyan: $cyan, ')
          ..write('white: $white, ')
          ..write('brightBlack: $brightBlack, ')
          ..write('brightRed: $brightRed, ')
          ..write('brightGreen: $brightGreen, ')
          ..write('brightYellow: $brightYellow, ')
          ..write('brightBlue: $brightBlue, ')
          ..write('brightPurple: $brightPurple, ')
          ..write('brightCyan: $brightCyan, ')
          ..write('brightWhite: $brightWhite, ')
          ..write('background: $background, ')
          ..write('foreground: $foreground, ')
          ..write('cursor: $cursor, ')
          ..write('cursorText: $cursorText, ')
          ..write('selectionBackground: $selectionBackground, ')
          ..write('selectionForeground: $selectionForeground')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    black,
    red,
    green,
    yellow,
    blue,
    purple,
    cyan,
    white,
    brightBlack,
    brightRed,
    brightGreen,
    brightYellow,
    brightBlue,
    brightPurple,
    brightCyan,
    brightWhite,
    background,
    foreground,
    cursor,
    cursorText,
    selectionBackground,
    selectionForeground,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomTerminalTheme &&
          other.id == this.id &&
          other.name == this.name &&
          other.black == this.black &&
          other.red == this.red &&
          other.green == this.green &&
          other.yellow == this.yellow &&
          other.blue == this.blue &&
          other.purple == this.purple &&
          other.cyan == this.cyan &&
          other.white == this.white &&
          other.brightBlack == this.brightBlack &&
          other.brightRed == this.brightRed &&
          other.brightGreen == this.brightGreen &&
          other.brightYellow == this.brightYellow &&
          other.brightBlue == this.brightBlue &&
          other.brightPurple == this.brightPurple &&
          other.brightCyan == this.brightCyan &&
          other.brightWhite == this.brightWhite &&
          other.background == this.background &&
          other.foreground == this.foreground &&
          other.cursor == this.cursor &&
          other.cursorText == this.cursorText &&
          other.selectionBackground == this.selectionBackground &&
          other.selectionForeground == this.selectionForeground);
}

class CustomTerminalThemesCompanion
    extends UpdateCompanion<CustomTerminalTheme> {
  final Value<String> id;
  final Value<String> name;
  final Value<Color> black;
  final Value<Color> red;
  final Value<Color> green;
  final Value<Color> yellow;
  final Value<Color> blue;
  final Value<Color> purple;
  final Value<Color> cyan;
  final Value<Color> white;
  final Value<Color> brightBlack;
  final Value<Color> brightRed;
  final Value<Color> brightGreen;
  final Value<Color> brightYellow;
  final Value<Color> brightBlue;
  final Value<Color> brightPurple;
  final Value<Color> brightCyan;
  final Value<Color> brightWhite;
  final Value<Color> background;
  final Value<Color> foreground;
  final Value<Color> cursor;
  final Value<Color> cursorText;
  final Value<Color> selectionBackground;
  final Value<Color> selectionForeground;
  final Value<int> rowid;
  const CustomTerminalThemesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.black = const Value.absent(),
    this.red = const Value.absent(),
    this.green = const Value.absent(),
    this.yellow = const Value.absent(),
    this.blue = const Value.absent(),
    this.purple = const Value.absent(),
    this.cyan = const Value.absent(),
    this.white = const Value.absent(),
    this.brightBlack = const Value.absent(),
    this.brightRed = const Value.absent(),
    this.brightGreen = const Value.absent(),
    this.brightYellow = const Value.absent(),
    this.brightBlue = const Value.absent(),
    this.brightPurple = const Value.absent(),
    this.brightCyan = const Value.absent(),
    this.brightWhite = const Value.absent(),
    this.background = const Value.absent(),
    this.foreground = const Value.absent(),
    this.cursor = const Value.absent(),
    this.cursorText = const Value.absent(),
    this.selectionBackground = const Value.absent(),
    this.selectionForeground = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomTerminalThemesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required Color black,
    required Color red,
    required Color green,
    required Color yellow,
    required Color blue,
    required Color purple,
    required Color cyan,
    required Color white,
    required Color brightBlack,
    required Color brightRed,
    required Color brightGreen,
    required Color brightYellow,
    required Color brightBlue,
    required Color brightPurple,
    required Color brightCyan,
    required Color brightWhite,
    required Color background,
    required Color foreground,
    required Color cursor,
    required Color cursorText,
    required Color selectionBackground,
    required Color selectionForeground,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       black = Value(black),
       red = Value(red),
       green = Value(green),
       yellow = Value(yellow),
       blue = Value(blue),
       purple = Value(purple),
       cyan = Value(cyan),
       white = Value(white),
       brightBlack = Value(brightBlack),
       brightRed = Value(brightRed),
       brightGreen = Value(brightGreen),
       brightYellow = Value(brightYellow),
       brightBlue = Value(brightBlue),
       brightPurple = Value(brightPurple),
       brightCyan = Value(brightCyan),
       brightWhite = Value(brightWhite),
       background = Value(background),
       foreground = Value(foreground),
       cursor = Value(cursor),
       cursorText = Value(cursorText),
       selectionBackground = Value(selectionBackground),
       selectionForeground = Value(selectionForeground);
  static Insertable<CustomTerminalTheme> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? black,
    Expression<int>? red,
    Expression<int>? green,
    Expression<int>? yellow,
    Expression<int>? blue,
    Expression<int>? purple,
    Expression<int>? cyan,
    Expression<int>? white,
    Expression<int>? brightBlack,
    Expression<int>? brightRed,
    Expression<int>? brightGreen,
    Expression<int>? brightYellow,
    Expression<int>? brightBlue,
    Expression<int>? brightPurple,
    Expression<int>? brightCyan,
    Expression<int>? brightWhite,
    Expression<int>? background,
    Expression<int>? foreground,
    Expression<int>? cursor,
    Expression<int>? cursorText,
    Expression<int>? selectionBackground,
    Expression<int>? selectionForeground,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (black != null) 'black': black,
      if (red != null) 'red': red,
      if (green != null) 'green': green,
      if (yellow != null) 'yellow': yellow,
      if (blue != null) 'blue': blue,
      if (purple != null) 'purple': purple,
      if (cyan != null) 'cyan': cyan,
      if (white != null) 'white': white,
      if (brightBlack != null) 'bright_black': brightBlack,
      if (brightRed != null) 'bright_red': brightRed,
      if (brightGreen != null) 'bright_green': brightGreen,
      if (brightYellow != null) 'bright_yellow': brightYellow,
      if (brightBlue != null) 'bright_blue': brightBlue,
      if (brightPurple != null) 'bright_purple': brightPurple,
      if (brightCyan != null) 'bright_cyan': brightCyan,
      if (brightWhite != null) 'bright_white': brightWhite,
      if (background != null) 'background': background,
      if (foreground != null) 'foreground': foreground,
      if (cursor != null) 'cursor': cursor,
      if (cursorText != null) 'cursor_text': cursorText,
      if (selectionBackground != null)
        'selection_background': selectionBackground,
      if (selectionForeground != null)
        'selection_foreground': selectionForeground,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomTerminalThemesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<Color>? black,
    Value<Color>? red,
    Value<Color>? green,
    Value<Color>? yellow,
    Value<Color>? blue,
    Value<Color>? purple,
    Value<Color>? cyan,
    Value<Color>? white,
    Value<Color>? brightBlack,
    Value<Color>? brightRed,
    Value<Color>? brightGreen,
    Value<Color>? brightYellow,
    Value<Color>? brightBlue,
    Value<Color>? brightPurple,
    Value<Color>? brightCyan,
    Value<Color>? brightWhite,
    Value<Color>? background,
    Value<Color>? foreground,
    Value<Color>? cursor,
    Value<Color>? cursorText,
    Value<Color>? selectionBackground,
    Value<Color>? selectionForeground,
    Value<int>? rowid,
  }) {
    return CustomTerminalThemesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      black: black ?? this.black,
      red: red ?? this.red,
      green: green ?? this.green,
      yellow: yellow ?? this.yellow,
      blue: blue ?? this.blue,
      purple: purple ?? this.purple,
      cyan: cyan ?? this.cyan,
      white: white ?? this.white,
      brightBlack: brightBlack ?? this.brightBlack,
      brightRed: brightRed ?? this.brightRed,
      brightGreen: brightGreen ?? this.brightGreen,
      brightYellow: brightYellow ?? this.brightYellow,
      brightBlue: brightBlue ?? this.brightBlue,
      brightPurple: brightPurple ?? this.brightPurple,
      brightCyan: brightCyan ?? this.brightCyan,
      brightWhite: brightWhite ?? this.brightWhite,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      cursor: cursor ?? this.cursor,
      cursorText: cursorText ?? this.cursorText,
      selectionBackground: selectionBackground ?? this.selectionBackground,
      selectionForeground: selectionForeground ?? this.selectionForeground,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (black.present) {
      map['black'] = Variable<int>(
        CustomTerminalThemes.$converterblack.toSql(black.value),
      );
    }
    if (red.present) {
      map['red'] = Variable<int>(
        CustomTerminalThemes.$converterred.toSql(red.value),
      );
    }
    if (green.present) {
      map['green'] = Variable<int>(
        CustomTerminalThemes.$convertergreen.toSql(green.value),
      );
    }
    if (yellow.present) {
      map['yellow'] = Variable<int>(
        CustomTerminalThemes.$converteryellow.toSql(yellow.value),
      );
    }
    if (blue.present) {
      map['blue'] = Variable<int>(
        CustomTerminalThemes.$converterblue.toSql(blue.value),
      );
    }
    if (purple.present) {
      map['purple'] = Variable<int>(
        CustomTerminalThemes.$converterpurple.toSql(purple.value),
      );
    }
    if (cyan.present) {
      map['cyan'] = Variable<int>(
        CustomTerminalThemes.$convertercyan.toSql(cyan.value),
      );
    }
    if (white.present) {
      map['white'] = Variable<int>(
        CustomTerminalThemes.$converterwhite.toSql(white.value),
      );
    }
    if (brightBlack.present) {
      map['bright_black'] = Variable<int>(
        CustomTerminalThemes.$converterbrightBlack.toSql(brightBlack.value),
      );
    }
    if (brightRed.present) {
      map['bright_red'] = Variable<int>(
        CustomTerminalThemes.$converterbrightRed.toSql(brightRed.value),
      );
    }
    if (brightGreen.present) {
      map['bright_green'] = Variable<int>(
        CustomTerminalThemes.$converterbrightGreen.toSql(brightGreen.value),
      );
    }
    if (brightYellow.present) {
      map['bright_yellow'] = Variable<int>(
        CustomTerminalThemes.$converterbrightYellow.toSql(brightYellow.value),
      );
    }
    if (brightBlue.present) {
      map['bright_blue'] = Variable<int>(
        CustomTerminalThemes.$converterbrightBlue.toSql(brightBlue.value),
      );
    }
    if (brightPurple.present) {
      map['bright_purple'] = Variable<int>(
        CustomTerminalThemes.$converterbrightPurple.toSql(brightPurple.value),
      );
    }
    if (brightCyan.present) {
      map['bright_cyan'] = Variable<int>(
        CustomTerminalThemes.$converterbrightCyan.toSql(brightCyan.value),
      );
    }
    if (brightWhite.present) {
      map['bright_white'] = Variable<int>(
        CustomTerminalThemes.$converterbrightWhite.toSql(brightWhite.value),
      );
    }
    if (background.present) {
      map['background'] = Variable<int>(
        CustomTerminalThemes.$converterbackground.toSql(background.value),
      );
    }
    if (foreground.present) {
      map['foreground'] = Variable<int>(
        CustomTerminalThemes.$converterforeground.toSql(foreground.value),
      );
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(
        CustomTerminalThemes.$convertercursor.toSql(cursor.value),
      );
    }
    if (cursorText.present) {
      map['cursor_text'] = Variable<int>(
        CustomTerminalThemes.$convertercursorText.toSql(cursorText.value),
      );
    }
    if (selectionBackground.present) {
      map['selection_background'] = Variable<int>(
        CustomTerminalThemes.$converterselectionBackground.toSql(
          selectionBackground.value,
        ),
      );
    }
    if (selectionForeground.present) {
      map['selection_foreground'] = Variable<int>(
        CustomTerminalThemes.$converterselectionForeground.toSql(
          selectionForeground.value,
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
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('black: $black, ')
          ..write('red: $red, ')
          ..write('green: $green, ')
          ..write('yellow: $yellow, ')
          ..write('blue: $blue, ')
          ..write('purple: $purple, ')
          ..write('cyan: $cyan, ')
          ..write('white: $white, ')
          ..write('brightBlack: $brightBlack, ')
          ..write('brightRed: $brightRed, ')
          ..write('brightGreen: $brightGreen, ')
          ..write('brightYellow: $brightYellow, ')
          ..write('brightBlue: $brightBlue, ')
          ..write('brightPurple: $brightPurple, ')
          ..write('brightCyan: $brightCyan, ')
          ..write('brightWhite: $brightWhite, ')
          ..write('background: $background, ')
          ..write('foreground: $foreground, ')
          ..write('cursor: $cursor, ')
          ..write('cursorText: $cursorText, ')
          ..write('selectionBackground: $selectionBackground, ')
          ..write('selectionForeground: $selectionForeground, ')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _vaultIdMeta = const VerificationMeta(
    'vaultId',
  );
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES vaults(id)ON DELETE CASCADE',
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
  late final GeneratedColumn<String> identityId = GeneratedColumn<String>(
    'identity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  late final GeneratedColumnWithTypeConverter<ConnectionIcons, int> icon =
      GeneratedColumn<int>(
        'icon',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT \'unknown\'',
        defaultValue: const CustomExpression('\'unknown\''),
      ).withConverter<ConnectionIcons>(Connections.$convertericon);
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
  late final GeneratedColumn<String> terminalThemeOverrideId =
      GeneratedColumn<String>(
        'terminal_theme_override_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints:
            'REFERENCES custom_terminal_themes(id)ON DELETE SET NULL',
      );
  static const VerificationMeta _usesDefaultThemeOverrideMeta =
      const VerificationMeta('usesDefaultThemeOverride');
  late final GeneratedColumn<bool> usesDefaultThemeOverride =
      GeneratedColumn<bool>(
        'uses_default_theme_override',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT FALSE',
        defaultValue: const CustomExpression('FALSE'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vaultId,
    label,
    address,
    port,
    identityId,
    username,
    groupName,
    icon,
    iconColor,
    iconBackgroundColor,
    terminalTypographyOverride,
    terminalThemeOverrideId,
    usesDefaultThemeOverride,
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
    if (data.containsKey('vault_id')) {
      context.handle(
        _vaultIdMeta,
        vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
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
    if (data.containsKey('terminal_theme_override_id')) {
      context.handle(
        _terminalThemeOverrideIdMeta,
        terminalThemeOverrideId.isAcceptableOrUnknown(
          data['terminal_theme_override_id']!,
          _terminalThemeOverrideIdMeta,
        ),
      );
    }
    if (data.containsKey('uses_default_theme_override')) {
      context.handle(
        _usesDefaultThemeOverrideMeta,
        usesDefaultThemeOverride.isAcceptableOrUnknown(
          data['uses_default_theme_override']!,
          _usesDefaultThemeOverrideMeta,
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vaultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_id'],
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
        DriftSqlType.string,
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
      terminalTypographyOverride: Connections
          .$converterterminalTypographyOverriden
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}terminal_typography_override'],
            ),
          ),
      terminalThemeOverrideId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terminal_theme_override_id'],
      ),
      usesDefaultThemeOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uses_default_theme_override'],
      )!,
    );
  }

  @override
  Connections createAlias(String alias) {
    return Connections(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ConnectionIcons, int, int> $convertericon =
      const EnumIndexConverter<ConnectionIcons>(ConnectionIcons.values);
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
  bool get dontWriteConstraints => true;
}

class Connection extends DataClass implements Insertable<Connection> {
  final String id;
  final String vaultId;
  final String label;
  final String address;
  final int port;
  final String? identityId;
  final String? username;
  final String? groupName;
  final ConnectionIcons icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final TerminalTypography? terminalTypographyOverride;
  final String? terminalThemeOverrideId;
  final bool usesDefaultThemeOverride;
  const Connection({
    required this.id,
    required this.vaultId,
    required this.label,
    required this.address,
    required this.port,
    this.identityId,
    this.username,
    this.groupName,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.terminalTypographyOverride,
    this.terminalThemeOverrideId,
    required this.usesDefaultThemeOverride,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<String>(vaultId);
    map['label'] = Variable<String>(label);
    map['address'] = Variable<String>(address);
    map['port'] = Variable<int>(port);
    if (!nullToAbsent || identityId != null) {
      map['identity_id'] = Variable<String>(identityId);
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
    if (!nullToAbsent || terminalTypographyOverride != null) {
      map['terminal_typography_override'] = Variable<String>(
        Connections.$converterterminalTypographyOverriden.toSql(
          terminalTypographyOverride,
        ),
      );
    }
    if (!nullToAbsent || terminalThemeOverrideId != null) {
      map['terminal_theme_override_id'] = Variable<String>(
        terminalThemeOverrideId,
      );
    }
    map['uses_default_theme_override'] = Variable<bool>(
      usesDefaultThemeOverride,
    );
    return map;
  }

  ConnectionsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionsCompanion(
      id: Value(id),
      vaultId: Value(vaultId),
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
      terminalTypographyOverride:
          terminalTypographyOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(terminalTypographyOverride),
      terminalThemeOverrideId: terminalThemeOverrideId == null && nullToAbsent
          ? const Value.absent()
          : Value(terminalThemeOverrideId),
      usesDefaultThemeOverride: Value(usesDefaultThemeOverride),
    );
  }

  factory Connection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Connection(
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<String>(json['vault_id']),
      label: serializer.fromJson<String>(json['label']),
      address: serializer.fromJson<String>(json['address']),
      port: serializer.fromJson<int>(json['port']),
      identityId: serializer.fromJson<String?>(json['identity_id']),
      username: serializer.fromJson<String?>(json['username']),
      groupName: serializer.fromJson<String?>(json['group_name']),
      icon: Connections.$convertericon.fromJson(
        serializer.fromJson<int>(json['icon']),
      ),
      iconColor: serializer.fromJson<Color>(json['icon_color']),
      iconBackgroundColor: serializer.fromJson<Color>(
        json['icon_background_color'],
      ),
      terminalTypographyOverride: serializer.fromJson<TerminalTypography?>(
        json['terminal_typography_override'],
      ),
      terminalThemeOverrideId: serializer.fromJson<String?>(
        json['terminal_theme_override_id'],
      ),
      usesDefaultThemeOverride: serializer.fromJson<bool>(
        json['uses_default_theme_override'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vault_id': serializer.toJson<String>(vaultId),
      'label': serializer.toJson<String>(label),
      'address': serializer.toJson<String>(address),
      'port': serializer.toJson<int>(port),
      'identity_id': serializer.toJson<String?>(identityId),
      'username': serializer.toJson<String?>(username),
      'group_name': serializer.toJson<String?>(groupName),
      'icon': serializer.toJson<int>(Connections.$convertericon.toJson(icon)),
      'icon_color': serializer.toJson<Color>(iconColor),
      'icon_background_color': serializer.toJson<Color>(iconBackgroundColor),
      'terminal_typography_override': serializer.toJson<TerminalTypography?>(
        terminalTypographyOverride,
      ),
      'terminal_theme_override_id': serializer.toJson<String?>(
        terminalThemeOverrideId,
      ),
      'uses_default_theme_override': serializer.toJson<bool>(
        usesDefaultThemeOverride,
      ),
    };
  }

  Connection copyWith({
    String? id,
    String? vaultId,
    String? label,
    String? address,
    int? port,
    Value<String?> identityId = const Value.absent(),
    Value<String?> username = const Value.absent(),
    Value<String?> groupName = const Value.absent(),
    ConnectionIcons? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    Value<TerminalTypography?> terminalTypographyOverride =
        const Value.absent(),
    Value<String?> terminalThemeOverrideId = const Value.absent(),
    bool? usesDefaultThemeOverride,
  }) => Connection(
    id: id ?? this.id,
    vaultId: vaultId ?? this.vaultId,
    label: label ?? this.label,
    address: address ?? this.address,
    port: port ?? this.port,
    identityId: identityId.present ? identityId.value : this.identityId,
    username: username.present ? username.value : this.username,
    groupName: groupName.present ? groupName.value : this.groupName,
    icon: icon ?? this.icon,
    iconColor: iconColor ?? this.iconColor,
    iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
    terminalTypographyOverride: terminalTypographyOverride.present
        ? terminalTypographyOverride.value
        : this.terminalTypographyOverride,
    terminalThemeOverrideId: terminalThemeOverrideId.present
        ? terminalThemeOverrideId.value
        : this.terminalThemeOverrideId,
    usesDefaultThemeOverride:
        usesDefaultThemeOverride ?? this.usesDefaultThemeOverride,
  );
  Connection copyWithCompanion(ConnectionsCompanion data) {
    return Connection(
      id: data.id.present ? data.id.value : this.id,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
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
      terminalTypographyOverride: data.terminalTypographyOverride.present
          ? data.terminalTypographyOverride.value
          : this.terminalTypographyOverride,
      terminalThemeOverrideId: data.terminalThemeOverrideId.present
          ? data.terminalThemeOverrideId.value
          : this.terminalThemeOverrideId,
      usesDefaultThemeOverride: data.usesDefaultThemeOverride.present
          ? data.usesDefaultThemeOverride.value
          : this.usesDefaultThemeOverride,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Connection(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('label: $label, ')
          ..write('address: $address, ')
          ..write('port: $port, ')
          ..write('identityId: $identityId, ')
          ..write('username: $username, ')
          ..write('groupName: $groupName, ')
          ..write('icon: $icon, ')
          ..write('iconColor: $iconColor, ')
          ..write('iconBackgroundColor: $iconBackgroundColor, ')
          ..write('terminalTypographyOverride: $terminalTypographyOverride, ')
          ..write('terminalThemeOverrideId: $terminalThemeOverrideId, ')
          ..write('usesDefaultThemeOverride: $usesDefaultThemeOverride')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vaultId,
    label,
    address,
    port,
    identityId,
    username,
    groupName,
    icon,
    iconColor,
    iconBackgroundColor,
    terminalTypographyOverride,
    terminalThemeOverrideId,
    usesDefaultThemeOverride,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Connection &&
          other.id == this.id &&
          other.vaultId == this.vaultId &&
          other.label == this.label &&
          other.address == this.address &&
          other.port == this.port &&
          other.identityId == this.identityId &&
          other.username == this.username &&
          other.groupName == this.groupName &&
          other.icon == this.icon &&
          other.iconColor == this.iconColor &&
          other.iconBackgroundColor == this.iconBackgroundColor &&
          other.terminalTypographyOverride == this.terminalTypographyOverride &&
          other.terminalThemeOverrideId == this.terminalThemeOverrideId &&
          other.usesDefaultThemeOverride == this.usesDefaultThemeOverride);
}

class ConnectionsCompanion extends UpdateCompanion<Connection> {
  final Value<String> id;
  final Value<String> vaultId;
  final Value<String> label;
  final Value<String> address;
  final Value<int> port;
  final Value<String?> identityId;
  final Value<String?> username;
  final Value<String?> groupName;
  final Value<ConnectionIcons> icon;
  final Value<Color> iconColor;
  final Value<Color> iconBackgroundColor;
  final Value<TerminalTypography?> terminalTypographyOverride;
  final Value<String?> terminalThemeOverrideId;
  final Value<bool> usesDefaultThemeOverride;
  final Value<int> rowid;
  const ConnectionsCompanion({
    this.id = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.label = const Value.absent(),
    this.address = const Value.absent(),
    this.port = const Value.absent(),
    this.identityId = const Value.absent(),
    this.username = const Value.absent(),
    this.groupName = const Value.absent(),
    this.icon = const Value.absent(),
    this.iconColor = const Value.absent(),
    this.iconBackgroundColor = const Value.absent(),
    this.terminalTypographyOverride = const Value.absent(),
    this.terminalThemeOverrideId = const Value.absent(),
    this.usesDefaultThemeOverride = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConnectionsCompanion.insert({
    this.id = const Value.absent(),
    required String vaultId,
    required String label,
    required String address,
    required int port,
    this.identityId = const Value.absent(),
    this.username = const Value.absent(),
    this.groupName = const Value.absent(),
    this.icon = const Value.absent(),
    required Color iconColor,
    required Color iconBackgroundColor,
    this.terminalTypographyOverride = const Value.absent(),
    this.terminalThemeOverrideId = const Value.absent(),
    this.usesDefaultThemeOverride = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : vaultId = Value(vaultId),
       label = Value(label),
       address = Value(address),
       port = Value(port),
       iconColor = Value(iconColor),
       iconBackgroundColor = Value(iconBackgroundColor);
  static Insertable<Connection> custom({
    Expression<String>? id,
    Expression<String>? vaultId,
    Expression<String>? label,
    Expression<String>? address,
    Expression<int>? port,
    Expression<String>? identityId,
    Expression<String>? username,
    Expression<String>? groupName,
    Expression<int>? icon,
    Expression<int>? iconColor,
    Expression<int>? iconBackgroundColor,
    Expression<String>? terminalTypographyOverride,
    Expression<String>? terminalThemeOverrideId,
    Expression<bool>? usesDefaultThemeOverride,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultId != null) 'vault_id': vaultId,
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
      if (terminalTypographyOverride != null)
        'terminal_typography_override': terminalTypographyOverride,
      if (terminalThemeOverrideId != null)
        'terminal_theme_override_id': terminalThemeOverrideId,
      if (usesDefaultThemeOverride != null)
        'uses_default_theme_override': usesDefaultThemeOverride,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConnectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? vaultId,
    Value<String>? label,
    Value<String>? address,
    Value<int>? port,
    Value<String?>? identityId,
    Value<String?>? username,
    Value<String?>? groupName,
    Value<ConnectionIcons>? icon,
    Value<Color>? iconColor,
    Value<Color>? iconBackgroundColor,
    Value<TerminalTypography?>? terminalTypographyOverride,
    Value<String?>? terminalThemeOverrideId,
    Value<bool>? usesDefaultThemeOverride,
    Value<int>? rowid,
  }) {
    return ConnectionsCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      label: label ?? this.label,
      address: address ?? this.address,
      port: port ?? this.port,
      identityId: identityId ?? this.identityId,
      username: username ?? this.username,
      groupName: groupName ?? this.groupName,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      terminalTypographyOverride:
          terminalTypographyOverride ?? this.terminalTypographyOverride,
      terminalThemeOverrideId:
          terminalThemeOverrideId ?? this.terminalThemeOverrideId,
      usesDefaultThemeOverride:
          usesDefaultThemeOverride ?? this.usesDefaultThemeOverride,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<String>(vaultId.value);
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
      map['identity_id'] = Variable<String>(identityId.value);
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
    if (terminalTypographyOverride.present) {
      map['terminal_typography_override'] = Variable<String>(
        Connections.$converterterminalTypographyOverriden.toSql(
          terminalTypographyOverride.value,
        ),
      );
    }
    if (terminalThemeOverrideId.present) {
      map['terminal_theme_override_id'] = Variable<String>(
        terminalThemeOverrideId.value,
      );
    }
    if (usesDefaultThemeOverride.present) {
      map['uses_default_theme_override'] = Variable<bool>(
        usesDefaultThemeOverride.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionsCompanion(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('label: $label, ')
          ..write('address: $address, ')
          ..write('port: $port, ')
          ..write('identityId: $identityId, ')
          ..write('username: $username, ')
          ..write('groupName: $groupName, ')
          ..write('icon: $icon, ')
          ..write('iconColor: $iconColor, ')
          ..write('iconBackgroundColor: $iconBackgroundColor, ')
          ..write('terminalTypographyOverride: $terminalTypographyOverride, ')
          ..write('terminalThemeOverrideId: $terminalThemeOverrideId, ')
          ..write('usesDefaultThemeOverride: $usesDefaultThemeOverride, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _vaultIdMeta = const VerificationMeta(
    'vaultId',
  );
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES vaults(id)ON DELETE CASCADE',
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
  static const VerificationMeta _privateKeyMeta = const VerificationMeta(
    'privateKey',
  );
  late final GeneratedColumn<String> privateKey = GeneratedColumn<String>(
    'private_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
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
  List<GeneratedColumn> get $columns => [
    id,
    vaultId,
    label,
    privateKey,
    publicKey,
    passphrase,
  ];
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
    if (data.containsKey('vault_id')) {
      context.handle(
        _vaultIdMeta,
        vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('private_key')) {
      context.handle(
        _privateKeyMeta,
        privateKey.isAcceptableOrUnknown(data['private_key']!, _privateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_privateKeyMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vaultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      privateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}private_key'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      ),
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
  final String id;
  final String vaultId;
  final String label;
  final String privateKey;
  final String? publicKey;
  final String? passphrase;
  const Key({
    required this.id,
    required this.vaultId,
    required this.label,
    required this.privateKey,
    this.publicKey,
    this.passphrase,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<String>(vaultId);
    map['label'] = Variable<String>(label);
    map['private_key'] = Variable<String>(privateKey);
    if (!nullToAbsent || publicKey != null) {
      map['public_key'] = Variable<String>(publicKey);
    }
    if (!nullToAbsent || passphrase != null) {
      map['passphrase'] = Variable<String>(passphrase);
    }
    return map;
  }

  KeysCompanion toCompanion(bool nullToAbsent) {
    return KeysCompanion(
      id: Value(id),
      vaultId: Value(vaultId),
      label: Value(label),
      privateKey: Value(privateKey),
      publicKey: publicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKey),
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
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<String>(json['vault_id']),
      label: serializer.fromJson<String>(json['label']),
      privateKey: serializer.fromJson<String>(json['private_key']),
      publicKey: serializer.fromJson<String?>(json['public_key']),
      passphrase: serializer.fromJson<String?>(json['passphrase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vault_id': serializer.toJson<String>(vaultId),
      'label': serializer.toJson<String>(label),
      'private_key': serializer.toJson<String>(privateKey),
      'public_key': serializer.toJson<String?>(publicKey),
      'passphrase': serializer.toJson<String?>(passphrase),
    };
  }

  Key copyWith({
    String? id,
    String? vaultId,
    String? label,
    String? privateKey,
    Value<String?> publicKey = const Value.absent(),
    Value<String?> passphrase = const Value.absent(),
  }) => Key(
    id: id ?? this.id,
    vaultId: vaultId ?? this.vaultId,
    label: label ?? this.label,
    privateKey: privateKey ?? this.privateKey,
    publicKey: publicKey.present ? publicKey.value : this.publicKey,
    passphrase: passphrase.present ? passphrase.value : this.passphrase,
  );
  Key copyWithCompanion(KeysCompanion data) {
    return Key(
      id: data.id.present ? data.id.value : this.id,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      label: data.label.present ? data.label.value : this.label,
      privateKey: data.privateKey.present
          ? data.privateKey.value
          : this.privateKey,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      passphrase: data.passphrase.present
          ? data.passphrase.value
          : this.passphrase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Key(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('label: $label, ')
          ..write('privateKey: $privateKey, ')
          ..write('publicKey: $publicKey, ')
          ..write('passphrase: $passphrase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vaultId, label, privateKey, publicKey, passphrase);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Key &&
          other.id == this.id &&
          other.vaultId == this.vaultId &&
          other.label == this.label &&
          other.privateKey == this.privateKey &&
          other.publicKey == this.publicKey &&
          other.passphrase == this.passphrase);
}

class KeysCompanion extends UpdateCompanion<Key> {
  final Value<String> id;
  final Value<String> vaultId;
  final Value<String> label;
  final Value<String> privateKey;
  final Value<String?> publicKey;
  final Value<String?> passphrase;
  final Value<int> rowid;
  const KeysCompanion({
    this.id = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.label = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.passphrase = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeysCompanion.insert({
    this.id = const Value.absent(),
    required String vaultId,
    required String label,
    required String privateKey,
    this.publicKey = const Value.absent(),
    this.passphrase = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : vaultId = Value(vaultId),
       label = Value(label),
       privateKey = Value(privateKey);
  static Insertable<Key> custom({
    Expression<String>? id,
    Expression<String>? vaultId,
    Expression<String>? label,
    Expression<String>? privateKey,
    Expression<String>? publicKey,
    Expression<String>? passphrase,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultId != null) 'vault_id': vaultId,
      if (label != null) 'label': label,
      if (privateKey != null) 'private_key': privateKey,
      if (publicKey != null) 'public_key': publicKey,
      if (passphrase != null) 'passphrase': passphrase,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeysCompanion copyWith({
    Value<String>? id,
    Value<String>? vaultId,
    Value<String>? label,
    Value<String>? privateKey,
    Value<String?>? publicKey,
    Value<String?>? passphrase,
    Value<int>? rowid,
  }) {
    return KeysCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      label: label ?? this.label,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      passphrase: passphrase ?? this.passphrase,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<String>(vaultId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (privateKey.present) {
      map['private_key'] = Variable<String>(privateKey.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (passphrase.present) {
      map['passphrase'] = Variable<String>(passphrase.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeysCompanion(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('label: $label, ')
          ..write('privateKey: $privateKey, ')
          ..write('publicKey: $publicKey, ')
          ..write('passphrase: $passphrase, ')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _vaultIdMeta = const VerificationMeta(
    'vaultId',
  );
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES vaults(id)ON DELETE CASCADE',
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
  late final GeneratedColumn<String> keyId = GeneratedColumn<String>(
    'key_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    $customConstraints: 'CONSTRAINT password_or_key_id CHECK ((type = \'password\' AND password IS NOT NULL AND key_id IS NULL)OR(type = \'key\' AND key_id IS NOT NULL AND password IS NULL))',
  );
  @override
  List<GeneratedColumn> get $columns => [id, vaultId, type, keyId, password];
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
    if (data.containsKey('vault_id')) {
      context.handle(
        _vaultIdMeta,
        vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vaultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_id'],
      )!,
      type: Credentials.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      keyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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
  final String id;
  final String vaultId;
  final CredentialType type;
  final String? keyId;
  final String? password;
  const Credential({
    required this.id,
    required this.vaultId,
    required this.type,
    this.keyId,
    this.password,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<String>(vaultId);
    {
      map['type'] = Variable<String>(Credentials.$convertertype.toSql(type));
    }
    if (!nullToAbsent || keyId != null) {
      map['key_id'] = Variable<String>(keyId);
    }
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    return map;
  }

  CredentialsCompanion toCompanion(bool nullToAbsent) {
    return CredentialsCompanion(
      id: Value(id),
      vaultId: Value(vaultId),
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
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<String>(json['vault_id']),
      type: Credentials.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      keyId: serializer.fromJson<String?>(json['key_id']),
      password: serializer.fromJson<String?>(json['password']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vault_id': serializer.toJson<String>(vaultId),
      'type': serializer.toJson<String>(
        Credentials.$convertertype.toJson(type),
      ),
      'key_id': serializer.toJson<String?>(keyId),
      'password': serializer.toJson<String?>(password),
    };
  }

  Credential copyWith({
    String? id,
    String? vaultId,
    CredentialType? type,
    Value<String?> keyId = const Value.absent(),
    Value<String?> password = const Value.absent(),
  }) => Credential(
    id: id ?? this.id,
    vaultId: vaultId ?? this.vaultId,
    type: type ?? this.type,
    keyId: keyId.present ? keyId.value : this.keyId,
    password: password.present ? password.value : this.password,
  );
  Credential copyWithCompanion(CredentialsCompanion data) {
    return Credential(
      id: data.id.present ? data.id.value : this.id,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      type: data.type.present ? data.type.value : this.type,
      keyId: data.keyId.present ? data.keyId.value : this.keyId,
      password: data.password.present ? data.password.value : this.password,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Credential(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('type: $type, ')
          ..write('keyId: $keyId, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vaultId, type, keyId, password);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Credential &&
          other.id == this.id &&
          other.vaultId == this.vaultId &&
          other.type == this.type &&
          other.keyId == this.keyId &&
          other.password == this.password);
}

class CredentialsCompanion extends UpdateCompanion<Credential> {
  final Value<String> id;
  final Value<String> vaultId;
  final Value<CredentialType> type;
  final Value<String?> keyId;
  final Value<String?> password;
  final Value<int> rowid;
  const CredentialsCompanion({
    this.id = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.type = const Value.absent(),
    this.keyId = const Value.absent(),
    this.password = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CredentialsCompanion.insert({
    this.id = const Value.absent(),
    required String vaultId,
    required CredentialType type,
    this.keyId = const Value.absent(),
    this.password = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : vaultId = Value(vaultId),
       type = Value(type);
  static Insertable<Credential> custom({
    Expression<String>? id,
    Expression<String>? vaultId,
    Expression<String>? type,
    Expression<String>? keyId,
    Expression<String>? password,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultId != null) 'vault_id': vaultId,
      if (type != null) 'type': type,
      if (keyId != null) 'key_id': keyId,
      if (password != null) 'password': password,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CredentialsCompanion copyWith({
    Value<String>? id,
    Value<String>? vaultId,
    Value<CredentialType>? type,
    Value<String?>? keyId,
    Value<String?>? password,
    Value<int>? rowid,
  }) {
    return CredentialsCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      type: type ?? this.type,
      keyId: keyId ?? this.keyId,
      password: password ?? this.password,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<String>(vaultId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        Credentials.$convertertype.toSql(type.value),
      );
    }
    if (keyId.present) {
      map['key_id'] = Variable<String>(keyId.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CredentialsCompanion(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('type: $type, ')
          ..write('keyId: $keyId, ')
          ..write('password: $password, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class KnownHosts extends Table with TableInfo<KnownHosts, KnownHost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  KnownHosts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _vaultIdMeta = const VerificationMeta(
    'vaultId',
  );
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES vaults(id)ON DELETE CASCADE',
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
  List<GeneratedColumn> get $columns => [id, vaultId, host, hostKey, createdAt];
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
    if (data.containsKey('vault_id')) {
      context.handle(
        _vaultIdMeta,
        vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vaultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_id'],
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
  final String id;
  final String vaultId;
  final String host;
  final Uint8List hostKey;
  final DateTime createdAt;
  const KnownHost({
    required this.id,
    required this.vaultId,
    required this.host,
    required this.hostKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<String>(vaultId);
    map['host'] = Variable<String>(host);
    map['hostKey'] = Variable<Uint8List>(hostKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  KnownHostsCompanion toCompanion(bool nullToAbsent) {
    return KnownHostsCompanion(
      id: Value(id),
      vaultId: Value(vaultId),
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
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<String>(json['vault_id']),
      host: serializer.fromJson<String>(json['host']),
      hostKey: serializer.fromJson<Uint8List>(json['hostKey']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vault_id': serializer.toJson<String>(vaultId),
      'host': serializer.toJson<String>(host),
      'hostKey': serializer.toJson<Uint8List>(hostKey),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  KnownHost copyWith({
    String? id,
    String? vaultId,
    String? host,
    Uint8List? hostKey,
    DateTime? createdAt,
  }) => KnownHost(
    id: id ?? this.id,
    vaultId: vaultId ?? this.vaultId,
    host: host ?? this.host,
    hostKey: hostKey ?? this.hostKey,
    createdAt: createdAt ?? this.createdAt,
  );
  KnownHost copyWithCompanion(KnownHostsCompanion data) {
    return KnownHost(
      id: data.id.present ? data.id.value : this.id,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      host: data.host.present ? data.host.value : this.host,
      hostKey: data.hostKey.present ? data.hostKey.value : this.hostKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KnownHost(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('host: $host, ')
          ..write('hostKey: $hostKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vaultId,
    host,
    $driftBlobEquality.hash(hostKey),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KnownHost &&
          other.id == this.id &&
          other.vaultId == this.vaultId &&
          other.host == this.host &&
          $driftBlobEquality.equals(other.hostKey, this.hostKey) &&
          other.createdAt == this.createdAt);
}

class KnownHostsCompanion extends UpdateCompanion<KnownHost> {
  final Value<String> id;
  final Value<String> vaultId;
  final Value<String> host;
  final Value<Uint8List> hostKey;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const KnownHostsCompanion({
    this.id = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.host = const Value.absent(),
    this.hostKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KnownHostsCompanion.insert({
    this.id = const Value.absent(),
    required String vaultId,
    required String host,
    required Uint8List hostKey,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : vaultId = Value(vaultId),
       host = Value(host),
       hostKey = Value(hostKey);
  static Insertable<KnownHost> custom({
    Expression<String>? id,
    Expression<String>? vaultId,
    Expression<String>? host,
    Expression<Uint8List>? hostKey,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultId != null) 'vault_id': vaultId,
      if (host != null) 'host': host,
      if (hostKey != null) 'hostKey': hostKey,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KnownHostsCompanion copyWith({
    Value<String>? id,
    Value<String>? vaultId,
    Value<String>? host,
    Value<Uint8List>? hostKey,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return KnownHostsCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      host: host ?? this.host,
      hostKey: hostKey ?? this.hostKey,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<String>(vaultId.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KnownHostsCompanion(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('host: $host, ')
          ..write('hostKey: $hostKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> identityId = GeneratedColumn<String>(
    'identity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES identities(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _credentialIdMeta = const VerificationMeta(
    'credentialId',
  );
  late final GeneratedColumn<String> credentialId = GeneratedColumn<String>(
    'credential_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
        DriftSqlType.string,
        data['${effectivePrefix}identity_id'],
      )!,
      credentialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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
  final String identityId;
  final String credentialId;
  const IdentityCredential({
    required this.identityId,
    required this.credentialId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['identity_id'] = Variable<String>(identityId);
    map['credential_id'] = Variable<String>(credentialId);
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
      identityId: serializer.fromJson<String>(json['identity_id']),
      credentialId: serializer.fromJson<String>(json['credential_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identity_id': serializer.toJson<String>(identityId),
      'credential_id': serializer.toJson<String>(credentialId),
    };
  }

  IdentityCredential copyWith({String? identityId, String? credentialId}) =>
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
  final Value<String> identityId;
  final Value<String> credentialId;
  final Value<int> rowid;
  const IdentityCredentialsCompanion({
    this.identityId = const Value.absent(),
    this.credentialId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdentityCredentialsCompanion.insert({
    required String identityId,
    required String credentialId,
    this.rowid = const Value.absent(),
  }) : identityId = Value(identityId),
       credentialId = Value(credentialId);
  static Insertable<IdentityCredential> custom({
    Expression<String>? identityId,
    Expression<String>? credentialId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (identityId != null) 'identity_id': identityId,
      if (credentialId != null) 'credential_id': credentialId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdentityCredentialsCompanion copyWith({
    Value<String>? identityId,
    Value<String>? credentialId,
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
      map['identity_id'] = Variable<String>(identityId.value);
    }
    if (credentialId.present) {
      map['credential_id'] = Variable<String>(credentialId.value);
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

class ConnectionCredentials extends Table
    with TableInfo<ConnectionCredentials, ConnectionCredential> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ConnectionCredentials(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES connections(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _credentialIdMeta = const VerificationMeta(
    'credentialId',
  );
  late final GeneratedColumn<String> credentialId = GeneratedColumn<String>(
    'credential_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      credentialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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
  final String connectionId;
  final String credentialId;
  const ConnectionCredential({
    required this.connectionId,
    required this.credentialId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['connection_id'] = Variable<String>(connectionId);
    map['credential_id'] = Variable<String>(credentialId);
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
      connectionId: serializer.fromJson<String>(json['connection_id']),
      credentialId: serializer.fromJson<String>(json['credential_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'connection_id': serializer.toJson<String>(connectionId),
      'credential_id': serializer.toJson<String>(credentialId),
    };
  }

  ConnectionCredential copyWith({String? connectionId, String? credentialId}) =>
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
  final Value<String> connectionId;
  final Value<String> credentialId;
  final Value<int> rowid;
  const ConnectionCredentialsCompanion({
    this.connectionId = const Value.absent(),
    this.credentialId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConnectionCredentialsCompanion.insert({
    required String connectionId,
    required String credentialId,
    this.rowid = const Value.absent(),
  }) : connectionId = Value(connectionId),
       credentialId = Value(credentialId);
  static Insertable<ConnectionCredential> custom({
    Expression<String>? connectionId,
    Expression<String>? credentialId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (connectionId != null) 'connection_id': connectionId,
      if (credentialId != null) 'credential_id': credentialId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConnectionCredentialsCompanion copyWith({
    Value<String>? connectionId,
    Value<String>? credentialId,
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
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (credentialId.present) {
      map['credential_id'] = Variable<String>(credentialId.value);
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
  late final Vaults vaults = Vaults(this);
  late final Identities identities = Identities(this);
  late final CustomTerminalThemes customTerminalThemes = CustomTerminalThemes(
    this,
  );
  late final Connections connections = Connections(this);
  late final Keys keys = Keys(this);
  late final Credentials credentials = Credentials(this);
  late final KnownHosts knownHosts = KnownHosts(this);
  late final IdentityCredentials identityCredentials = IdentityCredentials(
    this,
  );
  late final ConnectionCredentials connectionCredentials =
      ConnectionCredentials(this);
  Future<int> clearConnectionsByVaultId(String vaultId) {
    return customUpdate(
      'DELETE FROM connections WHERE vault_id = ?1',
      variables: [Variable<String>(vaultId)],
      updates: {connections},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> clearIdentitiesByVaultId(String vaultId) {
    return customUpdate(
      'DELETE FROM identities WHERE vault_id = ?1',
      variables: [Variable<String>(vaultId)],
      updates: {identities},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> clearCredentialsByVaultId(String vaultId) {
    return customUpdate(
      'DELETE FROM credentials WHERE vault_id = ?1',
      variables: [Variable<String>(vaultId)],
      updates: {credentials},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> clearKeysByVaultId(String vaultId) {
    return customUpdate(
      'DELETE FROM keys WHERE vault_id = ?1',
      variables: [Variable<String>(vaultId)],
      updates: {keys},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> clearKnownHostsByVaultId(String vaultId) {
    return customUpdate(
      'DELETE FROM known_hosts WHERE vault_id = ?1',
      variables: [Variable<String>(vaultId)],
      updates: {knownHosts},
      updateKind: UpdateKind.delete,
    );
  }

  Future<int> createOrUpdateKnownHost(
    String id,
    String vaultId,
    String host,
    Uint8List hostKey,
    DateTime createdAt,
  ) {
    return customInsert(
      'INSERT INTO known_hosts (id, vault_id, host, hostKey, created_at) VALUES (?1, ?2, ?3, ?4, ?5) ON CONFLICT (id) DO UPDATE SET vault_id = excluded.vault_id, host = excluded.host, hostKey = excluded.hostKey, created_at = excluded.created_at',
      variables: [
        Variable<String>(id),
        Variable<String>(vaultId),
        Variable<String>(host),
        Variable<Uint8List>(hostKey),
        Variable<DateTime>(createdAt),
      ],
      updates: {knownHosts},
    );
  }

  Selectable<FindAllKnownHostsFullResult> findAllKnownHostsFull(
    String vaultId,
  ) {
    return customSelect(
      'SELECT"k"."id" AS "nested_0.id", "k"."vault_id" AS "nested_0.vault_id", "k"."host" AS "nested_0.host", "k"."hostKey" AS "nested_0.hostKey", "k"."created_at" AS "nested_0.created_at","v"."id" AS "nested_1.id", "v"."owner" AS "nested_1.owner" FROM known_hosts AS k INNER JOIN vaults AS v ON k.vault_id = v.id WHERE ?1 = \'\' OR k.vault_id = ?1',
      variables: [Variable<String>(vaultId)],
      readsFrom: {knownHosts, vaults},
    ).asyncMap(
      (QueryRow row) async => FindAllKnownHostsFullResult(
        knownHost: await knownHosts.mapFromRow(row, tablePrefix: 'nested_0'),
        vault: await vaults.mapFromRow(row, tablePrefix: 'nested_1'),
      ),
    );
  }

  Selectable<KnownHost> findKnownHostByHost(String var1) {
    return customSelect(
      'SELECT * FROM known_hosts WHERE host = ?1',
      variables: [Variable<String>(var1)],
      readsFrom: {knownHosts},
    ).asyncMap(knownHosts.mapFromRow);
  }

  Future<int> createOrUpdateCustomColorScheme(
    String id,
    String name,
    Color blackColor,
    Color redColor,
    Color greenColor,
    Color yellowColor,
    Color blueColor,
    Color purpleColor,
    Color cyanColor,
    Color whiteColor,
    Color brightBlackColor,
    Color brightRedColor,
    Color brightGreenColor,
    Color brightYellowColor,
    Color brightBlueColor,
    Color brightPurpleColor,
    Color brightCyanColor,
    Color brightWhiteColor,
    Color backgroundColor,
    Color foregroundColor,
    Color cursorColor,
    Color cursorTextColor,
    Color selectionBackgroundColor,
    Color selectionForegroundColor,
  ) {
    return customInsert(
      'INSERT INTO custom_terminal_themes (id, name, black, red, green, yellow, blue, purple, cyan, white, bright_black, bright_red, bright_green, bright_yellow, bright_blue, bright_purple, bright_cyan, bright_white, background, foreground, cursor, cursor_text, selection_background, selection_foreground) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16, ?17, ?18, ?19, ?20, ?21, ?22, ?23, ?24) ON CONFLICT (id) DO UPDATE SET name = excluded.name, black = excluded.black, red = excluded.red, green = excluded.green, yellow = excluded.yellow, blue = excluded.blue, purple = excluded.purple, cyan = excluded.cyan, white = excluded.white, bright_black = excluded.bright_black, bright_red = excluded.bright_red, bright_green = excluded.bright_green, bright_yellow = excluded.bright_yellow, bright_blue = excluded.bright_blue, bright_purple = excluded.bright_purple, bright_cyan = excluded.bright_cyan, bright_white = excluded.bright_white, background = excluded.background, foreground = excluded.foreground, cursor = excluded.cursor, cursor_text = excluded.cursor_text, selection_background = excluded.selection_background, selection_foreground = excluded.selection_foreground',
      variables: [
        Variable<String>(id),
        Variable<String>(name),
        Variable<int>(CustomTerminalThemes.$converterblack.toSql(blackColor)),
        Variable<int>(CustomTerminalThemes.$converterred.toSql(redColor)),
        Variable<int>(CustomTerminalThemes.$convertergreen.toSql(greenColor)),
        Variable<int>(CustomTerminalThemes.$converteryellow.toSql(yellowColor)),
        Variable<int>(CustomTerminalThemes.$converterblue.toSql(blueColor)),
        Variable<int>(CustomTerminalThemes.$converterpurple.toSql(purpleColor)),
        Variable<int>(CustomTerminalThemes.$convertercyan.toSql(cyanColor)),
        Variable<int>(CustomTerminalThemes.$converterwhite.toSql(whiteColor)),
        Variable<int>(
          CustomTerminalThemes.$converterbrightBlack.toSql(brightBlackColor),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightRed.toSql(brightRedColor),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightGreen.toSql(brightGreenColor),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightYellow.toSql(brightYellowColor),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightBlue.toSql(brightBlueColor),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightPurple.toSql(brightPurpleColor),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightCyan.toSql(brightCyanColor),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightWhite.toSql(brightWhiteColor),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbackground.toSql(backgroundColor),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterforeground.toSql(foregroundColor),
        ),
        Variable<int>(CustomTerminalThemes.$convertercursor.toSql(cursorColor)),
        Variable<int>(
          CustomTerminalThemes.$convertercursorText.toSql(cursorTextColor),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterselectionBackground.toSql(
            selectionBackgroundColor,
          ),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterselectionForeground.toSql(
            selectionForegroundColor,
          ),
        ),
      ],
      updates: {customTerminalThemes},
    );
  }

  Selectable<CustomTerminalTheme> findAllCustomColorSchemesByIds(
    List<String> var1,
  ) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT * FROM custom_terminal_themes WHERE id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<String>($)],
      readsFrom: {customTerminalThemes},
    ).asyncMap(customTerminalThemes.mapFromRow);
  }

  Selectable<String> findMatchingCustomColorSchemeId(
    String name,
    Color black,
    Color red,
    Color green,
    Color yellow,
    Color blue,
    Color purple,
    Color cyan,
    Color white,
    Color brightBlack,
    Color brightRed,
    Color brightGreen,
    Color brightYellow,
    Color brightBlue,
    Color brightPurple,
    Color brightCyan,
    Color brightWhite,
    Color background,
    Color foreground,
    Color cursor,
    Color cursorText,
    Color selectionBackground,
    Color selectionForeground,
  ) {
    return customSelect(
      'SELECT id FROM custom_terminal_themes WHERE name = ?1 AND black = ?2 AND red = ?3 AND green = ?4 AND yellow = ?5 AND blue = ?6 AND purple = ?7 AND cyan = ?8 AND white = ?9 AND bright_black = ?10 AND bright_red = ?11 AND bright_green = ?12 AND bright_yellow = ?13 AND bright_blue = ?14 AND bright_purple = ?15 AND bright_cyan = ?16 AND bright_white = ?17 AND background = ?18 AND foreground = ?19 AND cursor = ?20 AND cursor_text = ?21 AND selection_background = ?22 AND selection_foreground = ?23 LIMIT 1',
      variables: [
        Variable<String>(name),
        Variable<int>(CustomTerminalThemes.$converterblack.toSql(black)),
        Variable<int>(CustomTerminalThemes.$converterred.toSql(red)),
        Variable<int>(CustomTerminalThemes.$convertergreen.toSql(green)),
        Variable<int>(CustomTerminalThemes.$converteryellow.toSql(yellow)),
        Variable<int>(CustomTerminalThemes.$converterblue.toSql(blue)),
        Variable<int>(CustomTerminalThemes.$converterpurple.toSql(purple)),
        Variable<int>(CustomTerminalThemes.$convertercyan.toSql(cyan)),
        Variable<int>(CustomTerminalThemes.$converterwhite.toSql(white)),
        Variable<int>(
          CustomTerminalThemes.$converterbrightBlack.toSql(brightBlack),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightRed.toSql(brightRed),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightGreen.toSql(brightGreen),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightYellow.toSql(brightYellow),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightBlue.toSql(brightBlue),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightPurple.toSql(brightPurple),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightCyan.toSql(brightCyan),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbrightWhite.toSql(brightWhite),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterbackground.toSql(background),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterforeground.toSql(foreground),
        ),
        Variable<int>(CustomTerminalThemes.$convertercursor.toSql(cursor)),
        Variable<int>(
          CustomTerminalThemes.$convertercursorText.toSql(cursorText),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterselectionBackground.toSql(
            selectionBackground,
          ),
        ),
        Variable<int>(
          CustomTerminalThemes.$converterselectionForeground.toSql(
            selectionForeground,
          ),
        ),
      ],
      readsFrom: {customTerminalThemes},
    ).map((QueryRow row) => row.read<String>('id'));
  }

  Future<int> createOrUpdateKey(
    String id,
    String vaultId,
    String label,
    String privateKey,
    String? publicKey,
    String? passphrase,
  ) {
    return customInsert(
      'INSERT INTO keys (id, vault_id, label, private_key, public_key, passphrase) VALUES (?1, ?2, ?3, ?4, ?5, ?6) ON CONFLICT (id) DO UPDATE SET vault_id = excluded.vault_id, label = excluded.label, private_key = excluded.private_key, public_key = excluded.public_key, passphrase = excluded.passphrase',
      variables: [
        Variable<String>(id),
        Variable<String>(vaultId),
        Variable<String>(label),
        Variable<String>(privateKey),
        Variable<String>(publicKey),
        Variable<String>(passphrase),
      ],
      updates: {keys},
    );
  }

  Future<int> moveKeysByIds(String vaultId, List<String> var2) {
    var $arrayStartIndex = 2;
    final expandedvar2 = $expandVar($arrayStartIndex, var2.length);
    $arrayStartIndex += var2.length;
    return customUpdate(
      'UPDATE keys SET vault_id = ?1 WHERE id IN ($expandedvar2)',
      variables: [
        Variable<String>(vaultId),
        for (var $ in var2) Variable<String>($),
      ],
      updates: {keys},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<String> findAllKeyIds() {
    return customSelect(
      'SELECT id FROM keys',
      variables: [],
      readsFrom: {keys},
    ).map((QueryRow row) => row.read<String>('id'));
  }

  Selectable<FindAllKeyFullByIdsResult> findAllKeyFullByIds(List<String> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT"k"."id" AS "nested_0.id", "k"."vault_id" AS "nested_0.vault_id", "k"."label" AS "nested_0.label", "k"."private_key" AS "nested_0.private_key", "k"."public_key" AS "nested_0.public_key", "k"."passphrase" AS "nested_0.passphrase","v"."id" AS "nested_1.id", "v"."owner" AS "nested_1.owner" FROM keys AS k INNER JOIN vaults AS v ON k.vault_id = v.id WHERE k.id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<String>($)],
      readsFrom: {keys, vaults},
    ).asyncMap(
      (QueryRow row) async => FindAllKeyFullByIdsResult(
        keyEntity: await keys.mapFromRow(row, tablePrefix: 'nested_0'),
        vault: await vaults.mapFromRow(row, tablePrefix: 'nested_1'),
      ),
    );
  }

  Future<int> createOrUpdateIdentity(
    String id,
    String vaultId,
    String label,
    String username,
  ) {
    return customInsert(
      'INSERT INTO identities (id, vault_id, label, username) VALUES (?1, ?2, ?3, ?4) ON CONFLICT (id) DO UPDATE SET vault_id = excluded.vault_id, label = excluded.label, username = excluded.username',
      variables: [
        Variable<String>(id),
        Variable<String>(vaultId),
        Variable<String>(label),
        Variable<String>(username),
      ],
      updates: {identities},
    );
  }

  Future<int> moveIdentitiesByIds(String vaultId, List<String> var2) {
    var $arrayStartIndex = 2;
    final expandedvar2 = $expandVar($arrayStartIndex, var2.length);
    $arrayStartIndex += var2.length;
    return customUpdate(
      'UPDATE identities SET vault_id = ?1 WHERE id IN ($expandedvar2)',
      variables: [
        Variable<String>(vaultId),
        for (var $ in var2) Variable<String>($),
      ],
      updates: {identities},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<String> findCredentialIdsByIdentityIds(List<String> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT credential_id FROM identity_credentials WHERE identity_id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<String>($)],
      readsFrom: {identityCredentials},
    ).map((QueryRow row) => row.read<String>('credential_id'));
  }

  Selectable<String> findIdentityIdsByCredentialIds(List<String> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT identity_id FROM identity_credentials WHERE credential_id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<String>($)],
      readsFrom: {identityCredentials},
    ).map((QueryRow row) => row.read<String>('identity_id'));
  }

  Selectable<FindAllIdentityFullResult> findAllIdentityFull(String vaultId) {
    return customSelect(
      'SELECT"i"."id" AS "nested_0.id", "i"."vault_id" AS "nested_0.vault_id", "i"."label" AS "nested_0.label", "i"."username" AS "nested_0.username","v"."id" AS "nested_1.id", "v"."owner" AS "nested_1.owner", i.id AS "\$n_0" FROM identities AS i INNER JOIN vaults AS v ON i.vault_id = v.id WHERE ?1 = \'\' OR i.vault_id = ?1',
      variables: [Variable<String>(vaultId)],
      readsFrom: {credentials, identityCredentials, identities, vaults},
    ).asyncMap(
      (QueryRow row) async => FindAllIdentityFullResult(
        identity: await identities.mapFromRow(row, tablePrefix: 'nested_0'),
        vault: await vaults.mapFromRow(row, tablePrefix: 'nested_1'),
        identityCredentials: await customSelect(
          'SELECT credentials.id FROM identity_credentials JOIN credentials ON credentials.id = identity_credentials.credential_id WHERE identity_credentials.identity_id = ?1 ORDER BY credentials.id',
          variables: [Variable<String>(row.read('\$n_0'))],
          readsFrom: {credentials, identityCredentials, identities},
        ).map((QueryRow row) => row.read<String>('id')).get(),
      ),
    );
  }

  Future<int> createOrUpdateCredential(
    String id,
    String vaultId,
    CredentialType type,
    String? keyId,
    String? password,
  ) {
    return customInsert(
      'INSERT INTO credentials (id, vault_id, type, key_id, password) VALUES (?1, ?2, ?3, ?4, ?5) ON CONFLICT (id) DO UPDATE SET vault_id = excluded.vault_id, type = excluded.type, key_id = excluded.key_id, password = excluded.password',
      variables: [
        Variable<String>(id),
        Variable<String>(vaultId),
        Variable<String>(Credentials.$convertertype.toSql(type)),
        Variable<String>(keyId),
        Variable<String>(password),
      ],
      updates: {credentials},
    );
  }

  Future<int> moveCredentialsByIds(String vaultId, List<String> var2) {
    var $arrayStartIndex = 2;
    final expandedvar2 = $expandVar($arrayStartIndex, var2.length);
    $arrayStartIndex += var2.length;
    return customUpdate(
      'UPDATE credentials SET vault_id = ?1 WHERE id IN ($expandedvar2)',
      variables: [
        Variable<String>(vaultId),
        for (var $ in var2) Variable<String>($),
      ],
      updates: {credentials},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<String?> findKeyIdsByCredentialIds(List<String> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT key_id FROM credentials WHERE id IN ($expandedvar1) AND key_id IS NOT NULL',
      variables: [for (var $ in var1) Variable<String>($)],
      readsFrom: {credentials},
    ).map((QueryRow row) => row.readNullable<String>('key_id'));
  }

  Selectable<String> findCredentialIdsByKeyIds(List<String?> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT id FROM credentials WHERE key_id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<String>($)],
      readsFrom: {credentials},
    ).map((QueryRow row) => row.read<String>('id'));
  }

  Selectable<String> findAllCredentialIds() {
    return customSelect(
      'SELECT id FROM credentials',
      variables: [],
      readsFrom: {credentials},
    ).map((QueryRow row) => row.read<String>('id'));
  }

  Selectable<FindCredentialFullByIdsResult> findCredentialFullByIds(
    List<String> var1,
  ) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT"c"."id" AS "nested_0.id", "c"."vault_id" AS "nested_0.vault_id", "c"."type" AS "nested_0.type", "c"."key_id" AS "nested_0.key_id", "c"."password" AS "nested_0.password","v"."id" AS "nested_1.id", "v"."owner" AS "nested_1.owner","k"."id" AS "nested_2.id", "k"."vault_id" AS "nested_2.vault_id", "k"."label" AS "nested_2.label", "k"."private_key" AS "nested_2.private_key", "k"."public_key" AS "nested_2.public_key", "k"."passphrase" AS "nested_2.passphrase" FROM credentials AS c INNER JOIN vaults AS v ON c.vault_id = v.id LEFT JOIN keys AS k ON c.key_id = k.id WHERE c.id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<String>($)],
      readsFrom: {credentials, vaults, keys},
    ).asyncMap(
      (QueryRow row) async => FindCredentialFullByIdsResult(
        credential: await credentials.mapFromRow(row, tablePrefix: 'nested_0'),
        vault: await vaults.mapFromRow(row, tablePrefix: 'nested_1'),
        credentialKey: await keys.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_2',
        ),
      ),
    );
  }

  Future<int> createOrUpdateConnection(
    String id,
    String vaultId,
    String label,
    String address,
    int port,
    String? identityId,
    String? username,
    String? groupName,
    ConnectionIcons icon,
    Color iconColor,
    Color iconBackgroundColor,
    TerminalTypography? terminalTypographyOverride,
    String? terminalThemeOverrideId,
    bool usesDefaultThemeOverride,
  ) {
    return customInsert(
      'INSERT INTO connections (id, vault_id, label, address, port, identity_id, username, group_name, icon, icon_color, icon_background_color, terminal_typography_override, terminal_theme_override_id, uses_default_theme_override) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14) ON CONFLICT (id) DO UPDATE SET vault_id = excluded.vault_id, label = excluded.label, address = excluded.address, port = excluded.port, identity_id = excluded.identity_id, username = excluded.username, group_name = excluded.group_name, icon = excluded.icon, icon_color = excluded.icon_color, icon_background_color = excluded.icon_background_color, terminal_typography_override = excluded.terminal_typography_override, terminal_theme_override_id = excluded.terminal_theme_override_id, uses_default_theme_override = excluded.uses_default_theme_override',
      variables: [
        Variable<String>(id),
        Variable<String>(vaultId),
        Variable<String>(label),
        Variable<String>(address),
        Variable<int>(port),
        Variable<String>(identityId),
        Variable<String>(username),
        Variable<String>(groupName),
        Variable<int>(Connections.$convertericon.toSql(icon)),
        Variable<int>(Connections.$convertericonColor.toSql(iconColor)),
        Variable<int>(
          Connections.$convertericonBackgroundColor.toSql(iconBackgroundColor),
        ),
        Variable<String>(
          Connections.$converterterminalTypographyOverriden.toSql(
            terminalTypographyOverride,
          ),
        ),
        Variable<String>(terminalThemeOverrideId),
        Variable<bool>(usesDefaultThemeOverride),
      ],
      updates: {connections},
    );
  }

  Future<int> moveConnectionsByIds(String vaultId, List<String> var2) {
    var $arrayStartIndex = 2;
    final expandedvar2 = $expandVar($arrayStartIndex, var2.length);
    $arrayStartIndex += var2.length;
    return customUpdate(
      'UPDATE connections SET vault_id = ?1 WHERE id IN ($expandedvar2)',
      variables: [
        Variable<String>(vaultId),
        for (var $ in var2) Variable<String>($),
      ],
      updates: {connections},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<String> findConnectionsByIdentityIds(List<String?> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT id FROM connections WHERE identity_id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<String>($)],
      readsFrom: {connections},
    ).map((QueryRow row) => row.read<String>('id'));
  }

  Selectable<String> findConnectionIdsByCredentialIds(List<String> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT connection_id FROM connection_credentials WHERE credential_id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<String>($)],
      readsFrom: {connectionCredentials},
    ).map((QueryRow row) => row.read<String>('connection_id'));
  }

  Selectable<String> findCredentialIdsByConnectionIds(List<String> var1) {
    var $arrayStartIndex = 1;
    final expandedvar1 = $expandVar($arrayStartIndex, var1.length);
    $arrayStartIndex += var1.length;
    return customSelect(
      'SELECT credential_id FROM connection_credentials WHERE connection_id IN ($expandedvar1)',
      variables: [for (var $ in var1) Variable<String>($)],
      readsFrom: {connectionCredentials},
    ).map((QueryRow row) => row.read<String>('credential_id'));
  }

  Selectable<String?> findIdentityIdByConnectionId(String id) {
    return customSelect(
      'SELECT identity_id FROM connections WHERE id = ?1 AND identity_id IS NOT NULL',
      variables: [Variable<String>(id)],
      readsFrom: {connections},
    ).map((QueryRow row) => row.readNullable<String>('identity_id'));
  }

  Selectable<FindAllConnectionFullResult> findAllConnectionFull(
    String vaultId,
  ) {
    return customSelect(
      'SELECT"c"."id" AS "nested_0.id", "c"."vault_id" AS "nested_0.vault_id", "c"."label" AS "nested_0.label", "c"."address" AS "nested_0.address", "c"."port" AS "nested_0.port", "c"."identity_id" AS "nested_0.identity_id", "c"."username" AS "nested_0.username", "c"."group_name" AS "nested_0.group_name", "c"."icon" AS "nested_0.icon", "c"."icon_color" AS "nested_0.icon_color", "c"."icon_background_color" AS "nested_0.icon_background_color", "c"."terminal_typography_override" AS "nested_0.terminal_typography_override", "c"."terminal_theme_override_id" AS "nested_0.terminal_theme_override_id", "c"."uses_default_theme_override" AS "nested_0.uses_default_theme_override","v"."id" AS "nested_1.id", "v"."owner" AS "nested_1.owner","i"."id" AS "nested_2.id", "i"."vault_id" AS "nested_2.vault_id", "i"."label" AS "nested_2.label", "i"."username" AS "nested_2.username","iv"."id" AS "nested_3.id", "iv"."owner" AS "nested_3.owner","t"."id" AS "nested_4.id", "t"."name" AS "nested_4.name", "t"."black" AS "nested_4.black", "t"."red" AS "nested_4.red", "t"."green" AS "nested_4.green", "t"."yellow" AS "nested_4.yellow", "t"."blue" AS "nested_4.blue", "t"."purple" AS "nested_4.purple", "t"."cyan" AS "nested_4.cyan", "t"."white" AS "nested_4.white", "t"."bright_black" AS "nested_4.bright_black", "t"."bright_red" AS "nested_4.bright_red", "t"."bright_green" AS "nested_4.bright_green", "t"."bright_yellow" AS "nested_4.bright_yellow", "t"."bright_blue" AS "nested_4.bright_blue", "t"."bright_purple" AS "nested_4.bright_purple", "t"."bright_cyan" AS "nested_4.bright_cyan", "t"."bright_white" AS "nested_4.bright_white", "t"."background" AS "nested_4.background", "t"."foreground" AS "nested_4.foreground", "t"."cursor" AS "nested_4.cursor", "t"."cursor_text" AS "nested_4.cursor_text", "t"."selection_background" AS "nested_4.selection_background", "t"."selection_foreground" AS "nested_4.selection_foreground", c.id AS "\$n_0", i.id AS "\$n_1" FROM connections AS c INNER JOIN vaults AS v ON c.vault_id = v.id LEFT JOIN identities AS i ON c.identity_id = i.id LEFT JOIN vaults AS iv ON i.vault_id = iv.id LEFT JOIN custom_terminal_themes AS t ON c.terminal_theme_override_id = t.id WHERE ?1 = \'\' OR c.vault_id = ?1',
      variables: [Variable<String>(vaultId)],
      readsFrom: {
        credentials,
        connectionCredentials,
        connections,
        identityCredentials,
        identities,
        vaults,
        customTerminalThemes,
      },
    ).asyncMap(
      (QueryRow row) async => FindAllConnectionFullResult(
        connection: await connections.mapFromRow(row, tablePrefix: 'nested_0'),
        vault: await vaults.mapFromRow(row, tablePrefix: 'nested_1'),
        identity: await identities.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_2',
        ),
        identityVault: await vaults.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_3',
        ),
        terminalThemeOverride: await customTerminalThemes.mapFromRowOrNull(
          row,
          tablePrefix: 'nested_4',
        ),
        connectionCredentials: await customSelect(
          'SELECT credentials.id FROM connection_credentials JOIN credentials ON credentials.id = connection_credentials.credential_id WHERE connection_credentials.connection_id = ?1 ORDER BY credentials.id',
          variables: [Variable<String>(row.read('\$n_0'))],
          readsFrom: {credentials, connectionCredentials, connections},
        ).map((QueryRow row) => row.read<String>('id')).get(),
        identityCredentials: await customSelect(
          'SELECT credentials.id FROM identity_credentials JOIN credentials ON credentials.id = identity_credentials.credential_id WHERE identity_credentials.identity_id = ?1 ORDER BY credentials.id',
          variables: [Variable<String>(row.read('\$n_1'))],
          readsFrom: {credentials, identityCredentials, identities},
        ).map((QueryRow row) => row.read<String>('id')).get(),
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
    vaults,
    identities,
    customTerminalThemes,
    connections,
    keys,
    credentials,
    knownHosts,
    identityCredentials,
    connectionCredentials,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vaults',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('identities', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vaults',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('connections', kind: UpdateKind.delete)],
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
        'vaults',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('keys', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vaults',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credentials', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'keys',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('credentials', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vaults',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('known_hosts', kind: UpdateKind.delete)],
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

typedef $VaultsCreateCompanionBuilder = VaultsCompanion Function({
  Value<String> id,
  Value<String?> owner,
  Value<int> rowid,
});
typedef $VaultsUpdateCompanionBuilder = VaultsCompanion Function({
  Value<String> id,
  Value<String?> owner,
  Value<int> rowid,
});

final class $VaultsReferences
    extends BaseReferences<_$CliqDatabase, Vaults, Vault> {
  $VaultsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Identities, List<Identity>> _identitiesRefsTable(
    _$CliqDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.identities,
    aliasName: 'vaults__id__identities__vault_id',
  );

  $IdentitiesProcessedTableManager get identitiesRefs {
    final manager = $IdentitiesTableManager(
      $_db,
      $_db.identities,
    ).filter((f) => f.vaultId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_identitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Connections, List<Connection>>
  _connectionsRefsTable(_$CliqDatabase db) => MultiTypedResultKey.fromTable(
    db.connections,
    aliasName: 'vaults__id__connections__vault_id',
  );

  $ConnectionsProcessedTableManager get connectionsRefs {
    final manager = $ConnectionsTableManager(
      $_db,
      $_db.connections,
    ).filter((f) => f.vaultId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_connectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Keys, List<Key>> _keysRefsTable(
    _$CliqDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.keys,
    aliasName: 'vaults__id__keys__vault_id',
  );

  $KeysProcessedTableManager get keysRefs {
    final manager = $KeysTableManager(
      $_db,
      $_db.keys,
    ).filter((f) => f.vaultId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_keysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Credentials, List<Credential>>
  _credentialsRefsTable(_$CliqDatabase db) => MultiTypedResultKey.fromTable(
    db.credentials,
    aliasName: 'vaults__id__credentials__vault_id',
  );

  $CredentialsProcessedTableManager get credentialsRefs {
    final manager = $CredentialsTableManager(
      $_db,
      $_db.credentials,
    ).filter((f) => f.vaultId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_credentialsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<KnownHosts, List<KnownHost>> _knownHostsRefsTable(
    _$CliqDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.knownHosts,
    aliasName: 'vaults__id__known_hosts__vault_id',
  );

  $KnownHostsProcessedTableManager get knownHostsRefs {
    final manager = $KnownHostsTableManager(
      $_db,
      $_db.knownHosts,
    ).filter((f) => f.vaultId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_knownHostsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $VaultsFilterComposer extends Composer<_$CliqDatabase, Vaults> {
  $VaultsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> identitiesRefs(
    Expression<bool> Function($IdentitiesFilterComposer f) f,
  ) {
    final $IdentitiesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.identities,
      getReferencedColumn: (t) => t.vaultId,
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
      getReferencedColumn: (t) => t.vaultId,
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

  Expression<bool> keysRefs(
    Expression<bool> Function($KeysFilterComposer f) f,
  ) {
    final $KeysFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.keys,
      getReferencedColumn: (t) => t.vaultId,
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
    return f(composer);
  }

  Expression<bool> credentialsRefs(
    Expression<bool> Function($CredentialsFilterComposer f) f,
  ) {
    final $CredentialsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credentials,
      getReferencedColumn: (t) => t.vaultId,
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

  Expression<bool> knownHostsRefs(
    Expression<bool> Function($KnownHostsFilterComposer f) f,
  ) {
    final $KnownHostsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.knownHosts,
      getReferencedColumn: (t) => t.vaultId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $KnownHostsFilterComposer(
            $db: $db,
            $table: $db.knownHosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $VaultsOrderingComposer extends Composer<_$CliqDatabase, Vaults> {
  $VaultsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );
}

class $VaultsAnnotationComposer extends Composer<_$CliqDatabase, Vaults> {
  $VaultsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  Expression<T> identitiesRefs<T extends Object>(
    Expression<T> Function($IdentitiesAnnotationComposer a) f,
  ) {
    final $IdentitiesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.identities,
      getReferencedColumn: (t) => t.vaultId,
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
      getReferencedColumn: (t) => t.vaultId,
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

  Expression<T> keysRefs<T extends Object>(
    Expression<T> Function($KeysAnnotationComposer a) f,
  ) {
    final $KeysAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.keys,
      getReferencedColumn: (t) => t.vaultId,
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
    return f(composer);
  }

  Expression<T> credentialsRefs<T extends Object>(
    Expression<T> Function($CredentialsAnnotationComposer a) f,
  ) {
    final $CredentialsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.credentials,
      getReferencedColumn: (t) => t.vaultId,
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

  Expression<T> knownHostsRefs<T extends Object>(
    Expression<T> Function($KnownHostsAnnotationComposer a) f,
  ) {
    final $KnownHostsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.knownHosts,
      getReferencedColumn: (t) => t.vaultId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $KnownHostsAnnotationComposer(
            $db: $db,
            $table: $db.knownHosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $VaultsTableManager
    extends
        RootTableManager<
          _$CliqDatabase,
          Vaults,
          Vault,
          $VaultsFilterComposer,
          $VaultsOrderingComposer,
          $VaultsAnnotationComposer,
          $VaultsCreateCompanionBuilder,
          $VaultsUpdateCompanionBuilder,
          (Vault, $VaultsReferences),
          Vault,
          PrefetchHooks Function({
            bool identitiesRefs,
            bool connectionsRefs,
            bool keysRefs,
            bool credentialsRefs,
            bool knownHostsRefs,
          })
        > {
  $VaultsTableManager(_$CliqDatabase db, Vaults table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $VaultsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $VaultsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $VaultsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> owner = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => VaultsCompanion(id: id, owner: owner, rowid: rowid),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> owner = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => VaultsCompanion.insert(id: id, owner: owner, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $VaultsReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback:
              ({
                identitiesRefs = false,
                connectionsRefs = false,
                keysRefs = false,
                credentialsRefs = false,
                knownHostsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (identitiesRefs) db.identities,
                    if (connectionsRefs) db.connections,
                    if (keysRefs) db.keys,
                    if (credentialsRefs) db.credentials,
                    if (knownHostsRefs) db.knownHosts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (identitiesRefs)
                        await $_getPrefetchedData<Vault, Vaults, Identity>(
                          currentTable: table,
                          referencedTable: $VaultsReferences
                              ._identitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $VaultsReferences(db, table, p0).identitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vaultId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (connectionsRefs)
                        await $_getPrefetchedData<Vault, Vaults, Connection>(
                          currentTable: table,
                          referencedTable: $VaultsReferences
                              ._connectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $VaultsReferences(db, table, p0).connectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vaultId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (keysRefs)
                        await $_getPrefetchedData<Vault, Vaults, Key>(
                          currentTable: table,
                          referencedTable: $VaultsReferences._keysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $VaultsReferences(db, table, p0).keysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vaultId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (credentialsRefs)
                        await $_getPrefetchedData<Vault, Vaults, Credential>(
                          currentTable: table,
                          referencedTable: $VaultsReferences
                              ._credentialsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $VaultsReferences(db, table, p0).credentialsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vaultId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (knownHostsRefs)
                        await $_getPrefetchedData<Vault, Vaults, KnownHost>(
                          currentTable: table,
                          referencedTable: $VaultsReferences
                              ._knownHostsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $VaultsReferences(db, table, p0).knownHostsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vaultId == item.id,
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

typedef $VaultsProcessedTableManager =
    ProcessedTableManager<
      _$CliqDatabase,
      Vaults,
      Vault,
      $VaultsFilterComposer,
      $VaultsOrderingComposer,
      $VaultsAnnotationComposer,
      $VaultsCreateCompanionBuilder,
      $VaultsUpdateCompanionBuilder,
      (Vault, $VaultsReferences),
      Vault,
      PrefetchHooks Function({
        bool identitiesRefs,
        bool connectionsRefs,
        bool keysRefs,
        bool credentialsRefs,
        bool knownHostsRefs,
      })
    >;
typedef $IdentitiesCreateCompanionBuilder = IdentitiesCompanion Function({
  Value<String> id,
  required String vaultId,
  required String label,
  required String username,
  Value<int> rowid,
});
typedef $IdentitiesUpdateCompanionBuilder = IdentitiesCompanion Function({
  Value<String> id,
  Value<String> vaultId,
  Value<String> label,
  Value<String> username,
  Value<int> rowid,
});

final class $IdentitiesReferences
    extends BaseReferences<_$CliqDatabase, Identities, Identity> {
  $IdentitiesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Vaults _vaultIdTable(_$CliqDatabase db) =>
      db.vaults.createAlias('identities__vault_id__vaults__id');

  $VaultsProcessedTableManager get vaultId {
    final $_column = $_itemColumn<String>('vault_id')!;

    final manager = $VaultsTableManager(
      $_db,
      $_db.vaults,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Connections, List<Connection>>
  _connectionsRefsTable(_$CliqDatabase db) => MultiTypedResultKey.fromTable(
    db.connections,
    aliasName: 'identities__id__connections__identity_id',
  );

  $ConnectionsProcessedTableManager get connectionsRefs {
    final manager = $ConnectionsTableManager(
      $_db,
      $_db.connections,
    ).filter((f) => f.identityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_connectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<IdentityCredentials, List<IdentityCredential>>
  _identityCredentialsRefsTable(_$CliqDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.identityCredentials,
        aliasName: 'identities__id__identity_credentials__identity_id',
      );

  $IdentityCredentialsProcessedTableManager get identityCredentialsRefs {
    final manager = $IdentityCredentialsTableManager(
      $_db,
      $_db.identityCredentials,
    ).filter((f) => f.identityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _identityCredentialsRefsTable($_db),
    );
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
  ColumnFilters<String> get id => $composableBuilder(
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

  $VaultsFilterComposer get vaultId {
    final $VaultsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsFilterComposer(
            $db: $db,
            $table: $db.vaults,
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
}

class $IdentitiesOrderingComposer extends Composer<_$CliqDatabase, Identities> {
  $IdentitiesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
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

  $VaultsOrderingComposer get vaultId {
    final $VaultsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsOrderingComposer(
            $db: $db,
            $table: $db.vaults,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  $VaultsAnnotationComposer get vaultId {
    final $VaultsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsAnnotationComposer(
            $db: $db,
            $table: $db.vaults,
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
            bool vaultId,
            bool connectionsRefs,
            bool identityCredentialsRefs,
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
                Value<String> id = const Value.absent(),
                Value<String> vaultId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdentitiesCompanion(
                id: id,
                vaultId: vaultId,
                label: label,
                username: username,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String vaultId,
                required String label,
                required String username,
                Value<int> rowid = const Value.absent(),
              }) => IdentitiesCompanion.insert(
                id: id,
                vaultId: vaultId,
                label: label,
                username: username,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $IdentitiesReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vaultId = false,
                connectionsRefs = false,
                identityCredentialsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (connectionsRefs) db.connections,
                    if (identityCredentialsRefs) db.identityCredentials,
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
                        if (vaultId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vaultId,
                            referencedTable: $IdentitiesReferences
                                ._vaultIdTable(db),
                            referencedColumn: $IdentitiesReferences
                                ._vaultIdTable(db)
                                .id,
                          ) as T;
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
        bool vaultId,
        bool connectionsRefs,
        bool identityCredentialsRefs,
      })
    >;
typedef $CustomTerminalThemesCreateCompanionBuilder =
    CustomTerminalThemesCompanion Function({
      Value<String> id,
      required String name,
      required Color black,
      required Color red,
      required Color green,
      required Color yellow,
      required Color blue,
      required Color purple,
      required Color cyan,
      required Color white,
      required Color brightBlack,
      required Color brightRed,
      required Color brightGreen,
      required Color brightYellow,
      required Color brightBlue,
      required Color brightPurple,
      required Color brightCyan,
      required Color brightWhite,
      required Color background,
      required Color foreground,
      required Color cursor,
      required Color cursorText,
      required Color selectionBackground,
      required Color selectionForeground,
      Value<int> rowid,
    });
typedef $CustomTerminalThemesUpdateCompanionBuilder =
    CustomTerminalThemesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<Color> black,
      Value<Color> red,
      Value<Color> green,
      Value<Color> yellow,
      Value<Color> blue,
      Value<Color> purple,
      Value<Color> cyan,
      Value<Color> white,
      Value<Color> brightBlack,
      Value<Color> brightRed,
      Value<Color> brightGreen,
      Value<Color> brightYellow,
      Value<Color> brightBlue,
      Value<Color> brightPurple,
      Value<Color> brightCyan,
      Value<Color> brightWhite,
      Value<Color> background,
      Value<Color> foreground,
      Value<Color> cursor,
      Value<Color> cursorText,
      Value<Color> selectionBackground,
      Value<Color> selectionForeground,
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
    aliasName:
        'custom_terminal_themes__id__connections__terminal_theme_override_id',
  );

  $ConnectionsProcessedTableManager get connectionsRefs {
    final manager = $ConnectionsTableManager($_db, $_db.connections).filter(
      (f) =>
          f.terminalThemeOverrideId.id.sqlEquals($_itemColumn<String>('id')!),
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Color, Color, int> get black =>
      $composableBuilder(
        column: $table.black,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get red =>
      $composableBuilder(
        column: $table.red,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get green =>
      $composableBuilder(
        column: $table.green,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get yellow =>
      $composableBuilder(
        column: $table.yellow,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get blue =>
      $composableBuilder(
        column: $table.blue,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get purple =>
      $composableBuilder(
        column: $table.purple,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get cyan =>
      $composableBuilder(
        column: $table.cyan,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get white =>
      $composableBuilder(
        column: $table.white,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightBlack =>
      $composableBuilder(
        column: $table.brightBlack,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightRed =>
      $composableBuilder(
        column: $table.brightRed,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightGreen =>
      $composableBuilder(
        column: $table.brightGreen,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightYellow =>
      $composableBuilder(
        column: $table.brightYellow,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightBlue =>
      $composableBuilder(
        column: $table.brightBlue,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightPurple =>
      $composableBuilder(
        column: $table.brightPurple,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightCyan =>
      $composableBuilder(
        column: $table.brightCyan,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get brightWhite =>
      $composableBuilder(
        column: $table.brightWhite,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get background =>
      $composableBuilder(
        column: $table.background,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get foreground =>
      $composableBuilder(
        column: $table.foreground,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get cursor =>
      $composableBuilder(
        column: $table.cursor,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get cursorText =>
      $composableBuilder(
        column: $table.cursorText,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get selectionBackground =>
      $composableBuilder(
        column: $table.selectionBackground,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Color, Color, int> get selectionForeground =>
      $composableBuilder(
        column: $table.selectionForeground,
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get black => $composableBuilder(
    column: $table.black,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get red => $composableBuilder(
    column: $table.red,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get green => $composableBuilder(
    column: $table.green,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yellow => $composableBuilder(
    column: $table.yellow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blue => $composableBuilder(
    column: $table.blue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purple => $composableBuilder(
    column: $table.purple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cyan => $composableBuilder(
    column: $table.cyan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get white => $composableBuilder(
    column: $table.white,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightBlack => $composableBuilder(
    column: $table.brightBlack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightRed => $composableBuilder(
    column: $table.brightRed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightGreen => $composableBuilder(
    column: $table.brightGreen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightYellow => $composableBuilder(
    column: $table.brightYellow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightBlue => $composableBuilder(
    column: $table.brightBlue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightPurple => $composableBuilder(
    column: $table.brightPurple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightCyan => $composableBuilder(
    column: $table.brightCyan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brightWhite => $composableBuilder(
    column: $table.brightWhite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foreground => $composableBuilder(
    column: $table.foreground,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursorText => $composableBuilder(
    column: $table.cursorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectionBackground => $composableBuilder(
    column: $table.selectionBackground,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectionForeground => $composableBuilder(
    column: $table.selectionForeground,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get black =>
      $composableBuilder(column: $table.black, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get red =>
      $composableBuilder(column: $table.red, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get green =>
      $composableBuilder(column: $table.green, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get yellow =>
      $composableBuilder(column: $table.yellow, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get blue =>
      $composableBuilder(column: $table.blue, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get purple =>
      $composableBuilder(column: $table.purple, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get cyan =>
      $composableBuilder(column: $table.cyan, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get white =>
      $composableBuilder(column: $table.white, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get brightBlack =>
      $composableBuilder(
        column: $table.brightBlack,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightRed =>
      $composableBuilder(column: $table.brightRed, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get brightGreen =>
      $composableBuilder(
        column: $table.brightGreen,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightYellow =>
      $composableBuilder(
        column: $table.brightYellow,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightBlue =>
      $composableBuilder(
        column: $table.brightBlue,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightPurple =>
      $composableBuilder(
        column: $table.brightPurple,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightCyan =>
      $composableBuilder(
        column: $table.brightCyan,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get brightWhite =>
      $composableBuilder(
        column: $table.brightWhite,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get background =>
      $composableBuilder(
        column: $table.background,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get foreground =>
      $composableBuilder(
        column: $table.foreground,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get cursorText =>
      $composableBuilder(
        column: $table.cursorText,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get selectionBackground =>
      $composableBuilder(
        column: $table.selectionBackground,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Color, int> get selectionForeground =>
      $composableBuilder(
        column: $table.selectionForeground,
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
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Color> black = const Value.absent(),
                Value<Color> red = const Value.absent(),
                Value<Color> green = const Value.absent(),
                Value<Color> yellow = const Value.absent(),
                Value<Color> blue = const Value.absent(),
                Value<Color> purple = const Value.absent(),
                Value<Color> cyan = const Value.absent(),
                Value<Color> white = const Value.absent(),
                Value<Color> brightBlack = const Value.absent(),
                Value<Color> brightRed = const Value.absent(),
                Value<Color> brightGreen = const Value.absent(),
                Value<Color> brightYellow = const Value.absent(),
                Value<Color> brightBlue = const Value.absent(),
                Value<Color> brightPurple = const Value.absent(),
                Value<Color> brightCyan = const Value.absent(),
                Value<Color> brightWhite = const Value.absent(),
                Value<Color> background = const Value.absent(),
                Value<Color> foreground = const Value.absent(),
                Value<Color> cursor = const Value.absent(),
                Value<Color> cursorText = const Value.absent(),
                Value<Color> selectionBackground = const Value.absent(),
                Value<Color> selectionForeground = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomTerminalThemesCompanion(
                id: id,
                name: name,
                black: black,
                red: red,
                green: green,
                yellow: yellow,
                blue: blue,
                purple: purple,
                cyan: cyan,
                white: white,
                brightBlack: brightBlack,
                brightRed: brightRed,
                brightGreen: brightGreen,
                brightYellow: brightYellow,
                brightBlue: brightBlue,
                brightPurple: brightPurple,
                brightCyan: brightCyan,
                brightWhite: brightWhite,
                background: background,
                foreground: foreground,
                cursor: cursor,
                cursorText: cursorText,
                selectionBackground: selectionBackground,
                selectionForeground: selectionForeground,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required Color black,
                required Color red,
                required Color green,
                required Color yellow,
                required Color blue,
                required Color purple,
                required Color cyan,
                required Color white,
                required Color brightBlack,
                required Color brightRed,
                required Color brightGreen,
                required Color brightYellow,
                required Color brightBlue,
                required Color brightPurple,
                required Color brightCyan,
                required Color brightWhite,
                required Color background,
                required Color foreground,
                required Color cursor,
                required Color cursorText,
                required Color selectionBackground,
                required Color selectionForeground,
                Value<int> rowid = const Value.absent(),
              }) => CustomTerminalThemesCompanion.insert(
                id: id,
                name: name,
                black: black,
                red: red,
                green: green,
                yellow: yellow,
                blue: blue,
                purple: purple,
                cyan: cyan,
                white: white,
                brightBlack: brightBlack,
                brightRed: brightRed,
                brightGreen: brightGreen,
                brightYellow: brightYellow,
                brightBlue: brightBlue,
                brightPurple: brightPurple,
                brightCyan: brightCyan,
                brightWhite: brightWhite,
                background: background,
                foreground: foreground,
                cursor: cursor,
                cursorText: cursorText,
                selectionBackground: selectionBackground,
                selectionForeground: selectionForeground,
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
typedef $ConnectionsCreateCompanionBuilder = ConnectionsCompanion Function({
  Value<String> id,
  required String vaultId,
  required String label,
  required String address,
  required int port,
  Value<String?> identityId,
  Value<String?> username,
  Value<String?> groupName,
  Value<ConnectionIcons> icon,
  required Color iconColor,
  required Color iconBackgroundColor,
  Value<TerminalTypography?> terminalTypographyOverride,
  Value<String?> terminalThemeOverrideId,
  Value<bool> usesDefaultThemeOverride,
  Value<int> rowid,
});
typedef $ConnectionsUpdateCompanionBuilder = ConnectionsCompanion Function({
  Value<String> id,
  Value<String> vaultId,
  Value<String> label,
  Value<String> address,
  Value<int> port,
  Value<String?> identityId,
  Value<String?> username,
  Value<String?> groupName,
  Value<ConnectionIcons> icon,
  Value<Color> iconColor,
  Value<Color> iconBackgroundColor,
  Value<TerminalTypography?> terminalTypographyOverride,
  Value<String?> terminalThemeOverrideId,
  Value<bool> usesDefaultThemeOverride,
  Value<int> rowid,
});

final class $ConnectionsReferences
    extends BaseReferences<_$CliqDatabase, Connections, Connection> {
  $ConnectionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Vaults _vaultIdTable(_$CliqDatabase db) =>
      db.vaults.createAlias('connections__vault_id__vaults__id');

  $VaultsProcessedTableManager get vaultId {
    final $_column = $_itemColumn<String>('vault_id')!;

    final manager = $VaultsTableManager(
      $_db,
      $_db.vaults,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Identities _identityIdTable(_$CliqDatabase db) =>
      db.identities.createAlias('connections__identity_id__identities__id');

  $IdentitiesProcessedTableManager? get identityId {
    final $_column = $_itemColumn<String>('identity_id');
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
    'connections__terminal_theme_override_id__custom_terminal_themes__id',
  );

  $CustomTerminalThemesProcessedTableManager? get terminalThemeOverrideId {
    final $_column = $_itemColumn<String>('terminal_theme_override_id');
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
        aliasName: 'connections__id__connection_credentials__connection_id',
      );

  $ConnectionCredentialsProcessedTableManager get connectionCredentialsRefs {
    final manager = $ConnectionCredentialsTableManager(
      $_db,
      $_db.connectionCredentials,
    ).filter((f) => f.connectionId.id.sqlEquals($_itemColumn<String>('id')!));

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
  ColumnFilters<String> get id => $composableBuilder(
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

  ColumnWithTypeConverterFilters<ConnectionIcons, ConnectionIcons, int>
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

  ColumnWithTypeConverterFilters<
    TerminalTypography?,
    TerminalTypography,
    String
  >
  get terminalTypographyOverride => $composableBuilder(
    column: $table.terminalTypographyOverride,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get usesDefaultThemeOverride => $composableBuilder(
    column: $table.usesDefaultThemeOverride,
    builder: (column) => ColumnFilters(column),
  );

  $VaultsFilterComposer get vaultId {
    final $VaultsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsFilterComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
  ColumnOrderings<String> get id => $composableBuilder(
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

  ColumnOrderings<String> get terminalTypographyOverride => $composableBuilder(
    column: $table.terminalTypographyOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usesDefaultThemeOverride => $composableBuilder(
    column: $table.usesDefaultThemeOverride,
    builder: (column) => ColumnOrderings(column),
  );

  $VaultsOrderingComposer get vaultId {
    final $VaultsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsOrderingComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
  GeneratedColumn<String> get id =>
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

  GeneratedColumnWithTypeConverter<ConnectionIcons, int> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get iconColor =>
      $composableBuilder(column: $table.iconColor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get iconBackgroundColor =>
      $composableBuilder(
        column: $table.iconBackgroundColor,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<TerminalTypography?, String>
  get terminalTypographyOverride => $composableBuilder(
    column: $table.terminalTypographyOverride,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get usesDefaultThemeOverride => $composableBuilder(
    column: $table.usesDefaultThemeOverride,
    builder: (column) => column,
  );

  $VaultsAnnotationComposer get vaultId {
    final $VaultsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsAnnotationComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
            bool vaultId,
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
                Value<String> id = const Value.absent(),
                Value<String> vaultId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String?> identityId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<ConnectionIcons> icon = const Value.absent(),
                Value<Color> iconColor = const Value.absent(),
                Value<Color> iconBackgroundColor = const Value.absent(),
                Value<TerminalTypography?> terminalTypographyOverride =
                    const Value.absent(),
                Value<String?> terminalThemeOverrideId = const Value.absent(),
                Value<bool> usesDefaultThemeOverride = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionsCompanion(
                id: id,
                vaultId: vaultId,
                label: label,
                address: address,
                port: port,
                identityId: identityId,
                username: username,
                groupName: groupName,
                icon: icon,
                iconColor: iconColor,
                iconBackgroundColor: iconBackgroundColor,
                terminalTypographyOverride: terminalTypographyOverride,
                terminalThemeOverrideId: terminalThemeOverrideId,
                usesDefaultThemeOverride: usesDefaultThemeOverride,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String vaultId,
                required String label,
                required String address,
                required int port,
                Value<String?> identityId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<ConnectionIcons> icon = const Value.absent(),
                required Color iconColor,
                required Color iconBackgroundColor,
                Value<TerminalTypography?> terminalTypographyOverride =
                    const Value.absent(),
                Value<String?> terminalThemeOverrideId = const Value.absent(),
                Value<bool> usesDefaultThemeOverride = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionsCompanion.insert(
                id: id,
                vaultId: vaultId,
                label: label,
                address: address,
                port: port,
                identityId: identityId,
                username: username,
                groupName: groupName,
                icon: icon,
                iconColor: iconColor,
                iconBackgroundColor: iconBackgroundColor,
                terminalTypographyOverride: terminalTypographyOverride,
                terminalThemeOverrideId: terminalThemeOverrideId,
                usesDefaultThemeOverride: usesDefaultThemeOverride,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $ConnectionsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vaultId = false,
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
                        if (vaultId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vaultId,
                            referencedTable: $ConnectionsReferences
                                ._vaultIdTable(db),
                            referencedColumn: $ConnectionsReferences
                                ._vaultIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (identityId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.identityId,
                            referencedTable: $ConnectionsReferences
                                ._identityIdTable(db),
                            referencedColumn: $ConnectionsReferences
                                ._identityIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (terminalThemeOverrideId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.terminalThemeOverrideId,
                            referencedTable: $ConnectionsReferences
                                ._terminalThemeOverrideIdTable(db),
                            referencedColumn: $ConnectionsReferences
                                ._terminalThemeOverrideIdTable(db)
                                .id,
                          ) as T;
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
        bool vaultId,
        bool identityId,
        bool terminalThemeOverrideId,
        bool connectionCredentialsRefs,
      })
    >;
typedef $KeysCreateCompanionBuilder = KeysCompanion Function({
  Value<String> id,
  required String vaultId,
  required String label,
  required String privateKey,
  Value<String?> publicKey,
  Value<String?> passphrase,
  Value<int> rowid,
});
typedef $KeysUpdateCompanionBuilder = KeysCompanion Function({
  Value<String> id,
  Value<String> vaultId,
  Value<String> label,
  Value<String> privateKey,
  Value<String?> publicKey,
  Value<String?> passphrase,
  Value<int> rowid,
});

final class $KeysReferences extends BaseReferences<_$CliqDatabase, Keys, Key> {
  $KeysReferences(super.$_db, super.$_table, super.$_typedResult);

  static Vaults _vaultIdTable(_$CliqDatabase db) =>
      db.vaults.createAlias('keys__vault_id__vaults__id');

  $VaultsProcessedTableManager get vaultId {
    final $_column = $_itemColumn<String>('vault_id')!;

    final manager = $VaultsTableManager(
      $_db,
      $_db.vaults,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Credentials, List<Credential>>
  _credentialsRefsTable(_$CliqDatabase db) => MultiTypedResultKey.fromTable(
    db.credentials,
    aliasName: 'keys__id__credentials__key_id',
  );

  $CredentialsProcessedTableManager get credentialsRefs {
    final manager = $CredentialsTableManager(
      $_db,
      $_db.credentials,
    ).filter((f) => f.keyId.id.sqlEquals($_itemColumn<String>('id')!));

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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => ColumnFilters(column),
  );

  $VaultsFilterComposer get vaultId {
    final $VaultsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsFilterComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => ColumnOrderings(column),
  );

  $VaultsOrderingComposer get vaultId {
    final $VaultsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsOrderingComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $KeysAnnotationComposer extends Composer<_$CliqDatabase, Keys> {
  $KeysAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => column,
  );

  $VaultsAnnotationComposer get vaultId {
    final $VaultsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsAnnotationComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
          PrefetchHooks Function({bool vaultId, bool credentialsRefs})
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
                Value<String> id = const Value.absent(),
                Value<String> vaultId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> privateKey = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<String?> passphrase = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeysCompanion(
                id: id,
                vaultId: vaultId,
                label: label,
                privateKey: privateKey,
                publicKey: publicKey,
                passphrase: passphrase,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String vaultId,
                required String label,
                required String privateKey,
                Value<String?> publicKey = const Value.absent(),
                Value<String?> passphrase = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeysCompanion.insert(
                id: id,
                vaultId: vaultId,
                label: label,
                privateKey: privateKey,
                publicKey: publicKey,
                passphrase: passphrase,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $KeysReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({vaultId = false, credentialsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (credentialsRefs) db.credentials],
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
                    if (vaultId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vaultId,
                        referencedTable: $KeysReferences._vaultIdTable(db),
                        referencedColumn: $KeysReferences._vaultIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
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
      PrefetchHooks Function({bool vaultId, bool credentialsRefs})
    >;
typedef $CredentialsCreateCompanionBuilder = CredentialsCompanion Function({
  Value<String> id,
  required String vaultId,
  required CredentialType type,
  Value<String?> keyId,
  Value<String?> password,
  Value<int> rowid,
});
typedef $CredentialsUpdateCompanionBuilder = CredentialsCompanion Function({
  Value<String> id,
  Value<String> vaultId,
  Value<CredentialType> type,
  Value<String?> keyId,
  Value<String?> password,
  Value<int> rowid,
});

final class $CredentialsReferences
    extends BaseReferences<_$CliqDatabase, Credentials, Credential> {
  $CredentialsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Vaults _vaultIdTable(_$CliqDatabase db) =>
      db.vaults.createAlias('credentials__vault_id__vaults__id');

  $VaultsProcessedTableManager get vaultId {
    final $_column = $_itemColumn<String>('vault_id')!;

    final manager = $VaultsTableManager(
      $_db,
      $_db.vaults,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Keys _keyIdTable(_$CliqDatabase db) =>
      db.keys.createAlias('credentials__key_id__keys__id');

  $KeysProcessedTableManager? get keyId {
    final $_column = $_itemColumn<String>('key_id');
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
        aliasName: 'credentials__id__identity_credentials__credential_id',
      );

  $IdentityCredentialsProcessedTableManager get identityCredentialsRefs {
    final manager = $IdentityCredentialsTableManager(
      $_db,
      $_db.identityCredentials,
    ).filter((f) => f.credentialId.id.sqlEquals($_itemColumn<String>('id')!));

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
        aliasName: 'credentials__id__connection_credentials__credential_id',
      );

  $ConnectionCredentialsProcessedTableManager get connectionCredentialsRefs {
    final manager = $ConnectionCredentialsTableManager(
      $_db,
      $_db.connectionCredentials,
    ).filter((f) => f.credentialId.id.sqlEquals($_itemColumn<String>('id')!));

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
  ColumnFilters<String> get id => $composableBuilder(
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

  $VaultsFilterComposer get vaultId {
    final $VaultsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsFilterComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
  ColumnOrderings<String> get id => $composableBuilder(
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

  $VaultsOrderingComposer get vaultId {
    final $VaultsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsOrderingComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CredentialType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  $VaultsAnnotationComposer get vaultId {
    final $VaultsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsAnnotationComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
            bool vaultId,
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
                Value<String> id = const Value.absent(),
                Value<String> vaultId = const Value.absent(),
                Value<CredentialType> type = const Value.absent(),
                Value<String?> keyId = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CredentialsCompanion(
                id: id,
                vaultId: vaultId,
                type: type,
                keyId: keyId,
                password: password,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String vaultId,
                required CredentialType type,
                Value<String?> keyId = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CredentialsCompanion.insert(
                id: id,
                vaultId: vaultId,
                type: type,
                keyId: keyId,
                password: password,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $CredentialsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vaultId = false,
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
                        if (vaultId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vaultId,
                            referencedTable: $CredentialsReferences
                                ._vaultIdTable(db),
                            referencedColumn: $CredentialsReferences
                                ._vaultIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (keyId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.keyId,
                            referencedTable: $CredentialsReferences._keyIdTable(
                              db,
                            ),
                            referencedColumn: $CredentialsReferences
                                ._keyIdTable(db)
                                .id,
                          ) as T;
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
        bool vaultId,
        bool keyId,
        bool identityCredentialsRefs,
        bool connectionCredentialsRefs,
      })
    >;
typedef $KnownHostsCreateCompanionBuilder = KnownHostsCompanion Function({
  Value<String> id,
  required String vaultId,
  required String host,
  required Uint8List hostKey,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $KnownHostsUpdateCompanionBuilder = KnownHostsCompanion Function({
  Value<String> id,
  Value<String> vaultId,
  Value<String> host,
  Value<Uint8List> hostKey,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $KnownHostsReferences
    extends BaseReferences<_$CliqDatabase, KnownHosts, KnownHost> {
  $KnownHostsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Vaults _vaultIdTable(_$CliqDatabase db) =>
      db.vaults.createAlias('known_hosts__vault_id__vaults__id');

  $VaultsProcessedTableManager get vaultId {
    final $_column = $_itemColumn<String>('vault_id')!;

    final manager = $VaultsTableManager(
      $_db,
      $_db.vaults,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $KnownHostsFilterComposer extends Composer<_$CliqDatabase, KnownHosts> {
  $KnownHostsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
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

  $VaultsFilterComposer get vaultId {
    final $VaultsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsFilterComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $KnownHostsOrderingComposer extends Composer<_$CliqDatabase, KnownHosts> {
  $KnownHostsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
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

  $VaultsOrderingComposer get vaultId {
    final $VaultsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsOrderingComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<Uint8List> get hostKey =>
      $composableBuilder(column: $table.hostKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $VaultsAnnotationComposer get vaultId {
    final $VaultsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $VaultsAnnotationComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (KnownHost, $KnownHostsReferences),
          KnownHost,
          PrefetchHooks Function({bool vaultId})
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
                Value<String> id = const Value.absent(),
                Value<String> vaultId = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<Uint8List> hostKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KnownHostsCompanion(
                id: id,
                vaultId: vaultId,
                host: host,
                hostKey: hostKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String vaultId,
                required String host,
                required Uint8List hostKey,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KnownHostsCompanion.insert(
                id: id,
                vaultId: vaultId,
                host: host,
                hostKey: hostKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $KnownHostsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({vaultId = false}) {
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
                    if (vaultId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.vaultId,
                        referencedTable: $KnownHostsReferences._vaultIdTable(
                          db,
                        ),
                        referencedColumn: $KnownHostsReferences
                            ._vaultIdTable(db)
                            .id,
                      ) as T;
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
      (KnownHost, $KnownHostsReferences),
      KnownHost,
      PrefetchHooks Function({bool vaultId})
    >;
typedef $IdentityCredentialsCreateCompanionBuilder =
    IdentityCredentialsCompanion Function({
      required String identityId,
      required String credentialId,
      Value<int> rowid,
    });
typedef $IdentityCredentialsUpdateCompanionBuilder =
    IdentityCredentialsCompanion Function({
      Value<String> identityId,
      Value<String> credentialId,
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

  static Identities _identityIdTable(_$CliqDatabase db) => db.identities
      .createAlias('identity_credentials__identity_id__identities__id');

  $IdentitiesProcessedTableManager get identityId {
    final $_column = $_itemColumn<String>('identity_id')!;

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

  static Credentials _credentialIdTable(_$CliqDatabase db) => db.credentials
      .createAlias('identity_credentials__credential_id__credentials__id');

  $CredentialsProcessedTableManager get credentialId {
    final $_column = $_itemColumn<String>('credential_id')!;

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
                Value<String> identityId = const Value.absent(),
                Value<String> credentialId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdentityCredentialsCompanion(
                identityId: identityId,
                credentialId: credentialId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String identityId,
                required String credentialId,
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
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.identityId,
                        referencedTable: $IdentityCredentialsReferences
                            ._identityIdTable(db),
                        referencedColumn: $IdentityCredentialsReferences
                            ._identityIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (credentialId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.credentialId,
                        referencedTable: $IdentityCredentialsReferences
                            ._credentialIdTable(db),
                        referencedColumn: $IdentityCredentialsReferences
                            ._credentialIdTable(db)
                            .id,
                      ) as T;
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
typedef $ConnectionCredentialsCreateCompanionBuilder =
    ConnectionCredentialsCompanion Function({
      required String connectionId,
      required String credentialId,
      Value<int> rowid,
    });
typedef $ConnectionCredentialsUpdateCompanionBuilder =
    ConnectionCredentialsCompanion Function({
      Value<String> connectionId,
      Value<String> credentialId,
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

  static Connections _connectionIdTable(_$CliqDatabase db) => db.connections
      .createAlias('connection_credentials__connection_id__connections__id');

  $ConnectionsProcessedTableManager get connectionId {
    final $_column = $_itemColumn<String>('connection_id')!;

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

  static Credentials _credentialIdTable(_$CliqDatabase db) => db.credentials
      .createAlias('connection_credentials__credential_id__credentials__id');

  $CredentialsProcessedTableManager get credentialId {
    final $_column = $_itemColumn<String>('credential_id')!;

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
                Value<String> connectionId = const Value.absent(),
                Value<String> credentialId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionCredentialsCompanion(
                connectionId: connectionId,
                credentialId: credentialId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String connectionId,
                required String credentialId,
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
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.connectionId,
                            referencedTable: $ConnectionCredentialsReferences
                                ._connectionIdTable(db),
                            referencedColumn: $ConnectionCredentialsReferences
                                ._connectionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (credentialId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.credentialId,
                            referencedTable: $ConnectionCredentialsReferences
                                ._credentialIdTable(db),
                            referencedColumn: $ConnectionCredentialsReferences
                                ._credentialIdTable(db)
                                .id,
                          ) as T;
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
  $VaultsTableManager get vaults => $VaultsTableManager(_db, _db.vaults);
  $IdentitiesTableManager get identities =>
      $IdentitiesTableManager(_db, _db.identities);
  $CustomTerminalThemesTableManager get customTerminalThemes =>
      $CustomTerminalThemesTableManager(_db, _db.customTerminalThemes);
  $ConnectionsTableManager get connections =>
      $ConnectionsTableManager(_db, _db.connections);
  $KeysTableManager get keys => $KeysTableManager(_db, _db.keys);
  $CredentialsTableManager get credentials =>
      $CredentialsTableManager(_db, _db.credentials);
  $KnownHostsTableManager get knownHosts =>
      $KnownHostsTableManager(_db, _db.knownHosts);
  $IdentityCredentialsTableManager get identityCredentials =>
      $IdentityCredentialsTableManager(_db, _db.identityCredentials);
  $ConnectionCredentialsTableManager get connectionCredentials =>
      $ConnectionCredentialsTableManager(_db, _db.connectionCredentials);
}

class FindAllKnownHostsFullResult {
  final KnownHost knownHost;
  final Vault vault;
  FindAllKnownHostsFullResult({required this.knownHost, required this.vault});
}

class FindAllKeyFullByIdsResult {
  final Key keyEntity;
  final Vault vault;
  FindAllKeyFullByIdsResult({required this.keyEntity, required this.vault});
}

class FindAllIdentityFullResult {
  final Identity identity;
  final Vault vault;
  final List<String> identityCredentials;
  FindAllIdentityFullResult({
    required this.identity,
    required this.vault,
    required this.identityCredentials,
  });
}

class FindCredentialFullByIdsResult {
  final Credential credential;
  final Vault vault;
  final Key? credentialKey;
  FindCredentialFullByIdsResult({
    required this.credential,
    required this.vault,
    this.credentialKey,
  });
}

class FindAllConnectionFullResult {
  final Connection connection;
  final Vault vault;
  final Identity? identity;
  final Vault? identityVault;
  final CustomTerminalTheme? terminalThemeOverride;
  final List<String> connectionCredentials;
  final List<String> identityCredentials;
  FindAllConnectionFullResult({
    required this.connection,
    required this.vault,
    this.identity,
    this.identityVault,
    this.terminalThemeOverride,
    required this.connectionCredentials,
    required this.identityCredentials,
  });
}
