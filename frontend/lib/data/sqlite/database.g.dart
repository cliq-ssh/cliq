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
  @override
  List<GeneratedColumn> get $columns => [id, type, data];
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
  const Credential({required this.id, required this.type, required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<int>(Credentials.$convertertype.toSql(type));
    }
    map['data'] = Variable<String>(data);
    return map;
  }

  CredentialsCompanion toCompanion(bool nullToAbsent) {
    return CredentialsCompanion(
      id: Value(id),
      type: Value(type),
      data: Value(data),
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
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<int>(Credentials.$convertertype.toJson(type)),
      'data': serializer.toJson<String>(data),
    };
  }

  Credential copyWith({int? id, CredentialType? type, String? data}) =>
      Credential(
        id: id ?? this.id,
        type: type ?? this.type,
        data: data ?? this.data,
      );
  Credential copyWithCompanion(CredentialsCompanion data) {
    return Credential(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Credential(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Credential &&
          other.id == this.id &&
          other.type == this.type &&
          other.data == this.data);
}

class CredentialsCompanion extends UpdateCompanion<Credential> {
  final Value<int> id;
  final Value<CredentialType> type;
  final Value<String> data;
  const CredentialsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.data = const Value.absent(),
  });
  CredentialsCompanion.insert({
    this.id = const Value.absent(),
    required CredentialType type,
    required String data,
  }) : type = Value(type),
       data = Value(data);
  static Insertable<Credential> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<String>? data,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (data != null) 'data': data,
    });
  }

  CredentialsCompanion copyWith({
    Value<int>? id,
    Value<CredentialType>? type,
    Value<String>? data,
  }) {
    return CredentialsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CredentialsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('data: $data')
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
  static const VerificationMeta _passphraseMeta = const VerificationMeta(
    'passphrase',
  );
  late final GeneratedColumn<String> passphrase = GeneratedColumn<String>(
    'passphrase',
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
  static const VerificationMeta _certificateMeta = const VerificationMeta(
    'certificate',
  );
  late final GeneratedColumn<String> certificate = GeneratedColumn<String>(
    'certificate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    passphrase,
    privateKey,
    publicKey,
    certificate,
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
    if (data.containsKey('passphrase')) {
      context.handle(
        _passphraseMeta,
        passphrase.isAcceptableOrUnknown(data['passphrase']!, _passphraseMeta),
      );
    } else if (isInserting) {
      context.missing(_passphraseMeta);
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
    if (data.containsKey('certificate')) {
      context.handle(
        _certificateMeta,
        certificate.isAcceptableOrUnknown(
          data['certificate']!,
          _certificateMeta,
        ),
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
      passphrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passphrase'],
      )!,
      privateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}private_key'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      ),
      certificate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}certificate'],
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
  final String passphrase;
  final String privateKey;
  final String? publicKey;
  final String? certificate;
  const Key({
    required this.id,
    required this.passphrase,
    required this.privateKey,
    this.publicKey,
    this.certificate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['passphrase'] = Variable<String>(passphrase);
    map['private_key'] = Variable<String>(privateKey);
    if (!nullToAbsent || publicKey != null) {
      map['public_key'] = Variable<String>(publicKey);
    }
    if (!nullToAbsent || certificate != null) {
      map['certificate'] = Variable<String>(certificate);
    }
    return map;
  }

  KeysCompanion toCompanion(bool nullToAbsent) {
    return KeysCompanion(
      id: Value(id),
      passphrase: Value(passphrase),
      privateKey: Value(privateKey),
      publicKey: publicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKey),
      certificate: certificate == null && nullToAbsent
          ? const Value.absent()
          : Value(certificate),
    );
  }

  factory Key.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Key(
      id: serializer.fromJson<int>(json['id']),
      passphrase: serializer.fromJson<String>(json['passphrase']),
      privateKey: serializer.fromJson<String>(json['private_key']),
      publicKey: serializer.fromJson<String?>(json['public_key']),
      certificate: serializer.fromJson<String?>(json['certificate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'passphrase': serializer.toJson<String>(passphrase),
      'private_key': serializer.toJson<String>(privateKey),
      'public_key': serializer.toJson<String?>(publicKey),
      'certificate': serializer.toJson<String?>(certificate),
    };
  }

  Key copyWith({
    int? id,
    String? passphrase,
    String? privateKey,
    Value<String?> publicKey = const Value.absent(),
    Value<String?> certificate = const Value.absent(),
  }) => Key(
    id: id ?? this.id,
    passphrase: passphrase ?? this.passphrase,
    privateKey: privateKey ?? this.privateKey,
    publicKey: publicKey.present ? publicKey.value : this.publicKey,
    certificate: certificate.present ? certificate.value : this.certificate,
  );
  Key copyWithCompanion(KeysCompanion data) {
    return Key(
      id: data.id.present ? data.id.value : this.id,
      passphrase: data.passphrase.present
          ? data.passphrase.value
          : this.passphrase,
      privateKey: data.privateKey.present
          ? data.privateKey.value
          : this.privateKey,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      certificate: data.certificate.present
          ? data.certificate.value
          : this.certificate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Key(')
          ..write('id: $id, ')
          ..write('passphrase: $passphrase, ')
          ..write('privateKey: $privateKey, ')
          ..write('publicKey: $publicKey, ')
          ..write('certificate: $certificate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, passphrase, privateKey, publicKey, certificate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Key &&
          other.id == this.id &&
          other.passphrase == this.passphrase &&
          other.privateKey == this.privateKey &&
          other.publicKey == this.publicKey &&
          other.certificate == this.certificate);
}

class KeysCompanion extends UpdateCompanion<Key> {
  final Value<int> id;
  final Value<String> passphrase;
  final Value<String> privateKey;
  final Value<String?> publicKey;
  final Value<String?> certificate;
  const KeysCompanion({
    this.id = const Value.absent(),
    this.passphrase = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.certificate = const Value.absent(),
  });
  KeysCompanion.insert({
    this.id = const Value.absent(),
    required String passphrase,
    required String privateKey,
    this.publicKey = const Value.absent(),
    this.certificate = const Value.absent(),
  }) : passphrase = Value(passphrase),
       privateKey = Value(privateKey);
  static Insertable<Key> custom({
    Expression<int>? id,
    Expression<String>? passphrase,
    Expression<String>? privateKey,
    Expression<String>? publicKey,
    Expression<String>? certificate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (passphrase != null) 'passphrase': passphrase,
      if (privateKey != null) 'private_key': privateKey,
      if (publicKey != null) 'public_key': publicKey,
      if (certificate != null) 'certificate': certificate,
    });
  }

  KeysCompanion copyWith({
    Value<int>? id,
    Value<String>? passphrase,
    Value<String>? privateKey,
    Value<String?>? publicKey,
    Value<String?>? certificate,
  }) {
    return KeysCompanion(
      id: id ?? this.id,
      passphrase: passphrase ?? this.passphrase,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      certificate: certificate ?? this.certificate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (passphrase.present) {
      map['passphrase'] = Variable<String>(passphrase.value);
    }
    if (privateKey.present) {
      map['private_key'] = Variable<String>(privateKey.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (certificate.present) {
      map['certificate'] = Variable<String>(certificate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeysCompanion(')
          ..write('id: $id, ')
          ..write('passphrase: $passphrase, ')
          ..write('privateKey: $privateKey, ')
          ..write('publicKey: $publicKey, ')
          ..write('certificate: $certificate')
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
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
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
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
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
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  Connections createAlias(String alias) {
    return Connections(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK(identity_id IS NOT NULL OR(username IS NOT NULL AND credential_id IS NOT NULL))',
  ];
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
  final String? icon;
  final String? color;
  const Connection({
    required this.id,
    required this.address,
    required this.port,
    this.identityId,
    this.username,
    this.credentialId,
    this.label,
    this.icon,
    this.color,
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
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
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
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
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
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
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
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
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
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
  }) => Connection(
    id: id ?? this.id,
    address: address ?? this.address,
    port: port ?? this.port,
    identityId: identityId.present ? identityId.value : this.identityId,
    username: username.present ? username.value : this.username,
    credentialId: credentialId.present ? credentialId.value : this.credentialId,
    label: label.present ? label.value : this.label,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
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
          ..write('color: $color')
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
          other.color == this.color);
}

class ConnectionsCompanion extends UpdateCompanion<Connection> {
  final Value<int> id;
  final Value<String> address;
  final Value<int> port;
  final Value<int?> identityId;
  final Value<String?> username;
  final Value<int?> credentialId;
  final Value<String?> label;
  final Value<String?> icon;
  final Value<String?> color;
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
    Expression<String>? icon,
    Expression<String>? color,
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
    Value<String?>? icon,
    Value<String?>? color,
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
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
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
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

abstract class _$CliqDatabase extends GeneratedDatabase {
  _$CliqDatabase(QueryExecutor e) : super(e);
  $CliqDatabaseManager get managers => $CliqDatabaseManager(this);
  late final Credentials credentials = Credentials(this);
  late final Identities identities = Identities(this);
  late final Keys keys = Keys(this);
  late final Connections connections = Connections(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    credentials,
    identities,
    keys,
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
    });
typedef $CredentialsUpdateCompanionBuilder =
    CredentialsCompanion Function({
      Value<int> id,
      Value<CredentialType> type,
      Value<String> data,
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
              }) => CredentialsCompanion(id: id, type: type, data: data),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required CredentialType type,
                required String data,
              }) => CredentialsCompanion.insert(id: id, type: type, data: data),
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
typedef $KeysCreateCompanionBuilder =
    KeysCompanion Function({
      Value<int> id,
      required String passphrase,
      required String privateKey,
      Value<String?> publicKey,
      Value<String?> certificate,
    });
typedef $KeysUpdateCompanionBuilder =
    KeysCompanion Function({
      Value<int> id,
      Value<String> passphrase,
      Value<String> privateKey,
      Value<String?> publicKey,
      Value<String?> certificate,
    });

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

  ColumnFilters<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
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

  ColumnFilters<String> get certificate => $composableBuilder(
    column: $table.certificate,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
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

  ColumnOrderings<String> get certificate => $composableBuilder(
    column: $table.certificate,
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

  GeneratedColumn<String> get passphrase => $composableBuilder(
    column: $table.passphrase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privateKey => $composableBuilder(
    column: $table.privateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get certificate => $composableBuilder(
    column: $table.certificate,
    builder: (column) => column,
  );
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
          (Key, BaseReferences<_$CliqDatabase, Keys, Key>),
          Key,
          PrefetchHooks Function()
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
                Value<String> passphrase = const Value.absent(),
                Value<String> privateKey = const Value.absent(),
                Value<String?> publicKey = const Value.absent(),
                Value<String?> certificate = const Value.absent(),
              }) => KeysCompanion(
                id: id,
                passphrase: passphrase,
                privateKey: privateKey,
                publicKey: publicKey,
                certificate: certificate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String passphrase,
                required String privateKey,
                Value<String?> publicKey = const Value.absent(),
                Value<String?> certificate = const Value.absent(),
              }) => KeysCompanion.insert(
                id: id,
                passphrase: passphrase,
                privateKey: privateKey,
                publicKey: publicKey,
                certificate: certificate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Key, BaseReferences<_$CliqDatabase, Keys, Key>),
      Key,
      PrefetchHooks Function()
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
      Value<String?> icon,
      Value<String?> color,
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
      Value<String?> icon,
      Value<String?> color,
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

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
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

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
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

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

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
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
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
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
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
  $KeysTableManager get keys => $KeysTableManager(_db, _db.keys);
  $ConnectionsTableManager get connections =>
      $ConnectionsTableManager(_db, _db.connections);
}
