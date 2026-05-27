// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartLineImpl _$$CartLineImplFromJson(Map<String, dynamic> json) =>
    _$CartLineImpl(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      variant: json['variant'] == null
          ? null
          : ProductVariant.fromJson(json['variant'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$CartLineImplToJson(_$CartLineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'variant': instance.variant,
      'quantity': instance.quantity,
    };
