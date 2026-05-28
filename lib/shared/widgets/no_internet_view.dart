import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

bool isNetworkIssue(Object? error) {
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.message?.toLowerCase().contains('socket') == true;
  }
  final text = error.toString().toLowerCase();
  return text.contains('socketexception') ||
      text.contains('network') ||
      text.contains('internet') ||
      text.contains('failed host lookup');
}

void showNoInternetSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white),
          SizedBox(width: 10),
          Expanded(child: Text('No internet connection. Tap retry to reload.')),
        ],
      ),
    ),
  );
}

class NoInternetView extends StatelessWidget {
  const NoInternetView({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.wifi_off_rounded,
                  size: 36, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 18),
            Text(
              'No internet connection',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
