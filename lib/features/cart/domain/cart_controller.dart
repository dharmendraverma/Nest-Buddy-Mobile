import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_controller.dart';
import '../../catalog/domain/catalog_models.dart';
import '../data/cart_api_service.dart';
import 'cart_models.dart';

final cartControllerProvider =
    NotifierProvider<CartController, CartSummary>(CartController.new);

class CartController extends Notifier<CartSummary> {
  @override
  CartSummary build() {
    ref.listen(authControllerProvider, (_, next) {
      if (next.valueOrNull != null) refresh();
      if (next.valueOrNull == null) clear();
    });
    Future.microtask(refresh);
    return const CartSummary();
  }

  Future<void> refresh() async {
    if (ref.read(authControllerProvider).valueOrNull == null) return;
    try {
      state = await ref.read(cartApiServiceProvider).getCart();
    } catch (_) {
      // Keep the current local cart if the remote cart is unavailable.
    }
  }

  Future<void> addProduct(ProductModel product,
      {ProductVariant? variant, int quantity = 1}) async {
    final key = '${product.id}:${variant?.id ?? variant?.sku ?? 'base'}';
    final lines = [...state.lines];
    final index = lines.indexWhere((line) => line.id == key);
    if (index >= 0) {
      final current = lines[index];
      lines[index] = current.copyWith(quantity: current.quantity + quantity);
    } else {
      lines.add(CartLine(
          id: key, product: product, variant: variant, quantity: quantity));
    }
    state = CartSummary(lines: lines);

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user != null) {
      try {
        await ref.read(cartApiServiceProvider).addItem(
              productId: product.id,
              variantId: variant?.id,
              quantity: quantity,
            );
      } catch (_) {
        // Keep the optimistic local cart; the backend cart endpoint is best effort.
      }
    }
  }

  void setQuantity(String lineId, int quantity) {
    if (quantity <= 0) {
      remove(lineId);
      return;
    }
    state = CartSummary(
      lines: [
        for (final line in state.lines)
          if (line.id == lineId) line.copyWith(quantity: quantity) else line,
      ],
    );
  }

  void remove(String lineId) {
    state = CartSummary(
        lines: state.lines.where((line) => line.id != lineId).toList());
  }

  void clear() {
    state = const CartSummary();
  }
}
