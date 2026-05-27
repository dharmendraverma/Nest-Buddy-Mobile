import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final backendAuthServiceProvider = Provider<BackendAuthService>((ref) {
  return BackendAuthService(ref.watch(dioProvider));
});

class BackendAuthService {
  BackendAuthService(this._dio);

  final Dio _dio;

  Future<void> verifyFirebaseToken(String firebaseToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/verify/user',
      data: {'firebaseToken': firebaseToken},
      options: Options(headers: {'Authorization': 'Bearer $firebaseToken'}),
    );

    final data = response.data;
    if (data == null || data['success'] != true) {
      throw Exception('Backend Firebase token verification failed.');
    }
  }
}
