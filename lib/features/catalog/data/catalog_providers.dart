import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/catalog_models.dart';
import 'catalog_api_service.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(catalogApiServiceProvider).getCategories();
});

final selectedCategoryProvider = StateProvider<CategoryModel?>((ref) => null);
final selectedSubCategoryProvider = StateProvider<CategoryModel?>((ref) => null);

final productsProvider = FutureProvider.family<ProductPage, ProductQuery>((ref, query) {
  return ref.watch(catalogApiServiceProvider).getProducts(
        category: query.categorySlug,
        search: query.search,
        page: query.page,
        limit: query.limit,
      );
});

class ProductQuery {
  const ProductQuery({
    this.categorySlug,
    this.search,
    this.page = 1,
    this.limit = 20,
  });

  final String? categorySlug;
  final String? search;
  final int page;
  final int limit;

  @override
  bool operator ==(Object other) {
    return other is ProductQuery &&
        other.categorySlug == categorySlug &&
        other.search == search &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(categorySlug, search, page, limit);
}
