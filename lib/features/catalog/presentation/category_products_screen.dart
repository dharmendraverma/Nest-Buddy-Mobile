import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/floating_cart_button.dart';
import '../data/catalog_api_service.dart';
import '../data/catalog_providers.dart';
import '../domain/catalog_models.dart';
import 'widgets/product_card.dart';
import 'widgets/variant_bottom_sheet.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  const CategoryProductsScreen({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends ConsumerState<CategoryProductsScreen> {
  String? selectedSlug;

  @override
  void initState() {
    super.initState();
    selectedSlug = widget.slug;
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(_categoryProvider(widget.slug));
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      body: SafeArea(
        child: Stack(
          children: [
            AsyncValueView(
              value: category,
              data: (category) {
                final children = category.children;
                final activeSlug = selectedSlug ?? category.slug;
                final products = ref.watch(
                    productsProvider(ProductQuery(categorySlug: activeSlug)));
                final wide = MediaQuery.sizeOf(context).width >= 720;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
                      child: Row(
                        children: [
                          const AppBackButton(),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SearchBar(
                              hintText: category.slug,
                              leading: const Icon(Icons.search),
                              onTap: () => context.go(
                                  '/search?q=${Uri.encodeComponent(category.slug)}'),
                              elevation: const WidgetStatePropertyAll(0),
                              backgroundColor: const WidgetStatePropertyAll(
                                  Color(0xFFFFFCF6)),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF4F2),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(26)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: wide ? 132 : 96,
                              child: DecoratedBox(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFFCF6),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(22)),
                                ),
                                child: ListView(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  children: [
                                    _SubCategoryTile(
                                      label: 'All Products',
                                      selected: activeSlug == category.slug,
                                      onTap: () => setState(
                                          () => selectedSlug = category.slug),
                                    ),
                                    for (final child in children)
                                      _SubCategoryTile(
                                        label: child.name,
                                        selected: activeSlug == child.slug,
                                        onTap: () => setState(
                                            () => selectedSlug = child.slug),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: AsyncValueView(
                                value: products,
                                data: (page) =>
                                    _ProductList(products: page.items),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const FloatingCartButton(),
          ],
        ),
      ),
    );
  }
}

final _categoryProvider =
    FutureProvider.family<CategoryModel, String>((ref, slug) {
  return ref.watch(catalogApiServiceProvider).getCategory(slug);
});

class _SubCategoryTile extends StatelessWidget {
  const _SubCategoryTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0D5C63);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        child: ColoredBox(
          color: selected ? const Color(0xFFEAF4F2) : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            child: Column(
              children: [
                const SizedBox(
                    height: 58,
                    child: Icon(Icons.inventory_2_outlined,
                        color: Colors.black45)),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.15,
                    color: selected ? green : Colors.black87,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductList extends ConsumerWidget {
  const _ProductList({required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const Center(child: Text('No products found in this category.'));
    }
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1000
        ? 4
        : width >= 720
            ? 3
            : 2;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 110;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(18, 0, 18, bottomPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 18,
        mainAxisSpacing: 26,
        childAspectRatio: 0.58,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onAdd: () => showVariantBottomSheet(context, ref, product),
        );
      },
    );
  }
}
