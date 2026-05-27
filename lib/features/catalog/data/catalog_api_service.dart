import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/catalog_models.dart';

final catalogApiServiceProvider = Provider<CatalogApiService>((ref) {
  return CatalogApiService(ref.watch(dioProvider));
});

class CatalogApiService {
  CatalogApiService(this._dio);

  final Dio _dio;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/category');
      final data = _unwrapList(response.data);
      final items = data.map((item) => CategoryModel.fromJson(item)).toList();
      return items.isEmpty ? _fallbackCategories : items;
    } on DioException catch (error) {
      if (_canUseFallback(error)) return _fallbackCategories;
      rethrow;
    } catch (_) {
      return _fallbackCategories;
    }
  }

  Future<CategoryModel> getCategory(String slug) async {
    try {
      final response = await _dio.get('/category/$slug');
      return CategoryModel.fromJson(_unwrapMap(response.data));
    } on DioException catch (error) {
      if (_canUseFallback(error)) {
        return _fallbackCategory(slug);
      }
      rethrow;
    } catch (_) {
      return _fallbackCategory(slug);
    }
  }

  Future<ProductPage> getProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/product',
        queryParameters: {
          if (category != null && category.isNotEmpty) 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      final root = response.data;
      final list = _unwrapList(root);
      final items = list.map((item) => ProductModel.fromJson(item)).toList();

      if (root is Map<String, dynamic>) {
        return ProductPage(
          items: items,
          page: (root['page'] as num?)?.toInt() ?? page,
          limit: (root['limit'] as num?)?.toInt() ?? limit,
          hasMore: root['hasMore'] == true || items.length == limit,
        );
      }

      return ProductPage(
          items: items,
          page: page,
          limit: limit,
          hasMore: items.length == limit);
    } on DioException catch (error) {
      if (_canUseFallback(error)) {
        return ProductPage(
          items: _fallbackProducts(category: category, search: search),
          page: page,
          limit: limit,
        );
      }
      rethrow;
    } catch (_) {
      return ProductPage(
        items: _fallbackProducts(category: category, search: search),
        page: page,
        limit: limit,
      );
    }
  }

  Future<ProductModel> getProduct(String slug) async {
    try {
      final response = await _dio.get('/product/$slug');
      return ProductModel.fromJson(_unwrapMap(response.data));
    } catch (_) {
      final fallback = _fallbackProducts(search: slug);
      return fallback.isEmpty ? _fallbackProducts().first : fallback.first;
    }
  }

  bool _canUseFallback(DioException error) {
    final status = error.response?.statusCode;
    return status == 401 || status == 403 || status == 404 || status == 500;
  }

  List<Map<String, dynamic>> _unwrapList(dynamic value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    if (value is Map<String, dynamic>) {
      final candidates = [
        value['items'],
        value['data'],
        value['products'],
        value['categories']
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _unwrapMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      final data = value['data'];
      if (data is Map<String, dynamic>) return data;
      return value;
    }
    return const {};
  }
}

const _fallbackCategories = [
  CategoryModel(
    id: 'hardware',
    name: 'Hardware & Accessories',
    slug: 'hardware',
    children: [
      CategoryModel(id: 'hinges', name: 'Hinges', slug: 'hinges'),
      CategoryModel(id: 'locks', name: 'Locks & Hardware', slug: 'locks'),
      CategoryModel(id: 'channels', name: 'Drawer Channels', slug: 'channels'),
    ],
  ),
  CategoryModel(
    id: 'plywood',
    name: 'Plywood & Boards',
    slug: 'plywood',
    children: [
      CategoryModel(
          id: 'plywood-boards', name: 'Plywood Boards', slug: 'plywood-boards'),
      CategoryModel(id: 'mdf', name: 'MDF & HDHMR Boards', slug: 'mdf'),
    ],
  ),
  CategoryModel(
    id: 'plumbing',
    name: 'Bathware & Plumbing',
    slug: 'plumbing',
    children: [
      CategoryModel(
          id: 'cpvc-pipes-fittings',
          name: 'CPVC Pipes Fittings',
          slug: 'cpvc-pipes-fittings'),
      CategoryModel(
          id: 'showers', name: 'Showers Bath Fixtures', slug: 'showers'),
    ],
  ),
  CategoryModel(id: 'electricals', name: 'Electricals', slug: 'electricals'),
  CategoryModel(id: 'paints', name: 'Paints', slug: 'paints'),
  CategoryModel(
      id: 'waterproofing', name: 'Water Proofing', slug: 'waterproofing'),
];

