import 'package:freezed_annotation/freezed_annotation.dart';

import '../../cart/domain/cart_models.dart';

part 'order_models.freezed.dart';
part 'order_models.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    String? orderNumber,
    required String userId,
    @Default('PLACED') String status,
    @Default(<CartLine>[]) List<CartLine> items,
    @Default(0) num total,
    DateTime? createdAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}
