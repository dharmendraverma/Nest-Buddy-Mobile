import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final profileApiServiceProvider = Provider<ProfileApiService>((ref) {
  return ProfileApiService(ref.watch(dioProvider));
});

class ProfileApiService {
  ProfileApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? imageUrl,
  }) async {
    final response = await _dio.patch(
      '/user',
      data: {
        'name': name,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    return const {};
  }
}
