import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/network_image_box.dart';
import '../../cart/domain/cart_models.dart';
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
        data: (order) => _OrderDetailContent(order: order),
      ),
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  const _OrderDetailContent({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final orderNo = _orderNumber(order);
    final subtotal = _orderSubtotal(order);
    final total = order.total == 0 ? subtotal : order.total;
    final totalQty =
        order.items.fold<int>(0, (sum, line) => sum + line.quantity);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _OrderHeader(order: order, orderNo: orderNo, total: total),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Items',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '$totalQty items',
              style: const TextStyle(
                color: Color(0xFF0D5C63),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final line in order.items) ...[
          _OrderItemTile(line: line),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        _SummaryCard(subtotal: subtotal, total: total),
      ],
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.order,
    required this.orderNo,
    required this.total,
  });

  final OrderModel order;
  final String orderNo;
  final num total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF09263A),
                fontSize: 21,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Color(0xFF09263A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  formatPrice(total),
                  style: const TextStyle(
                    color: Color(0xFF09263A),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            const _PaymentChip(),
          ],
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

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final variant = line.variant?.name;
    final price = _lineUnitPrice(line);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E8E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            NetworkImageBox(
              imageUrl: line.product.imageUrl,
              width: 72,
              height: 72,
              borderRadius: 12,
              backgroundColor: const Color(0xFFEAF4F2),
              iconColor: const Color(0xFF0D5C63),
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
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  if (variant != null && variant.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      variant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0D5C63),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 7),
                  Text(
                    'Qty ${line.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatPrice(price),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.subtotal, required this.total});

  final num subtotal;
  final num total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E8E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Order summary',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _SummaryRow(label: 'Subtotal', value: formatPrice(subtotal)),
            _SummaryRow(label: 'Delivery', value: subtotal == 0 ? '-' : 'Free'),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Total',
              value: formatPrice(total),
              strong: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)
        : const TextStyle(fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: style),
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

num _orderSubtotal(OrderModel order) {
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
