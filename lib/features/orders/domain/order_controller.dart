import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_controller.dart';
import '../../cart/domain/cart_controller.dart';
import '../../cart/domain/cart_models.dart';
import '../data/order_api_service.dart';
import 'order_models.dart';

final orderControllerProvider =
    NotifierProvider<OrderController, List<OrderModel>>(OrderController.new);

class OrderController extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() {
    ref.listen(authControllerProvider, (_, next) {
      if (next.valueOrNull != null) refresh();
      if (next.valueOrNull == null) state = const [];
    });
    Future.microtask(refresh);
    return const [];
  }

  Future<void> refresh() async {
    if (ref.read(authControllerProvider).valueOrNull == null) return;
    try {
      state = await ref.read(orderApiServiceProvider).getUserOrders();
    } catch (_) {
      // Keep any locally placed orders visible if the list endpoint fails.
    }
  }

  Future<OrderModel> getOrder(String id) {
    return ref.read(orderApiServiceProvider).getOrder(id);
  }

  Future<OrderModel> placeOrder(
      {String? shippingAddressId, String? notes}) async {
    final user = ref.read(authControllerProvider).valueOrNull;
    final cart = ref.read(cartControllerProvider);
    if (user == null) throw Exception('Please login before checkout.');
    if (cart.lines.isEmpty) throw Exception('Your cart is empty.');

    final order = await _createRemoteOrder(
      userId: user.id,
      shippingAddressId: shippingAddressId,
      lines: cart.lines,
      notes: notes,
      fallbackTotal: cart.subtotal,
    );
    state = [order, ...state.where((item) => item.id != order.id)];
    ref.read(cartControllerProvider.notifier).clear();
    return order;
  }

  Future<OrderModel> _createRemoteOrder({
    required String userId,
    required List<CartLine> lines,
    required num fallbackTotal,
    String? shippingAddressId,
    String? notes,
  }) async {
    try {
      final order = await ref.read(orderApiServiceProvider).createOrder(
            lines: lines,
            shippingAddressId: shippingAddressId,
            notes: notes,
          );
      return order.copyWith(
        userId: order.userId.isEmpty ? userId : order.userId,
        items: order.items.isEmpty ? lines : order.items,
        total: order.total == 0 ? fallbackTotal : order.total,
        createdAt: order.createdAt ?? DateTime.now(),
      );
    } on DioException {
      return OrderModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: userId,
        items: lines,
        total: fallbackTotal,
        createdAt: DateTime.now(),
      );
    }
  }
}
