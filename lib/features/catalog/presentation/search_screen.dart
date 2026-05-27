import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/floating_cart_button.dart';
import '../data/catalog_providers.dart';
import '../domain/catalog_models.dart';
import 'widgets/product_card.dart';
import 'widgets/variant_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final initial = GoRouterState.of(context).uri.queryParameters['q'] ?? '';
    if (query.isEmpty && initial.isNotEmpty) {
      query = initial;
      _controller.text = initial;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = query.trim();
    final products = trimmed.isEmpty
        ? ref.watch(productsProvider(const ProductQuery(limit: 20)))
        : ref.watch(productsProvider(ProductQuery(search: trimmed, limit: 30)));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SearchBar(
                          controller: _controller,
                          hintText: 'Search plywood, hinges, pipes...',
                          leading: const Icon(Icons.search),
                          autoFocus: true,
                          elevation: const WidgetStatePropertyAll(0),
                          backgroundColor:
                              const WidgetStatePropertyAll(Color(0xFFFFFCF6)),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                          trailing: [
                            if (query.isNotEmpty)
                              IconButton(
                                tooltip: 'Clear',
                                onPressed: () => setState(() {
                                  _controller.clear();
                                  query = '';
                                }),
                                icon: const Icon(Icons.close),
                              ),
                          ],
                          onChanged: (value) => setState(() => query = value),
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
                    child: AsyncValueView(
                      value: products,
                      data: (page) => _SearchResults(products: page.items),
                    ),
                  ),
                ),
              ],
            ),
            const FloatingCartButton(),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const Center(child: Text('No matching products found.'));
    }

    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1000
        ? 4
        : width >= 720
            ? 3
            : 2;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 110;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottomPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 18,
        childAspectRatio: 0.64,
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
