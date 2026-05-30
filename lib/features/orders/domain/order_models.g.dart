// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String?,
      userId: json['userId'] as String,
      status: json['status'] as String? ?? 'PLACED',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CartLine>[],
      total: json['total'] as num? ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'userId': instance.userId,
      'status': instance.status,
      'items': instance.items,
      'total': instance.total,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
