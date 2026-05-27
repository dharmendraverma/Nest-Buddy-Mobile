import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../address/domain/address_controller.dart';
import '../../cart/domain/cart_controller.dart';
import '../../orders/domain/order_controller.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final address = ref.watch(selectedAddressProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/cart'),
        centerTitle: true,
        title: const Text('Checkout'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            tileColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: const Icon(Icons.location_on_outlined),
            title: Text(address == null
                ? 'No address selected'
                : '${address.label} • ${address.fullName}'),
            subtitle: address == null
                ? null
                : Text(
                    '${address.line1}, ${address.city}, ${address.state} ${address.pincode}'),
            trailing: TextButton(
                onPressed: () => context.go('/address'),
                child: const Text('Change')),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order summary',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  for (final line in cart.lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                                  '${line.quantity} x ${line.product.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)),
                          Text(formatPrice(
                              (line.variant?.price ?? line.product.price) *
                                  line.quantity)),
                        ],
                      ),
                    ),
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(
                          child: Text('Total',
                              style: TextStyle(fontWeight: FontWeight.w900))),
                      Text(formatPrice(cart.subtotal),
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: cart.lines.isEmpty
                ? null
                : () => _placeOrder(context, ref, address?.id),
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Place order'),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(
      BuildContext context, WidgetRef ref, String? addressId) async {
    try {
      await ref
          .read(orderControllerProvider.notifier)
          .placeOrder(shippingAddressId: addressId);
      if (context.mounted) context.go('/orders');
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}
