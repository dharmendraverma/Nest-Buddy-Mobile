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

  @override
  void initState() {
    super.initState();
    selected =
        widget.product.variants.isEmpty ? null : widget.product.variants.first;
  }

  @override
  Widget build(BuildContext context) {
    final variants = widget.product.variants;
    final price = selected?.price ?? widget.product.price;

    return DraggableScrollableSheet(
      initialChildSize: variants.length > 3 ? 0.76 : 0.62,
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
                    color: const Color(0xFF11383D).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                if (variants.isNotEmpty)
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      itemCount: variants.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final variant = variants[index];
                        final isSelected = selected == variant;
                        return ChoiceChip(
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: const Color(0xFFEAF4F2),
                          backgroundColor: Colors.white,
                          label: Text(variant.name),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF0D5C63)
                                : Colors.black54,
                            fontWeight:
                                isSelected ? FontWeight.w900 : FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF0D5C63)
                                  : const Color(0xFFE0DED8),
                            ),
                          ),
                          onSelected: (_) => setState(() => selected = variant),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _sectionLabel(widget.product),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                Expanded(
                  child: variants.isEmpty
                      ? ListView(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                          children: [
                            _VariantRow(
                              title: widget.product.unit ?? 'Standard',
                              subtitle: widget.product.shortDescription ??
                                  widget.product.name,
                              price: widget.product.price,
                              imageUrl: widget.product.imageUrl,
                              selected: true,
                              onTap: () {},
                            ),
                          ],
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                          itemCount: variants.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final variant = variants[index];
                            return _VariantRow(
                              title: variant.name,
                              subtitle:
                                  '${widget.product.name}, ${variant.name}',
                              price: variant.price,
                              imageUrl: widget.product.imageUrl,
                              selected: selected == variant,
                              onTap: () => setState(() => selected = variant),
                            );
                          },
                        ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatPrice(price),
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w900),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          height: 54,
                          child: FilledButton(
                            onPressed: _add,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0D5C63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Add',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w900)),
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

  void _add() {
    widget.ref
        .read(cartControllerProvider.notifier)
        .addProduct(widget.product, variant: selected);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  String _sectionLabel(ProductModel product) {
    final lower = product.name.toLowerCase();
    if (lower.contains('hinge')) return 'Body';
    if (lower.contains('channel')) return 'Length';
    if (lower.contains('pipe') || lower.contains('pvc')) return 'Size';
    return 'Variants';
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final num price;
  final bool selected;
  final VoidCallback onTap;
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
            color: selected ? const Color(0xFF0D5C63) : const Color(0xFFE3E0D8),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: imageUrl == null || imageUrl!.isEmpty
                      ? const Icon(Icons.inventory_2_outlined,
                          color: Color(0xFF0D5C63))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(imageUrl!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(formatPrice(price),
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D5C63),
                  side: const BorderSide(color: Color(0xFF0D5C63)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(selected ? 'Added' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
