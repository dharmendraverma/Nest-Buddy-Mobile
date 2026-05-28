import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/price_formatter.dart';
import '../../../cart/domain/cart_controller.dart';
import '../../domain/catalog_models.dart';

Future<void> showVariantBottomSheet(
    BuildContext context, WidgetRef ref, ProductModel product) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _VariantSheet(product: product, ref: ref),
  );
}

class _VariantSheet extends StatefulWidget {
  const _VariantSheet({required this.product, required this.ref});

  final ProductModel product;
  final WidgetRef ref;

  @override
  State<_VariantSheet> createState() => _VariantSheetState();
}

class _VariantSheetState extends State<_VariantSheet> {
  ProductVariant? selected;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    selected =
        widget.product.variants.isEmpty ? null : widget.product.variants.first;
  }

  @override
  Widget build(BuildContext context) {
    final variants = widget.product.variants;
    final activePrice = selected?.price ?? widget.product.price;
    final total = activePrice * quantity;

    return DraggableScrollableSheet(
      initialChildSize: variants.length > 4 ? 0.78 : 0.66,
      minChildSize: 0.48,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFCF6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
                    children: [
                      Text(
                        'Select Variant',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF111827),
                                ),
                      ),
                      const SizedBox(height: 26),
                      if (variants.isNotEmpty) ...[
                        _SectionTitle(_chipLabel(widget.product)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final variant in variants)
                              _OptionChip(
                                label: variant.name,
                                selected: selected == variant,
                                onTap: () => setState(() {
                                  selected = variant;
                                  quantity = 1;
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      _SectionTitle(_sectionLabel(widget.product)),
                      const SizedBox(height: 10),
                      if (variants.isEmpty)
                        _VariantRow(
                          title: widget.product.unit ?? 'Standard',
                          subtitle: widget.product.shortDescription ??
                              widget.product.name,
                          price: widget.product.price,
                          imageUrl: widget.product.imageUrl,
                          selected: true,
                          quantity: quantity,
                          onTap: () {},
                          onDecrease: _decrease,
                          onIncrease: _increase,
                        )
                      else
                        for (final variant in variants) ...[
                          _VariantRow(
                            title: variant.name,
                            subtitle: '${widget.product.name}, ${variant.name}',
                            price: variant.price,
                            imageUrl: widget.product.imageUrl,
                            selected: selected == variant,
                            quantity: selected == variant ? quantity : 0,
                            onTap: () => setState(() {
                              selected = variant;
                              quantity = 1;
                            }),
                            onDecrease: _decrease,
                            onIncrease: _increase,
                          ),
                          const SizedBox(height: 12),
                        ],
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF6),
                    border: Border(
                      top: BorderSide(
                          color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 18,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatPrice(total),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 154,
                          height: 56,
                          child: FilledButton(
                            onPressed: _confirm,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF277B63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _decrease() {
    if (quantity <= 1) return;
    setState(() => quantity -= 1);
  }

  void _increase() {
    setState(() => quantity += 1);
  }

  void _confirm() {
    widget.ref.read(cartControllerProvider.notifier).addProduct(
          widget.product,
          variant: selected,
          quantity: quantity,
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
    );
  }

  String _chipLabel(ProductModel product) {
    final lower = product.name.toLowerCase();
    if (lower.contains('ply') ||
        lower.contains('board') ||
        lower.contains('hdhmr')) {
      return 'Thickness';
    }
    if (lower.contains('pipe') || lower.contains('pvc')) return 'Size';
    if (lower.contains('channel')) return 'Length';
    if (lower.contains('hinge')) return 'Body';
    return 'Options';
  }

  String _sectionLabel(ProductModel product) {
    final lower = product.name.toLowerCase();
    if (lower.contains('pipe') || lower.contains('pvc')) return 'Length';
    if (lower.contains('ply') ||
        lower.contains('board') ||
        lower.contains('hdhmr')) {
      return 'Variant';
    }
    return _chipLabel(product);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 92),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF9F3) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF277B63) : const Color(0xFFE0DED8),
            width: selected ? 1.8 : 1.2,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? Colors.black : Colors.black54,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.quantity,
    required this.onTap,
    required this.onDecrease,
    required this.onIncrease,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final num price;
  final bool selected;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF277B63) : const Color(0xFFE3E0D8),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: imageUrl == null || imageUrl!.isEmpty
                      ? const Icon(Icons.inventory_2_outlined,
                          color: Color(0xFF277B63))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.inventory_2_outlined,
                              color: Color(0xFF277B63),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                formatPrice(price),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              _QtyStepper(
                selected: selected,
                quantity: selected ? quantity : 0,
                onSelect: onTap,
                onDecrease: onDecrease,
                onIncrease: onIncrease,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.selected,
    required this.quantity,
    required this.onSelect,
    required this.onDecrease,
    required this.onIncrease,
  });

  final bool selected;
  final int quantity;
  final VoidCallback onSelect;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return OutlinedButton(
        onPressed: onSelect,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF277B63),
          minimumSize: const Size(72, 42),
          side: const BorderSide(color: Color(0xFF277B63)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Add'),
      );
    }
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF277B63),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrease,
            constraints: const BoxConstraints.tightFor(width: 34, height: 42),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.remove, color: Colors.white, size: 18),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          IconButton(
            onPressed: onIncrease,
            constraints: const BoxConstraints.tightFor(width: 34, height: 42),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
