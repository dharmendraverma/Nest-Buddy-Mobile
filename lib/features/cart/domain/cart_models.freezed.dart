// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CartLine _$CartLineFromJson(Map<String, dynamic> json) {
  return _CartLine.fromJson(json);
}

/// @nodoc
mixin _$CartLine {
  String get id => throw _privateConstructorUsedError;
  ProductModel get product => throw _privateConstructorUsedError;
  ProductVariant? get variant => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;

  /// Serializes this CartLine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartLineCopyWith<CartLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartLineCopyWith<$Res> {
  factory $CartLineCopyWith(CartLine value, $Res Function(CartLine) then) =
      _$CartLineCopyWithImpl<$Res, CartLine>;
  @useResult
  $Res call(
      {String id, ProductModel product, ProductVariant? variant, int quantity});

  $ProductModelCopyWith<$Res> get product;
  $ProductVariantCopyWith<$Res>? get variant;
}

/// @nodoc
class _$CartLineCopyWithImpl<$Res, $Val extends CartLine>
    implements $CartLineCopyWith<$Res> {
  _$CartLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? product = null,
    Object? variant = freezed,
    Object? quantity = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      product: null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductModel,
      variant: freezed == variant
          ? _value.variant
          : variant // ignore: cast_nullable_to_non_nullable
              as ProductVariant?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of CartLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductModelCopyWith<$Res> get product {
    return $ProductModelCopyWith<$Res>(_value.product, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
  }

  /// Create a copy of CartLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductVariantCopyWith<$Res>? get variant {
    if (_value.variant == null) {
      return null;
    }

    return $ProductVariantCopyWith<$Res>(_value.variant!, (value) {
      return _then(_value.copyWith(variant: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartLineImplCopyWith<$Res>
    implements $CartLineCopyWith<$Res> {
  factory _$$CartLineImplCopyWith(
          _$CartLineImpl value, $Res Function(_$CartLineImpl) then) =
      __$$CartLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, ProductModel product, ProductVariant? variant, int quantity});

  @override
  $ProductModelCopyWith<$Res> get product;
  @override
  $ProductVariantCopyWith<$Res>? get variant;
}

/// @nodoc
class __$$CartLineImplCopyWithImpl<$Res>
    extends _$CartLineCopyWithImpl<$Res, _$CartLineImpl>
    implements _$$CartLineImplCopyWith<$Res> {
  __$$CartLineImplCopyWithImpl(
      _$CartLineImpl _value, $Res Function(_$CartLineImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? product = null,
    Object? variant = freezed,
    Object? quantity = null,
  }) {
    return _then(_$CartLineImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      product: null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductModel,
      variant: freezed == variant
          ? _value.variant
          : variant // ignore: cast_nullable_to_non_nullable
              as ProductVariant?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartLineImpl implements _CartLine {
  const _$CartLineImpl(
      {required this.id,
      required this.product,
      this.variant,
      this.quantity = 1});

  factory _$CartLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartLineImplFromJson(json);

  @override
  final String id;
  @override
  final ProductModel product;
  @override
  final ProductVariant? variant;
  @override
  @JsonKey()
  final int quantity;

  @override
  String toString() {
    return 'CartLine(id: $id, product: $product, variant: $variant, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartLineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.product, product) || other.product == product) &&
            (identical(other.variant, variant) || other.variant == variant) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, product, variant, quantity);

  /// Create a copy of CartLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartLineImplCopyWith<_$CartLineImpl> get copyWith =>
      __$$CartLineImplCopyWithImpl<_$CartLineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartLineImplToJson(
      this,
    );
  }
}

abstract class _CartLine implements CartLine {
  const factory _CartLine(
      {required final String id,
      required final ProductModel product,
      final ProductVariant? variant,
      final int quantity}) = _$CartLineImpl;

  factory _CartLine.fromJson(Map<String, dynamic> json) =
      _$CartLineImpl.fromJson;

  @override
  String get id;
  @override
  ProductModel get product;
  @override
  ProductVariant? get variant;
  @override
  int get quantity;

  /// Create a copy of CartLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartLineImplCopyWith<_$CartLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CartSummary {
  List<CartLine> get lines => throw _privateConstructorUsedError;

  /// Create a copy of CartSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartSummaryCopyWith<CartSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartSummaryCopyWith<$Res> {
  factory $CartSummaryCopyWith(
          CartSummary value, $Res Function(CartSummary) then) =
      _$CartSummaryCopyWithImpl<$Res, CartSummary>;
  @useResult
  $Res call({List<CartLine> lines});
}

/// @nodoc
class _$CartSummaryCopyWithImpl<$Res, $Val extends CartSummary>
    implements $CartSummaryCopyWith<$Res> {
  _$CartSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lines = null,
  }) {
    return _then(_value.copyWith(
      lines: null == lines
          ? _value.lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<CartLine>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartSummaryImplCopyWith<$Res>
    implements $CartSummaryCopyWith<$Res> {
  factory _$$CartSummaryImplCopyWith(
          _$CartSummaryImpl value, $Res Function(_$CartSummaryImpl) then) =
      __$$CartSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CartLine> lines});
}

/// @nodoc
class __$$CartSummaryImplCopyWithImpl<$Res>
    extends _$CartSummaryCopyWithImpl<$Res, _$CartSummaryImpl>
    implements _$$CartSummaryImplCopyWith<$Res> {
  __$$CartSummaryImplCopyWithImpl(
      _$CartSummaryImpl _value, $Res Function(_$CartSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lines = null,
  }) {
    return _then(_$CartSummaryImpl(
      lines: null == lines
          ? _value._lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<CartLine>,
    ));
  }
}

/// @nodoc

class _$CartSummaryImpl extends _CartSummary {
  const _$CartSummaryImpl({final List<CartLine> lines = const <CartLine>[]})
      : _lines = lines,
        super._();

  final List<CartLine> _lines;
  @override
  @JsonKey()
  List<CartLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  String toString() {
    return 'CartSummary(lines: $lines)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartSummaryImpl &&
            const DeepCollectionEquality().equals(other._lines, _lines));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_lines));

  /// Create a copy of CartSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartSummaryImplCopyWith<_$CartSummaryImpl> get copyWith =>
      __$$CartSummaryImplCopyWithImpl<_$CartSummaryImpl>(this, _$identity);
}

abstract class _CartSummary extends CartSummary {
  const factory _CartSummary({final List<CartLine> lines}) = _$CartSummaryImpl;
  const _CartSummary._() : super._();

  @override
  List<CartLine> get lines;

  /// Create a copy of CartSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartSummaryImplCopyWith<_$CartSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
