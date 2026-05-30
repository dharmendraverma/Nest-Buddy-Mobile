import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/update/force_update_controller.dart';
import 'routing/app_router.dart';

class NestBuddyApp extends ConsumerWidget {
  const NestBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'NestBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) =>
          ForceUpdateGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
