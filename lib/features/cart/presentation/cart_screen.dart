import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../address/domain/address_controller.dart';
import '../../orders/domain/order_controller.dart';
import '../domain/cart_controller.dart';

final paymentMethodProvider =
    StateProvider<PaymentMethod>((ref) => PaymentMethod.cod);

enum PaymentMethod {
  cod('Cash on delivery', Icons.payments_outlined),
  upi('UPI', Icons.account_balance_wallet_outlined),
  card('Card', Icons.credit_card);

  const PaymentMethod(this.label, this.icon);

  final String label;
  final IconData icon;
}

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final address = ref.watch(selectedAddressProvider);
    final payment = ref.watch(paymentMethodProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        centerTitle: true,
        title: const Text('Cart'),
      ),
      body: cart.lines.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  sliver: SliverToBoxAdapter(
                    child: _AddressBlock(
                      title: address == null
                          ? 'No address selected'
                          : '${address.label} • ${address.fullName}',
                      subtitle: address == null
                          ? 'Add an address before placing the order.'
                          : '${address.line1}, ${address.city}, ${address.state} ${address.pincode}',
                      onChange: () => context.go('/address'),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Items',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 170),
                  sliver: SliverList.separated(
                    itemCount: cart.lines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final line = cart.lines[index];
                      final price = line.variant?.price ?? line.product.price;
                      return Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.inventory_2_outlined),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                    if (line.variant != null)
                                      Text(
                                        line.variant!.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formatPrice(price),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filledTonal(
                                onPressed: () => ref
                                    .read(cartControllerProvider.notifier)
                                    .setQuantity(line.id, line.quantity - 1),
                                icon: const Icon(Icons.remove),
                              ),
                              SizedBox(
                                  width: 34,
                                  child:
                                      Center(child: Text('${line.quantity}'))),
                              IconButton.filledTonal(
                                onPressed: () => ref
                                    .read(cartControllerProvider.notifier)
                                    .setQuantity(line.id, line.quantity + 1),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: cart.lines.isEmpty
          ? null
          : _CartCheckoutBar(
              subtotal: cart.subtotal,
              payment: payment,
              onPaymentChanged: (value) =>
                  ref.read(paymentMethodProvider.notifier).state = value,
              onPlaceOrder: () => _placeOrder(context, ref, address?.id),
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

class _AddressBlock extends StatelessWidget {
  const _AddressBlock({
    required this.title,
    required this.subtitle,
    required this.onChange,
  });

  final String title;
  final String subtitle;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            TextButton(onPressed: onChange, child: const Text('Change')),
          ],
        ),
      ),
    );
  }
}

class _CartCheckoutBar extends StatelessWidget {
  const _CartCheckoutBar({
    required this.subtotal,
    required this.payment,
    required this.onPaymentChanged,
    required this.onPlaceOrder,
  });

  final num subtotal;
  final PaymentMethod payment;
  final ValueChanged<PaymentMethod> onPaymentChanged;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    PopupMenuButton<PaymentMethod>(
                      initialValue: payment,
                      onSelected: onPaymentChanged,
                      itemBuilder: (context) => [
                        for (final method in PaymentMethod.values)
                          PopupMenuItem(
                            value: method,
                            child: Row(
                              children: [
                                Icon(method.icon, size: 18),
                                const SizedBox(width: 8),
                                Text(method.label),
                              ],
                            ),
                          ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(payment.icon, size: 18),
                            const SizedBox(width: 6),
                            Flexible(
                                child: Text(payment.label,
                                    overflow: TextOverflow.ellipsis)),
                            const Icon(Icons.expand_more, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total'),
                  Text(
                    formatPrice(subtotal),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: onPlaceOrder,
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Place order'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
