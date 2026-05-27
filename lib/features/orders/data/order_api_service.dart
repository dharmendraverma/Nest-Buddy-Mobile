import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../cart/domain/cart_models.dart';
import '../../catalog/domain/catalog_models.dart';
import '../domain/order_models.dart';

final orderApiServiceProvider = Provider<OrderApiService>((ref) {
  return OrderApiService(ref.watch(dioProvider));
});

class OrderApiService {
  OrderApiService(this._dio);

  final Dio _dio;

  Future<List<OrderModel>> getUserOrders() async {
    final response = await _dio.get('/order/user-orders');
    return _unwrapList(response.data).map(_orderFromJson).toList();
  }

  Future<OrderModel> getOrder(String id) async {
    final response = await _dio.get('/order/$id');
    return _orderFromJson(_unwrapMap(response.data));
  }

  Future<OrderModel> createOrder({
    required List<CartLine> lines,
    String? shippingAddressId,
    String? notes,
  }) async {
    final response = await _dio.post(
      '/order',
      data: {
        if (shippingAddressId != null && shippingAddressId.isNotEmpty)
          'shippingAddressId': shippingAddressId,
        'items': [
          for (final line in lines)
            {
              'productId': line.product.id,
              if (line.variant?.id != null) 'variantId': line.variant!.id,
              'quantity': line.quantity,
            },
        ],
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return _orderFromJson(_unwrapMap(response.data), fallbackLines: lines);
  }

  OrderModel _orderFromJson(
    Map<String, dynamic> json, {
    List<CartLine> fallbackLines = const [],
  }) {
    final lines = _unwrapOrderItems(json)
        .map(_cartLineFromOrderItem)
        .whereType<CartLine>()
        .toList();
    return OrderModel(
      id: (json['id'] ?? json['_id'] ?? json['orderId'] ?? '').toString(),
      userId: (json['userId'] ?? json['user']?['id'] ?? '').toString(),
      status: (json['status'] ?? 'PLACED').toString(),
      items: lines.isEmpty ? fallbackLines : lines,
      total: _num(json['total'] ??
          json['totalAmount'] ??
          json['grandTotal'] ??
          json['amount']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  CartLine? _cartLineFromOrderItem(Map<String, dynamic> json) {
    final productJson = _map(json['product']) ??
        {
          'id': json['productId'],
          'name': json['productName'] ?? 'Product',
          'slug': json['productSlug'] ?? json['productId'] ?? 'product',
          'basePrice': json['price'] ?? json['salePrice'] ?? 0,
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
    return CartLine(
      id: (json['id'] ??
              json['_id'] ??
              '${product.id}:${variant?.id ?? variant?.sku ?? 'base'}')
          .toString(),
      product: product,
      variant: variant,
      quantity: _int(json['quantity']),
    );
  }

  List<Map<String, dynamic>> _unwrapList(Object? value) {
    if (value is List) return value.whereType<Map<String, dynamic>>().toList();
    if (value is Map<String, dynamic>) {
      for (final key in ['items', 'data', 'orders']) {
        final candidate = value[key];
        if (candidate is List) {
          return candidate.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }

  List<Map<String, dynamic>> _unwrapOrderItems(Map<String, dynamic> json) {
    for (final key in ['items', 'orderItems', 'lines']) {
      final candidate = json[key];
      if (candidate is List) {
        return candidate.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  Map<String, dynamic> _unwrapMap(Object? value) {
    if (value is Map<String, dynamic>) {
      final data = value['data'];
      if (data is Map<String, dynamic>) return data;
      return value;
    }
    return const {};
  }

  Map<String, dynamic>? _map(Object? value) {
    return value is Map<String, dynamic> ? value : null;
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
