import 'package:flutter/material.dart';

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
    final variants = product.variants.length;
    final optionText = variants > 0 ? '$variants Options' : 'Add';
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ProductImage(imageUrl: product.imageUrl),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 15, height: 1.08, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              _AddBadge(
                optionText: optionText,
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: url == null || url.isEmpty
            ? const Center(
                child: Icon(Icons.inventory_2_outlined,
                    size: 42, color: Colors.black38))
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.inventory_2_outlined,
                        size: 42, color: Colors.black38)),
              ),
      ),
    );
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
      height: 38,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, size: 19),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            optionText ?? 'Add',
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
