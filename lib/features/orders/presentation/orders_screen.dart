import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../domain/order_controller.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderControllerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        centerTitle: true,
        title: const Text('Orders'),
      ),
      body: orders.isEmpty
          ? const Center(child: Text('Orders you place will appear here.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text('Order #${order.id}',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle:
                        Text('${order.status} • ${order.items.length} items'),
                    trailing: Text(formatPrice(order.total),
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    onTap: () => context.go('/orders/${order.id}'),
                  ),
                );
              },
            ),
    );
  }
}
