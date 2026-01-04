// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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
          ..write('groupName: $groupName')
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
          other.groupName == this.groupName);
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
          ..write('groupName: $groupName')
          ..write(')'))
        .toString();
  }
}

abstract class _$CliqDatabase extends GeneratedDatabase {
  _$CliqDatabase(QueryExecutor e) : super(e);
  $CliqDatabaseManager get managers => $CliqDatabaseManager(this);
  late final Credentials credentials = Credentials(this);
  late final Identities identities = Identities(this);
  late final Connections connections = Connections(this);
  Selectable<FindFullIdentityByIdResult> findFullIdentityById(int id) {
    return customSelect(
      'SELECT i.id AS identity_id, i.username AS identity_username, i.credential_id AS identity_credential_id, c.id AS credential_id, c.type AS credential_type, c.data AS credential_data, c.passphrase AS credential_passphrase FROM identities AS i LEFT JOIN credentials AS c ON c.id = i.credential_id WHERE i.id = ?1',
      variables: [Variable<int>(id)],
      readsFrom: {identities, credentials},
    ).map(
      (QueryRow row) => FindFullIdentityByIdResult(
        identityId: row.read<int>('identity_id'),
        identityUsername: row.read<String>('identity_username'),
        identityCredentialId: row.read<int>('identity_credential_id'),
        credentialId: row.readNullable<int>('credential_id'),
        credentialType: NullAwareTypeConverter.wrapFromSql(
          Credentials.$convertertype,
          row.readNullable<int>('credential_type'),
        ),
        credentialData: row.readNullable<String>('credential_data'),
        credentialPassphrase: row.readNullable<String>('credential_passphrase'),
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

  Selectable<FindAllConnectionFullResult> findAllConnectionFull() {
    return customSelect(
      'SELECT con.id AS connection_id, con.address, con.port, con.identity_id, con.username AS connection_username, con.credential_id AS connection_credential_ref_id, con.label, con.icon, con.color, con.group_name, i.id AS identity_id, i.username AS identity_username, i.credential_id AS identity_credential_ref_id, ci.id AS identity_credential_id_explicit, ci.type AS identity_credential_type, ci.data AS identity_credential_data, ci.passphrase AS identity_credential_passphrase, cc.id AS connection_credential_id_explicit, cc.type AS connection_credential_type, cc.data AS connection_credential_data, cc.passphrase AS connection_credential_passphrase, COALESCE(ci.id, cc.id) AS effective_credential_id, COALESCE(ci.type, cc.type) AS effective_credential_type, COALESCE(ci.data, cc.data) AS effective_credential_data, COALESCE(ci.passphrase, cc.passphrase) AS effective_credential_passphrase FROM connections AS con LEFT JOIN identities AS i ON i.id = con.identity_id LEFT JOIN credentials AS ci ON ci.id = i.credential_id LEFT JOIN credentials AS cc ON cc.id = con.credential_id ORDER BY con.id',
      variables: [],
      readsFrom: {connections, identities, credentials},
    ).map(
      (QueryRow row) => FindAllConnectionFullResult(
        connectionId: row.read<int>('connection_id'),
        address: row.read<String>('address'),
        port: row.read<int>('port'),
        identityId: row.readNullable<int>('identity_id'),
        connectionUsername: row.readNullable<String>('connection_username'),
        connectionCredentialRefId: row.readNullable<int>(
          'connection_credential_ref_id',
        ),
        label: row.readNullable<String>('label'),
        icon: Connections.$convertericon.fromSql(row.read<int>('icon')),
        color: row.readNullable<String>('color'),
        groupName: row.readNullable<String>('group_name'),
        identityId1: row.readNullable<int>('identity_id'),
        identityUsername: row.readNullable<String>('identity_username'),
        identityCredentialRefId: row.readNullable<int>(
          'identity_credential_ref_id',
        ),
        identityCredentialIdExplicit: row.readNullable<int>(
          'identity_credential_id_explicit',
        ),
        identityCredentialType: NullAwareTypeConverter.wrapFromSql(
          Credentials.$convertertype,
          row.readNullable<int>('identity_credential_type'),
        ),
        identityCredentialData: row.readNullable<String>(
          'identity_credential_data',
        ),
        identityCredentialPassphrase: row.readNullable<String>(
          'identity_credential_passphrase',
        ),
        connectionCredentialIdExplicit: row.readNullable<int>(
          'connection_credential_id_explicit',
        ),
        connectionCredentialType: NullAwareTypeConverter.wrapFromSql(
          Credentials.$convertertype,
          row.readNullable<int>('connection_credential_type'),
        ),
        connectionCredentialData: row.readNullable<String>(
          'connection_credential_data',
        ),
        connectionCredentialPassphrase: row.readNullable<String>(
          'connection_credential_passphrase',
        ),
        effectiveCredentialId: row.readNullable<int>('effective_credential_id'),
        effectiveCredentialType: NullAwareTypeConverter.wrapFromSql(
          Credentials.$convertertype,
          row.readNullable<int>('effective_credential_type'),
        ),
        effectiveCredentialData: row.readNullable<String>(
          'effective_credential_data',
        ),
        effectiveCredentialPassphrase: row.readNullable<String>(
          'effective_credential_passphrase',
        ),
      ),
    );
  }

  Future<int> deleteConnectionById(int id) {
    return customUpdate(
      'DELETE FROM connections WHERE id = ?1',
      variables: [Variable<int>(id)],
      updates: {connections},
      updateKind: UpdateKind.delete,
    );
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
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
  ]);
}

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
          PrefetchHooks Function({bool identityId, bool credentialId})
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
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $ConnectionsReferences(db, table, e)),
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
      PrefetchHooks Function({bool identityId, bool credentialId})
    >;

class $CliqDatabaseManager {
  final _$CliqDatabase _db;
  $CliqDatabaseManager(this._db);
  $CredentialsTableManager get credentials =>
      $CredentialsTableManager(_db, _db.credentials);
  $IdentitiesTableManager get identities =>
      $IdentitiesTableManager(_db, _db.identities);
  $ConnectionsTableManager get connections =>
      $ConnectionsTableManager(_db, _db.connections);
}

class FindFullIdentityByIdResult {
  final int identityId;
  final String identityUsername;
  final int identityCredentialId;
  final int? credentialId;
  final CredentialType? credentialType;
  final String? credentialData;
  final String? credentialPassphrase;
  FindFullIdentityByIdResult({
    required this.identityId,
    required this.identityUsername,
    required this.identityCredentialId,
    this.credentialId,
    this.credentialType,
    this.credentialData,
    this.credentialPassphrase,
  });
}

class FindAllConnectionFullResult {
  final int connectionId;
  final String address;
  final int port;
  final int? identityId;
  final String? connectionUsername;
  final int? connectionCredentialRefId;
  final String? label;
  final ConnectionIcon icon;
  final String? color;
  final String? groupName;
  final int? identityId1;
  final String? identityUsername;
  final int? identityCredentialRefId;
  final int? identityCredentialIdExplicit;
  final CredentialType? identityCredentialType;
  final String? identityCredentialData;
  final String? identityCredentialPassphrase;
  final int? connectionCredentialIdExplicit;
  final CredentialType? connectionCredentialType;
  final String? connectionCredentialData;
  final String? connectionCredentialPassphrase;
  final int? effectiveCredentialId;
  final CredentialType? effectiveCredentialType;
  final String? effectiveCredentialData;
  final String? effectiveCredentialPassphrase;
  FindAllConnectionFullResult({
    required this.connectionId,
    required this.address,
    required this.port,
    this.identityId,
    this.connectionUsername,
    this.connectionCredentialRefId,
    this.label,
    required this.icon,
    this.color,
    this.groupName,
    this.identityId1,
    this.identityUsername,
    this.identityCredentialRefId,
    this.identityCredentialIdExplicit,
    this.identityCredentialType,
    this.identityCredentialData,
    this.identityCredentialPassphrase,
    this.connectionCredentialIdExplicit,
    this.connectionCredentialType,
    this.connectionCredentialData,
    this.connectionCredentialPassphrase,
    this.effectiveCredentialId,
    this.effectiveCredentialType,
    this.effectiveCredentialData,
    this.effectiveCredentialPassphrase,
  });
}