CategoryModel _fallbackCategory(String slug) {
  for (final category in _fallbackCategories) {
    if (category.slug == slug) return category;
    for (final child in category.children) {
      if (child.slug == slug) return category;
    }
  }
  return _fallbackCategories.first;
}

List<ProductModel> _fallbackProducts({String? category, String? search}) {
  final products = [
    ProductModel(
      id: 'hinge-1',
      name: 'Hettich Concealed Hinge',
      slug: 'hettich-concealed-hinge',
      price: 185,
      brandName: 'Hettich',
      unit: 'piece',
      categoryId: 'hinges',
      variants: [
        ProductVariant(sku: 'HINGE-0', name: '0 Crank', price: 185),
        ProductVariant(sku: 'HINGE-8', name: '8 Crank', price: 224),
      ],
    ),
    ProductModel(
      id: 'channel-1',
      name: 'Ball Bearing Channel',
      slug: 'ball-bearing-channel',
      price: 240,
      brandName: 'Hettich',
      unit: 'piece',
      categoryId: 'channels',
      variants: [
        ProductVariant(sku: 'CH-10', name: '10 inch', price: 240),
        ProductVariant(sku: 'CH-12', name: '12 inch', price: 260),
        ProductVariant(sku: 'CH-14', name: '14 inch', price: 290),
      ],
    ),
    ProductModel(
      id: 'pipe-1',
      name: 'ASTRAL - Elbow 90°',
      slug: 'astral-elbow-90',
      price: 63,
      brandName: 'Astral',
      unit: 'piece',
      categoryId: 'cpvc-pipes-fittings',
      variants: [
        ProductVariant(sku: 'ELBOW-12', name: '1/2 x 1/2 Inch', price: 63),
        ProductVariant(sku: 'ELBOW-34', name: '3/4 x 3/4 Inch', price: 82),
      ],
    ),
    ProductModel(
      id: 'ply-1',
      name: 'Century Sainik - 8x4',
      slug: 'century-sainik-8x4',
      price: 1895,
      brandName: 'CenturyPly',
      unit: 'sheet',
      categoryId: 'plywood',
      variants: [
        ProductVariant(sku: 'PLY-12', name: '12 mm', price: 1895),
        ProductVariant(sku: 'PLY-18', name: '18 mm', price: 2450),
      ],
    ),
  ];
  final categorySlugs = _expandedCategorySlugs(category);
  final query = search?.toLowerCase().trim();
  return products.where((product) {
    final categoryMatches = category == null ||
        category.isEmpty ||
        categorySlugs.contains(product.categoryId) ||
        categorySlugs.any(product.slug.contains);
    final searchMatches = query == null ||
        query.isEmpty ||
        product.name.toLowerCase().contains(query) ||
        (product.brandName ?? '').toLowerCase().contains(query);
    return categoryMatches && searchMatches;
  }).toList();
}

Set<String> _expandedCategorySlugs(String? category) {
  if (category == null || category.isEmpty) return const {};
  return switch (category) {
    'hardware' => {'hardware', 'hinges', 'channels', 'locks'},
    'plumbing' => {'plumbing', 'cpvc-pipes-fittings', 'showers'},
    'plywood' => {'plywood', 'plywood-boards', 'mdf'},
    _ => {category},
  };
}
