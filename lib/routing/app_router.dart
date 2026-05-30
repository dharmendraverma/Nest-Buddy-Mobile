import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/debug/alice_debug.dart';
import '../features/auth/data/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/address/presentation/address_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/catalog/presentation/category_products_screen.dart';
import '../features/catalog/presentation/home_screen.dart';
import '../features/catalog/presentation/search_screen.dart';
import '../features/orders/presentation/orders_screen.dart';
import '../features/orders/presentation/order_detail_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/profile/presentation/info_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey:
        kDebugMode ? ref.watch(aliceProvider).getNavigatorKey() : null,
    initialLocation: '/splash',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final otpSession = ref.read(otpSessionProvider);
      final loggedIn = auth.valueOrNull != null;
      final splashRoute = state.matchedLocation == '/splash';
      final loginRoute = state.matchedLocation == '/login';
      final otpRoute = state.matchedLocation == '/otp';
      final loadingRoute = state.matchedLocation == '/auth-loading';
      final authRoute = loginRoute || otpRoute;
      if (splashRoute) return null;
      if (auth.isLoading && !authRoute && !loadingRoute) return '/auth-loading';
      if (auth.isLoading) return null;
      if (otpSession.isPending && otpSession.canVerify && !otpRoute) {
        return '/otp?phone=${Uri.encodeComponent(otpSession.phone ?? '')}';
      }
      if (!loggedIn && !authRoute && !loadingRoute) return '/login';
      if (!loggedIn && loadingRoute) return '/login';
      if (loggedIn && loginRoute && !otpSession.isPending) return '/home';
      return null;
    },
    routes: [
      GoRoute(
          path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: '/auth-loading',
          builder: (context, state) => const AuthLoadingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (context, state) =>
            OtpScreen(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
              path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/category/:slug',
            builder: (context, state) =>
                CategoryProductsScreen(slug: state.pathParameters['slug']!),
          ),
          GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen()),
          GoRoute(
              path: '/cart', builder: (context, state) => const CartScreen()),
          GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersScreen()),
          GoRoute(
            path: '/orders/:id',
            builder: (context, state) =>
                OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen()),
          GoRoute(
              path: '/about',
              builder: (context, state) =>
                  const InfoScreen(kind: InfoPageKind.about)),
          GoRoute(
              path: '/contact',
              builder: (context, state) =>
                  const InfoScreen(kind: InfoPageKind.contact)),
          GoRoute(
              path: '/address',
              builder: (context, state) => const AddressScreen()),
        ],
      ),
    ],
  );
});

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
    ref.listen(otpSessionProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
