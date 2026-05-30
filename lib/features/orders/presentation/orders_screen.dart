import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../cart/domain/cart_models.dart';
import '../domain/order_controller.dart';
import '../domain/order_models.dart';

final ordersListProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) {
  return ref.watch(orderControllerProvider.notifier).fetchOrders();
});

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersListProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        centerTitle: true,
        title: const Text('Orders'),
      ),
      body: orders.when(
        loading: () => const _OrdersLoading(),
        error: (error, _) => _OrdersEmpty(
          title: 'Unable to fetch orders',
          subtitle: error.toString(),
          onRetry: () => ref.invalidate(ordersListProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _OrdersEmpty(
              title: 'Your orders will appear here',
              subtitle: 'Place your first NestBuddy order to track it here.',
              onRetry: () => ref.invalidate(ordersListProvider),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(ordersListProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = items[index];
                return _OrderCard(
                  order: order,
                  onTap: () => context.go('/orders/${order.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrdersLoading extends StatelessWidget {
  const _OrdersLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 14),
          Text('Fetching your orders...'),
        ],
      ),
    );
  }
}

class _OrdersEmpty extends StatelessWidget {
  const _OrdersEmpty({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 58,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final orderNo = _orderNumber(order);
    final total = _orderTotal(order);
    final itemSummary = _itemSummary(order);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E8E5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Order #$orderNo',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF09263A),
                  fontSize: 19,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _dateLabel(order.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF1D2D75),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total Amount',
                      style: TextStyle(
                        color: Color(0xFF09263A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    formatPrice(total),
                    style: const TextStyle(
                      color: Color(0xFF09263A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              const _PaymentChip(),
              if (itemSummary.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  itemSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5E6B74),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_outlined, color: Color(0xFF09263A), size: 20),
          SizedBox(width: 9),
          Text(
            'Cash on delivery',
            style: TextStyle(
              color: Color(0xFF2B3540),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

String _orderNumber(OrderModel order) {
  final raw = (order.orderNumber == null || order.orderNumber!.isEmpty)
      ? order.id
      : order.orderNumber!;
  final cleaned =
      raw.replaceFirst(RegExp(r'^order\s*#?', caseSensitive: false), '');
  if (order.orderNumber != null && order.orderNumber!.isNotEmpty) {
    return cleaned.toUpperCase();
  }
  if (cleaned.length <= 10) return cleaned.toUpperCase();
  return cleaned.substring(cleaned.length - 10).toUpperCase();
}

num _orderTotal(OrderModel order) {
  if (order.total > 0) return order.total;
  return order.items.fold<num>(
    0,
    (sum, line) => sum + (_lineUnitPrice(line) * line.quantity),
  );
}

num _lineUnitPrice(CartLine line) {
  final variantPrice = line.variant?.price ?? 0;
  if (variantPrice > 0) return variantPrice;
  return line.product.price;
}

String _itemSummary(OrderModel order) {
  return order.items.map((line) {
    final variant = line.variant?.name;
    final name = variant == null || variant.isEmpty
        ? line.product.name
        : '${line.product.name} - $variant';
    return '${line.quantity} x $name';
  }).join(', ');
}

String _dateLabel(DateTime? date) {
  if (date == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final day = date.day;
  final suffix = switch (day) {
    1 || 21 || 31 => 'st',
    2 || 22 => 'nd',
    3 || 23 => 'rd',
    _ => 'th',
  };
  return '$day$suffix ${months[date.month - 1]},${date.year}';
}
