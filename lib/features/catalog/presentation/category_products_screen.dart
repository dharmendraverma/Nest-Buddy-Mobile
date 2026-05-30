import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/floating_cart_button.dart';
import '../../../shared/widgets/network_image_box.dart';
import '../data/catalog_api_service.dart';
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
      backgroundColor: const Color(0xFFF7F4EE),
      body: SafeArea(
        child: Stack(
          children: [
            AsyncValueView(
              value: category,
              onRetry: () => ref.invalidate(_categoryProvider(widget.slug)),
              data: (category) {
                final children = category.children;
                final activeSlug = selectedSlug ?? category.slug;
                final products = ref.watch(_categoryProductsProvider(
                    _CategoryProductsRequest(category, activeSlug)));
                final wide = MediaQuery.sizeOf(context).width >= 720;

                return Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFFCF6), Color(0xFFF7F4EE)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF11383D).withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Row(
                          children: [
                            const AppBackButton(),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 58,
                                child: SearchBar(
                                  hintText: category.slug,
                                  leading: const Icon(Icons.search),
                                  onTap: () => context.push('/search'),
                                  elevation: const WidgetStatePropertyAll(0),
                                  padding: const WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  backgroundColor: const WidgetStatePropertyAll(
                                      Colors.white),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: Color(0xFFE3E8E4)),
                                          borderRadius:
                                              BorderRadius.circular(18))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFEAF4F2), Color(0xFFF4FAF8)],
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28)),
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFF0D5C63)
                                  .withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: wide ? 132 : 74,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    right: BorderSide(
                                      color: const Color(0xFF0D5C63)
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(26)),
                                ),
                                child: ListView(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  children: [
                                    _SubCategoryTile(
                                      label: 'All Products',
                                      imageUrl: category.imageUrl,
                                      selected: activeSlug == category.slug,
                                      onTap: () => setState(
                                          () => selectedSlug = category.slug),
                                    ),
                                    for (final child in children)
                                      _SubCategoryTile(
                                        label: child.name,
                                        imageUrl: child.imageUrl,
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
                                onRetry: () => ref.invalidate(
                                    _categoryProductsProvider(
                                        _CategoryProductsRequest(
                                            category, activeSlug))),
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

final _categoryProductsProvider =
    FutureProvider.family<ProductPage, _CategoryProductsRequest>(
        (ref, request) async {
  final api = ref.watch(catalogApiServiceProvider);
  if (request.activeSlug != request.category.slug) {
    return api.getProducts(category: request.activeSlug, limit: 100);
  }

  final parentPage =
      await api.getProducts(category: request.category.slug, limit: 100);
  if (parentPage.items.isNotEmpty || request.category.children.isEmpty) {
    return parentPage;
  }

  final childPages = await Future.wait([
    for (final child in request.category.children)
      api.getProducts(category: child.slug, limit: 100),
  ]);
  final byId = <String, ProductModel>{};
  for (final page in childPages) {
    for (final item in page.items) {
      byId[item.id] = item;
    }
  }
  return ProductPage(items: byId.values.toList(), limit: 100);
});

class _CategoryProductsRequest {
  const _CategoryProductsRequest(this.category, this.activeSlug);

  final CategoryModel category;
  final String activeSlug;

  @override
  bool operator ==(Object other) {
    return other is _CategoryProductsRequest &&
        other.category.slug == category.slug &&
        other.activeSlug == activeSlug;
  }

  @override
  int get hashCode => Object.hash(category.slug, activeSlug);
}

class _SubCategoryTile extends StatelessWidget {
  const _SubCategoryTile({
    required this.label,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0D5C63);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
        child: ColoredBox(
          color: selected ? const Color(0xFFEAF4F2) : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              children: [
                NetworkImageBox(
                  imageUrl: imageUrl,
                  width: 52,
                  height: 52,
                  borderRadius: 12,
                  backgroundColor:
                      selected ? Colors.white : const Color(0xFFF7F4EE),
                  iconColor: selected ? green : Colors.black45,
                  iconSize: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
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
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 110;
    return LayoutBuilder(
      builder: (context, constraints) {
        final paneWidth = constraints.maxWidth;
        const columns = 2;
        final childAspectRatio = paneWidth >= 430 ? 0.54 : 0.46;
        return GridView.builder(
          padding: EdgeInsets.fromLTRB(12, 18, 12, bottomPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
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
      },
    );
  }
}
