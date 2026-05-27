import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../domain/order_controller.dart';
import '../domain/order_models.dart';

final orderDetailProvider =
    FutureProvider.autoDispose.family<OrderModel, String>((ref, id) {
  return ref.read(orderControllerProvider.notifier).getOrder(id);
});

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderDetailProvider(orderId));
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/orders'),
        centerTitle: true,
        title: const Text('Order detail'),
      ),
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (order) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text('Order #${order.id}',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(order.status),
                trailing: Text(formatPrice(order.total),
                    style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Items',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final line in order.items)
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(line.product.name),
                  subtitle: Text(
                    [
                      if (line.variant != null) line.variant!.name,
                      'Qty ${line.quantity}',
                    ].join(' • '),
                  ),
                  trailing: Text(
                    formatPrice(line.variant?.price ?? line.product.price),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
