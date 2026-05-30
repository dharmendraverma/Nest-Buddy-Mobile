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
    try {
      final response = await _dio.get('/order/user-orders');
      return _unwrapList(response.data).map(_orderFromJson).toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
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
      orderNumber: (json['orderNumber'] ??
              json['orderNo'] ??
              json['number'] ??
              json['displayId'])
          ?.toString(),
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
    final variantJson = _map(json['variant']) ??
        _map(json['productVariant']) ??
        _map(json['variantSnapshot']);
    final unitPrice = _itemUnitPrice(json);
    final productImageUrl = _itemImageUrl(json, variantJson);
    final rawProductJson = _map(json['product']) ??
        _map(variantJson?['product']) ??
        {
          'id': json['productId'] ?? variantJson?['productId'],
          'name': json['productName'] ??
              variantJson?['productName'] ??
              variantJson?['product']?['name'] ??
              'Product',
          'slug': json['productSlug'] ??
              json['productId'] ??
              variantJson?['product']?['slug'] ??
              'product',
        };
    final productJson = {
      ...rawProductJson,
      'basePrice': rawProductJson['basePrice'] ??
          rawProductJson['price'] ??
          unitPrice ??
          json['basePrice'] ??
          json['mrp'] ??
          0,
      'salePrice': rawProductJson['salePrice'] ??
          json['salePrice'] ??
          json['sellingPrice'] ??
          unitPrice,
      if (productImageUrl != null) 'imageUrl': productImageUrl,
    };

    var product = ProductModel.fromJson(productJson);
    if (product.id.isEmpty) return null;
    ProductVariant? variant;
    if (variantJson != null) {
      variant = ProductVariant.fromJson(variantJson);
      if (unitPrice != null && variant.price == 0) {
        variant = variant.copyWith(price: unitPrice);
      }
    } else if (json['variantId'] != null) {
      variant = ProductVariant(
        id: json['variantId']?.toString(),
        sku: json['variantId']?.toString() ?? '',
        name: json['variantName']?.toString() ?? 'Variant',
        price: unitPrice ?? product.price,
      );
    }
    final fallbackPrice = unitPrice ?? variant?.price ?? product.price;
    if (fallbackPrice > 0 && product.price == 0) {
      product = product.copyWith(
        price: fallbackPrice,
        mrp: product.mrp == 0 ? fallbackPrice : product.mrp,
      );
    }
    if ((product.imageUrl == null || product.imageUrl!.isEmpty) &&
        productImageUrl != null) {
      product = product.copyWith(imageUrl: productImageUrl);
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
    if (value is List) {
      return [
        for (final item in value)
          if (item is Map) Map<String, dynamic>.from(item),
      ];
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      for (final key in ['items', 'data', 'orders']) {
        final candidate = map[key];
        if (candidate is List) {
          return [
            for (final item in candidate)
              if (item is Map) Map<String, dynamic>.from(item),
          ];
        }
      }
    }
    return const [];
  }

  List<Map<String, dynamic>> _unwrapOrderItems(Map<String, dynamic> json) {
    for (final key in ['items', 'orderItems', 'lines']) {
      final candidate = json[key];
      if (candidate is List) {
        return [
          for (final item in candidate)
            if (item is Map) Map<String, dynamic>.from(item),
        ];
      }
    }
    return const [];
  }

  Map<String, dynamic> _unwrapMap(Object? value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final data = map['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
      return map;
    }
    return const {};
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

  num? _itemUnitPrice(Map<String, dynamic> json) {
    for (final key in [
      'unitPrice',
      'priceAtPurchase',
      'salePrice',
      'sellingPrice',
      'variantPrice',
      'price',
      'mrp',
      'basePrice',
    ]) {
      final value = _num(json[key]);
      if (value > 0) return value;
    }
    final quantity = _int(json['quantity']);
    for (final key in ['lineTotal', 'totalPrice', 'subtotal', 'amount']) {
      final value = _num(json[key]);
      if (value > 0) return quantity <= 1 ? value : value / quantity;
    }
    return null;
  }

  String? _itemImageUrl(
      Map<String, dynamic> json, Map<String, dynamic>? variantJson) {
    for (final value in [
      json['imageUrl'],
      json['image'],
      json['thumbnail'],
      json['thumbnailUrl'],
      json['productImage'],
      json['productImageUrl'],
      _firstImageUrl(json['images']),
      _firstImageUrl(json['productImages']),
      variantJson?['imageUrl'],
      variantJson?['image'],
      _firstImageUrl(variantJson?['images']),
      _map(json['product'])?['imageUrl'],
      _firstImageUrl(_map(json['product'])?['images']),
      _map(variantJson?['product'])?['imageUrl'],
      _firstImageUrl(_map(variantJson?['product'])?['images']),
    ]) {
      final text = value?.toString();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  String? _firstImageUrl(Object? value) {
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map) {
        return (first['url'] ??
                first['imageUrl'] ??
                first['src'] ??
                first['path'] ??
                first['secureUrl'])
            ?.toString();
      }
      return first?.toString();
    }
    return null;
  }
}
