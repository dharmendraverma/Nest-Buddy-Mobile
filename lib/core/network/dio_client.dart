import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            final idToken = await user
                .getIdToken()
                .timeout(const Duration(seconds: 8), onTimeout: () => null);
            if (idToken != null && idToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $idToken';
            }
          } catch (_) {
            // Let the request continue; endpoints that need auth can return 401
            // and feature services can decide whether to show fallback data.
          }
        }
        handler.next(options);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (value) {
        assert(() {
          // ignore: avoid_print
          print(value);
          return true;
        }());
      },
    ),
  );

  return dio;
});
