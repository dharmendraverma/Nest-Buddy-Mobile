// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryModelImpl _$$CategoryModelImplFromJson(Map<String, dynamic> json) =>
    _$CategoryModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      parentId: json['parentId'] as String?,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CategoryModel>[],
    );

Map<String, dynamic> _$$CategoryModelImplToJson(_$CategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'parentId': instance.parentId,
      'children': instance.children,
    };

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: _numFromJson(_readProductPrice(json, 'price')),
      shortDescription: json['shortDescription'] as String?,
      description: json['description'] as String?,
      unit: json['unit'] as String?,
      imageUrl: json['imageUrl'] as String?,
      brandName: _readBrandName(json, 'brandName') as String?,
      categoryId: json['categoryId'] as String?,
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ProductAttribute>[],
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ProductVariant>[],
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'price': instance.price,
      'shortDescription': instance.shortDescription,
      'description': instance.description,
      'unit': instance.unit,
      'imageUrl': instance.imageUrl,
      'brandName': instance.brandName,
      'categoryId': instance.categoryId,
      'attributes': instance.attributes,
      'variants': instance.variants,
    };

_$ProductAttributeImpl _$$ProductAttributeImplFromJson(
        Map<String, dynamic> json) =>
    _$ProductAttributeImpl(
      name: json['name'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$$ProductAttributeImplToJson(
        _$ProductAttributeImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'unit': instance.unit,
    };

_$ProductVariantImpl _$$ProductVariantImplFromJson(Map<String, dynamic> json) =>
    _$ProductVariantImpl(
      id: json['id'] as String?,
      sku: json['sku'] as String,
      name: json['name'] as String,
      price: _numFromJson(_readVariantPrice(json, 'price')),
      quantity: _readVariantQuantity(json, 'quantity') == null
          ? 0
          : _numFromJson(_readVariantQuantity(json, 'quantity')),
      color: json['color'] as String?,
      size: json['size'] as String?,
      theme: json['theme'] as String?,
    );

Map<String, dynamic> _$$ProductVariantImplToJson(
        _$ProductVariantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'name': instance.name,
      'price': instance.price,
      'quantity': instance.quantity,
      'color': instance.color,
      'size': instance.size,
      'theme': instance.theme,
    };
