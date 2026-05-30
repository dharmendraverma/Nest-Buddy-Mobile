import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/price_formatter.dart';
import '../../../../shared/widgets/network_image_box.dart';
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
    final variants = _displayVariants(widget.product.variants);
    selected = variants.isEmpty ? null : variants.first;
  }

  @override
  Widget build(BuildContext context) {
    final variants = _displayVariants(widget.product.variants);
    if (selected == null && variants.isNotEmpty) selected = variants.first;
    final activePrice = selected?.price ?? widget.product.price;
    final activeMrp = _activeMrp;
    final total = activePrice * quantity;

    return DraggableScrollableSheet(
      initialChildSize: variants.length > 3 ? 0.82 : 0.72,
      minChildSize: 0.52,
      maxChildSize: 0.94,
      builder: (context, controller) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFCF6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                    children: [
                      _ProductSummary(
                        product: widget.product,
                        mrp: activeMrp,
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        _sectionLabel(widget.product, variants),
                        count: variants.length,
                      ),
                      const SizedBox(height: 10),
                      if (variants.isEmpty)
                        _VariantOptionRow(
                          title: widget.product.unit ?? 'Standard',
                          subtitle: widget.product.shortDescription ??
                              widget.product.name,
                          price: widget.product.price,
                          mrp: widget.product.mrp,
                          selected: true,
                          quantity: quantity,
                          onSelect: () {},
                          onDecrease: _decrease,
                          onIncrease: _increase,
                        )
                      else
                        for (final variant in variants) ...[
                          _VariantOptionRow(
                            title: variant.name,
                            subtitle: _variantSubtitle(variant),
                            price: variant.price,
                            mrp: variant.mrp,
                            selected: selected == variant,
                            quantity: selected == variant ? quantity : 0,
                            onSelect: () => setState(() {
                              selected = variant;
                              quantity = 1;
                            }),
                            onDecrease: _decrease,
                            onIncrease: _increase,
                          ),
                          const SizedBox(height: 10),
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
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                formatPrice(total),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          height: 54,
                          child: FilledButton(
                            onPressed: _confirm,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF277B63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
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

  num get _activeMrp {
    final selectedMrp = selected?.mrp ?? 0;
    if (selectedMrp > 0) return selectedMrp;
    if (widget.product.mrp > 0) return widget.product.mrp;
    return selected?.price ?? widget.product.price;
  }

  List<ProductVariant> _displayVariants(List<ProductVariant> variants) {
    if (variants.length < 2) return variants;
    final unique = <String, ProductVariant>{};
    for (final variant in variants) {
      final key = variant.name.trim().isEmpty ? variant.sku : variant.name;
      unique[key.toLowerCase()] = variant;
    }
    final values = unique.values.toList();
    if (selected != null && !values.contains(selected)) {
      selected = values.isEmpty ? null : values.first;
    }
    return values;
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

  String _sectionLabel(ProductModel product, List<ProductVariant> variants) {
    if (variants.length <= 1) return 'Variant';
    final lower = product.name.toLowerCase();
    if (lower.contains('pipe') || lower.contains('pvc')) return 'Sizes';
    if (lower.contains('channel')) return 'Lengths';
    if (lower.contains('hinge')) return 'Bodies';
    return 'All variants';
  }

  String _variantSubtitle(ProductVariant variant) {
    final values = [
      if (variant.size != null && variant.size!.isNotEmpty) variant.size,
      if (variant.color != null && variant.color!.isNotEmpty) variant.color,
      if (variant.theme != null && variant.theme!.isNotEmpty) variant.theme,
      if (variant.sku.isNotEmpty) variant.sku,
    ];
    return values.take(2).join(' • ');
  }
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({
    required this.product,
    required this.mrp,
  });

  final ProductModel product;
  final num mrp;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E8E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            NetworkImageBox(
              imageUrl: product.imageUrl,
              width: 96,
              height: 96,
              borderRadius: 12,
              backgroundColor: const Color(0xFFEAF4F2),
              iconColor: const Color(0xFF277B63),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (product.brandName != null &&
                      product.brandName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.brandName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'MRP ${formatPrice(mrp)}',
                    style: const TextStyle(
                      color: Color(0xFF11383D),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, {required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (count > 1)
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4F2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                '$count options',
                style: const TextStyle(
                  color: Color(0xFF0D5C63),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _VariantOptionRow extends StatelessWidget {
  const _VariantOptionRow({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.mrp,
    required this.selected,
    required this.quantity,
    required this.onSelect,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String title;
  final String subtitle;
  final num price;
  final num mrp;
  final bool selected;
  final int quantity;
  final VoidCallback onSelect;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5FBF8) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF277B63) : const Color(0xFFDDE7E3),
            width: selected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D5C63).withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color:
                      selected ? const Color(0xFF277B63) : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MRP',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    formatPrice(mrp > 0 ? mrp : price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              _QtyStepper(
                selected: selected,
                quantity: selected ? quantity : 0,
                onSelect: onSelect,
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
          minimumSize: const Size(68, 40),
          side: const BorderSide(color: Color(0xFF277B63)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Add'),
      );
    }
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF277B63),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrease,
            constraints: const BoxConstraints.tightFor(width: 32, height: 40),
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
            constraints: const BoxConstraints.tightFor(width: 32, height: 40),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
