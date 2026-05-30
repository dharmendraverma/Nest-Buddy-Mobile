import 'package:flutter/material.dart';

import '../../../../shared/widgets/network_image_box.dart';
import '../../domain/catalog_models.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onAdd,
    super.key,
  });

  final ProductModel product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final variants = _variantOptionCount(product.variants);
    final optionText = variants > 0
        ? '$variants ${variants == 1 ? 'Option' : 'Options'}'
        : 'Add';
    final priceText = _priceText(product);

    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 132;
          final imageHeight = (constraints.maxWidth * (compact ? 0.86 : 0.90))
              .clamp(92.0, 128.0);
          return Ink(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E8E5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D5C63).withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetworkImageBox(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    height: imageHeight,
                    borderRadius: 10,
                    backgroundColor: Colors.white,
                    iconColor: const Color(0xFF75817D),
                    iconSize: 34,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.2,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    priceText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF11383D),
                      fontSize: 12.6,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AddBadge(optionText: optionText, onPressed: onAdd),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _priceText(ProductModel product) {
    final variants = _dedupedVariants(product.variants);
    if (variants.length > 1) {
      final prices =
          variants.map((variant) => variant.price).where((price) => price > 0);
      final minPrice = prices.isEmpty
          ? product.price
          : prices.reduce((a, b) => a < b ? a : b);
      return '${_rupee(minPrice)} onwards';
    }
    if (variants.length == 1) return _rupee(variants.first.price);
    return _rupee(product.price);
  }

  int _variantOptionCount(List<ProductVariant> variants) {
    return _dedupedVariants(variants).length;
  }

  List<ProductVariant> _dedupedVariants(List<ProductVariant> variants) {
    if (variants.length < 2) return variants;
    final unique = <String, ProductVariant>{};
    for (final variant in variants) {
      final key = variant.name.trim().isEmpty ? variant.sku : variant.name;
      unique[key.toLowerCase()] = variant;
    }
    return unique.values.toList();
  }

  String _rupee(num value) {
    final rounded =
        value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
    return '₹$rounded';
  }
}

class _AddBadge extends StatelessWidget {
  const _AddBadge({required this.onPressed, this.optionText});

  final VoidCallback onPressed;
  final String? optionText;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF277B63);
    return SizedBox(
      width: double.infinity,
      height: 34,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, size: 17),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            optionText ?? 'Add',
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
