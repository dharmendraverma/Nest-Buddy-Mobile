import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../catalog/domain/catalog_models.dart';
import '../domain/cart_models.dart';

final cartApiServiceProvider = Provider<CartApiService>((ref) {
  return CartApiService(ref.watch(dioProvider));
});

class CartApiService {
  CartApiService(this._dio);

  final Dio _dio;

  Future<CartSummary> getCart() async {
    final response = await _dio.get('/cart');
    final items = _unwrapItems(response.data);
    return CartSummary(
        lines: items.map(_lineFromJson).whereType<CartLine>().toList());
  }

  Future<void> addItem({
    required String productId,
    String? variantId,
    required int quantity,
  }) async {
    await _dio.post(
      '/cart/items',
      data: {
        'productId': productId,
        if (variantId != null && variantId.isNotEmpty) 'variantId': variantId,
        'quantity': quantity,
      },
    );
  }

  CartLine? _lineFromJson(Map<String, dynamic> json) {
    final productJson = _map(json['product']) ??
        {
          'id': json['productId'],
          'name': json['productName'] ?? 'Product',
          'slug': json['productSlug'] ?? json['productId'] ?? 'product',
          'basePrice': json['price'] ?? json['salePrice'] ?? 0,
          'salePrice': json['salePrice'],
          'imageUrl': json['imageUrl'] ??
              json['productImage'] ??
              json['productImageUrl'],
          'images': json['images'] ?? json['productImages'],
        };
    final product = ProductModel.fromJson(productJson);
    if (product.id.isEmpty) return null;

    ProductVariant? variant;
    final variantJson = _map(json['variant']);
    if (variantJson != null) {
      variant = ProductVariant.fromJson(variantJson);
    } else if (json['variantId'] != null) {
      variant = ProductVariant(
        id: json['variantId']?.toString(),
        sku: json['variantId']?.toString() ?? '',
        name: json['variantName']?.toString() ?? 'Variant',
        price: _num(json['price'] ?? json['salePrice'] ?? product.price),
      );
    }

    final lineId = (json['id'] ??
            json['_id'] ??
            '${product.id}:${variant?.id ?? variant?.sku ?? 'base'}')
        .toString();
    return CartLine(
      id: lineId,
      product: product,
      variant: variant,
      quantity: _int(json['quantity']),
    );
  }

  List<Map<String, dynamic>> _unwrapItems(Object? value) {
    if (value is List) {
      return [
        for (final item in value)
          if (item is Map) Map<String, dynamic>.from(item),
      ];
    }
    if (value is Map<String, dynamic>) {
      for (final key in ['items', 'lines', 'cartItems', 'data']) {
        final candidate = value[key];
        if (candidate is List) {
          return candidate.whereType<Map<String, dynamic>>().toList();
        }
        if (candidate is Map<String, dynamic>) {
          final nested = _unwrapItems(candidate);
          if (nested.isNotEmpty) return nested;
        }
      }
    }
    return const [];
  }

  Map<String, dynamic>? _map(Object? value) {
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  int _int(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 1;
  }

  num _num(Object? value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}
