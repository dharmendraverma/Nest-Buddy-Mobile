import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/address_model.dart';

final addressApiServiceProvider = Provider<AddressApiService>((ref) {
  return AddressApiService(ref.watch(dioProvider));
});

class AddressApiService {
  AddressApiService(this._dio);

  final Dio _dio;

  Future<List<AddressModel>> getAddresses() async {
    final response = await _dio.get('/addresses');
    return _unwrapList(response.data).map(_addressFromJson).toList();
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    final response =
        await _dio.post('/addresses', data: _addressToJson(address));
    return _addressFromJson(_unwrapMap(response.data));
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    final response = await _dio.put(
      '/addresses/${address.id}',
      data: _addressToJson(address),
    );
    return _addressFromJson(_unwrapMap(response.data));
  }

  Future<AddressModel> markDefault(AddressModel address) {
    return updateAddress(address.copyWith(isDefault: true));
  }

  Future<bool> isPincodeServiceable(String pincode) async {
    final response = await _dio.get('/addresses/serviceability/$pincode');
    final data = _unwrapMap(response.data);
    final raw = data['serviceable'] ??
        data['isServiceable'] ??
        data['available'] ??
        data['success'];
    if (raw is bool) return raw;
    return raw?.toString().toLowerCase() == 'true';
  }

  Map<String, dynamic> _addressToJson(AddressModel address) {
    return {
      'type': _typeForLabel(address.label),
      'name': address.fullName,
      'mobile': address.phone,
      'line1': address.line1,
      if (address.line2 != null && address.line2!.isNotEmpty)
        'line2': address.line2,
      'city': address.city,
      'state': address.state,
      'postalCode': address.pincode,
      'country': 'India',
      'isDefault': address.isDefault,
    };
  }

  AddressModel _addressFromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: _string(json['id'] ?? json['_id'] ?? json['addressId']),
      label: _labelForType(json['type'] ?? json['label']),
      fullName: _string(json['name'] ?? json['fullName']),
      phone: _string(json['mobile'] ?? json['phone']),
      line1: _string(json['line1'] ?? json['addressLine1']),
      line2: _nullableString(json['line2'] ?? json['landmark']),
      city: _string(json['city']),
      state: _string(json['state']),
      pincode: _string(json['postalCode'] ?? json['pincode'] ?? json['zip']),
      isDefault: json['isDefault'] == true || json['default'] == true,
    );
  }

  List<Map<String, dynamic>> _unwrapList(Object? value) {
    if (value is List) return value.whereType<Map<String, dynamic>>().toList();
    if (value is Map<String, dynamic>) {
      for (final key in ['items', 'data', 'addresses']) {
        final candidate = value[key];
        if (candidate is List) {
          return candidate.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _unwrapMap(Object? value) {
    if (value is Map<String, dynamic>) {
      final data = value['data'];
      if (data is Map<String, dynamic>) return data;
      return value;
    }
    return const {};
  }

  String _typeForLabel(String label) {
    final value = label.trim().toUpperCase();
    const allowed = {'HOME', 'WORK', 'SITE', 'BILLING', 'SHIPPING'};
    return allowed.contains(value) ? value : 'HOME';
  }

  String _labelForType(Object? value) {
    final text = _string(value);
    if (text.isEmpty) return 'Home';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _string(Object? value) => value?.toString() ?? '';

  String? _nullableString(Object? value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }
}
