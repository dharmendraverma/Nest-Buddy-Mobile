// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_models.freezed.dart';
part 'catalog_models.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    String? imageUrl,
    String? parentId,
    @Default(<CategoryModel>[]) List<CategoryModel> children,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(_normalizeCategoryJson(json));
}

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String slug,
    @JsonKey(readValue: _readProductPrice, fromJson: _numFromJson)
    required num price,
    String? shortDescription,
    String? description,
    String? unit,
    String? imageUrl,
    @JsonKey(readValue: _readBrandName) String? brandName,
    String? categoryId,
    @Default(<ProductAttribute>[]) List<ProductAttribute> attributes,
    @Default(<ProductVariant>[]) List<ProductVariant> variants,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(_normalizeProductJson(json));
}

@freezed
class ProductAttribute with _$ProductAttribute {
  const factory ProductAttribute({
    required String name,
    required String value,
    String? unit,
  }) = _ProductAttribute;

  factory ProductAttribute.fromJson(Map<String, dynamic> json) =>
      _$ProductAttributeFromJson(json);
}

@freezed
class ProductVariant with _$ProductVariant {
  const factory ProductVariant({
    String? id,
    required String sku,
    required String name,
    @JsonKey(readValue: _readVariantPrice, fromJson: _numFromJson)
    required num price,
    @JsonKey(readValue: _readVariantQuantity, fromJson: _numFromJson)
    @Default(0)
    num quantity,
    String? color,
    String? size,
    String? theme,
  }) = _ProductVariant;

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantFromJson(_normalizeVariantJson(json));
}

@freezed
class ProductPage with _$ProductPage {
  const factory ProductPage({
    @Default(<ProductModel>[]) List<ProductModel> items,
    @Default(1) int page,
    @Default(20) int limit,
    @Default(false) bool hasMore,
  }) = _ProductPage;
}

Object? _readProductPrice(Map<dynamic, dynamic> json, String key) {
  return json['salePrice'] ?? json['basePrice'] ?? json[key];
}

Object? _readVariantPrice(Map<dynamic, dynamic> json, String key) {
  return json['salePrice'] ?? json['price'] ?? json[key];
}

Object? _readVariantQuantity(Map<dynamic, dynamic> json, String key) {
  final stock = json['stock'];
  if (stock is Map) return stock['quantity'] ?? json[key] ?? json['totalUnits'];
  return json[key] ?? json['totalUnits'];
}

Object? _readBrandName(Map<dynamic, dynamic> json, String key) {
  final brand = json['brand'];
  if (brand is Map) return brand['name'];
  return json[key] ?? json['brandName'];
}

num _numFromJson(Object? value) {
  if (value == null) return 0;
  if (value is num) return value;
  return num.tryParse(value.toString()) ?? 0;
}

Map<String, dynamic> _normalizeProductJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  normalized['id'] = _stringFromJson(normalized['id']);
  normalized['name'] = _stringFromJson(normalized['name']);
  normalized['slug'] = _stringFromJson(normalized['slug']);
  normalized['categoryId'] = _nullableStringFromJson(normalized['categoryId']);
  normalized['brandName'] =
      _nullableStringFromJson(_readBrandName(normalized, 'brandName'));
  normalized['imageUrl'] = _nullableStringFromJson(
      normalized['imageUrl'] ?? _readFirstImageUrl(normalized['images']));
  normalized['basePrice'] =
      _numFromJson(normalized['salePrice'] ?? normalized['basePrice']);
  normalized['variants'] = [
    for (final variant in _listFromJson(normalized['variants']))
      _normalizeVariantJson(variant),
  ];
  normalized['attributes'] = _listFromJson(normalized['attributes']);
  return normalized;
}

Map<String, dynamic> _normalizeCategoryJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  normalized['id'] = _stringFromJson(normalized['id']);
  normalized['name'] = _stringFromJson(normalized['name']);
  normalized['slug'] = _stringFromJson(normalized['slug']);
  normalized['description'] =
      _nullableStringFromJson(normalized['description']);
  normalized['imageUrl'] =
      _nullableStringFromJson(normalized['imageUrl'] ?? normalized['image']);
  normalized['parentId'] = _nullableStringFromJson(normalized['parentId']);
  normalized['children'] = [
    for (final child in _listFromJson(normalized['children']))
      _normalizeCategoryJson(child),
  ];
  return normalized;
}

Map<String, dynamic> _normalizeVariantJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  normalized['id'] = _nullableStringFromJson(normalized['id']);
  normalized['sku'] = _stringFromJson(normalized['sku']);
  normalized['name'] = _stringFromJson(normalized['name']);
  normalized['price'] =
      _numFromJson(normalized['salePrice'] ?? normalized['price']);
  normalized['quantity'] =
      _numFromJson(_readVariantQuantity(normalized, 'quantity'));
  return normalized;
}

List<Map<String, dynamic>> _listFromJson(Object? value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

String _stringFromJson(Object? value) => value?.toString() ?? '';

String? _nullableStringFromJson(Object? value) => value?.toString();

String? _readFirstImageUrl(Object? value) {
  if (value is List && value.isNotEmpty) {
    final first = value.first;
    if (first is Map) {
      return (first['url'] ?? first['imageUrl'] ?? first['src'])?.toString();
    }
    return first?.toString();
  }
  return null;
}
