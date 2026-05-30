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
        ? ref.watch(productsProvider(const ProductQuery(limit: 200)))
        : ref
            .watch(productsProvider(ProductQuery(search: trimmed, limit: 200)));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 58,
                          child: SearchBar(
                            controller: _controller,
                            hintText: 'Search plywood, hinges, pipes...',
                            leading: const Icon(Icons.search),
                            autoFocus: false,
                            elevation: const WidgetStatePropertyAll(0),
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 14),
                            ),
                            backgroundColor:
                                const WidgetStatePropertyAll(Colors.white),
                            shape:
                                WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            )),
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
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF4F2),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: AsyncValueView(
                      value: products,
                      onRetry: () => ref.invalidate(trimmed.isEmpty
                          ? productsProvider(const ProductQuery(limit: 200))
                          : productsProvider(
                              ProductQuery(search: trimmed, limit: 200))),
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
      padding: EdgeInsets.fromLTRB(14, 18, 14, bottomPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: width >= 720 ? 0.66 : 0.56,
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
