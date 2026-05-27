import 'package:freezed_annotation/freezed_annotation.dart';

import '../../catalog/domain/catalog_models.dart';

part 'cart_models.freezed.dart';
part 'cart_models.g.dart';

@freezed
class CartLine with _$CartLine {
  const factory CartLine({
    required String id,
    required ProductModel product,
    ProductVariant? variant,
    @Default(1) int quantity,
  }) = _CartLine;

  factory CartLine.fromJson(Map<String, dynamic> json) =>
      _$CartLineFromJson(json);
}

@freezed
class CartSummary with _$CartSummary {
  const CartSummary._();

  const factory CartSummary({
    @Default(<CartLine>[]) List<CartLine> lines,
  }) = _CartSummary;

  num get subtotal => lines.fold<num>(0, (sum, line) {
        final unit = line.variant?.price ?? line.product.price;
        return sum + (unit * line.quantity);
      });

  int get totalItems => lines.fold<int>(0, (sum, line) => sum + line.quantity);
}
