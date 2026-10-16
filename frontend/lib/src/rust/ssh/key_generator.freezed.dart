// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'key_generator.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SshKeyType {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SshKeyType);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SshKeyType()';
}


}

/// @nodoc
class $SshKeyTypeCopyWith<$Res>  {
$SshKeyTypeCopyWith(SshKeyType _, $Res Function(SshKeyType) __);
}


/// Adds pattern-matching-related methods to [SshKeyType].
extension SshKeyTypePatterns on SshKeyType {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SshKeyType_Ed25519 value)?  ed25519,TResult Function( SshKeyType_Ecdsa value)?  ecdsa,TResult Function( SshKeyType_Rsa value)?  rsa,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SshKeyType_Ed25519() when ed25519 != null:
return ed25519(_that);case SshKeyType_Ecdsa() when ecdsa != null:
return ecdsa(_that);case SshKeyType_Rsa() when rsa != null:
return rsa(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SshKeyType_Ed25519 value)  ed25519,required TResult Function( SshKeyType_Ecdsa value)  ecdsa,required TResult Function( SshKeyType_Rsa value)  rsa,}){
final _that = this;
switch (_that) {
case SshKeyType_Ed25519():
return ed25519(_that);case SshKeyType_Ecdsa():
return ecdsa(_that);case SshKeyType_Rsa():
return rsa(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SshKeyType_Ed25519 value)?  ed25519,TResult? Function( SshKeyType_Ecdsa value)?  ecdsa,TResult? Function( SshKeyType_Rsa value)?  rsa,}){
final _that = this;
switch (_that) {
case SshKeyType_Ed25519() when ed25519 != null:
return ed25519(_that);case SshKeyType_Ecdsa() when ecdsa != null:
return ecdsa(_that);case SshKeyType_Rsa() when rsa != null:
return rsa(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  ed25519,TResult Function( EcdsaBits field0)?  ecdsa,TResult Function( RsaBits field0)?  rsa,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SshKeyType_Ed25519() when ed25519 != null:
return ed25519();case SshKeyType_Ecdsa() when ecdsa != null:
return ecdsa(_that.field0);case SshKeyType_Rsa() when rsa != null:
return rsa(_that.field0);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  ed25519,required TResult Function( EcdsaBits field0)  ecdsa,required TResult Function( RsaBits field0)  rsa,}) {final _that = this;
switch (_that) {
case SshKeyType_Ed25519():
return ed25519();case SshKeyType_Ecdsa():
return ecdsa(_that.field0);case SshKeyType_Rsa():
return rsa(_that.field0);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  ed25519,TResult? Function( EcdsaBits field0)?  ecdsa,TResult? Function( RsaBits field0)?  rsa,}) {final _that = this;
switch (_that) {
case SshKeyType_Ed25519() when ed25519 != null:
return ed25519();case SshKeyType_Ecdsa() when ecdsa != null:
return ecdsa(_that.field0);case SshKeyType_Rsa() when rsa != null:
return rsa(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class SshKeyType_Ed25519 extends SshKeyType {
  const SshKeyType_Ed25519(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SshKeyType_Ed25519);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SshKeyType.ed25519()';
}


}




/// @nodoc


class SshKeyType_Ecdsa extends SshKeyType {
  const SshKeyType_Ecdsa(this.field0): super._();
  

 final  EcdsaBits field0;

/// Create a copy of SshKeyType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SshKeyType_EcdsaCopyWith<SshKeyType_Ecdsa> get copyWith => _$SshKeyType_EcdsaCopyWithImpl<SshKeyType_Ecdsa>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SshKeyType_Ecdsa&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'SshKeyType.ecdsa(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $SshKeyType_EcdsaCopyWith<$Res> implements $SshKeyTypeCopyWith<$Res> {
  factory $SshKeyType_EcdsaCopyWith(SshKeyType_Ecdsa value, $Res Function(SshKeyType_Ecdsa) _then) = _$SshKeyType_EcdsaCopyWithImpl;
@useResult
$Res call({
 EcdsaBits field0
});




}
/// @nodoc
class _$SshKeyType_EcdsaCopyWithImpl<$Res>
    implements $SshKeyType_EcdsaCopyWith<$Res> {
  _$SshKeyType_EcdsaCopyWithImpl(this._self, this._then);

  final SshKeyType_Ecdsa _self;
  final $Res Function(SshKeyType_Ecdsa) _then;

/// Create a copy of SshKeyType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(SshKeyType_Ecdsa(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as EcdsaBits,
  ));
}


}

/// @nodoc


class SshKeyType_Rsa extends SshKeyType {
  const SshKeyType_Rsa(this.field0): super._();
  

 final  RsaBits field0;

/// Create a copy of SshKeyType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SshKeyType_RsaCopyWith<SshKeyType_Rsa> get copyWith => _$SshKeyType_RsaCopyWithImpl<SshKeyType_Rsa>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SshKeyType_Rsa&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'SshKeyType.rsa(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $SshKeyType_RsaCopyWith<$Res> implements $SshKeyTypeCopyWith<$Res> {
  factory $SshKeyType_RsaCopyWith(SshKeyType_Rsa value, $Res Function(SshKeyType_Rsa) _then) = _$SshKeyType_RsaCopyWithImpl;
@useResult
$Res call({
 RsaBits field0
});




}
/// @nodoc
class _$SshKeyType_RsaCopyWithImpl<$Res>
    implements $SshKeyType_RsaCopyWith<$Res> {
  _$SshKeyType_RsaCopyWithImpl(this._self, this._then);

  final SshKeyType_Rsa _self;
  final $Res Function(SshKeyType_Rsa) _then;

/// Create a copy of SshKeyType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(SshKeyType_Rsa(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as RsaBits,
  ));
}


}

// dart format on
