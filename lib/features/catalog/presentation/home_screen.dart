import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/floating_cart_button.dart';
import '../../location/presentation/pincode_controller.dart';
import '../data/catalog_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _mist = Color(0xFFEAF4F2);
  static const _cream = Color(0xFFF8F5EF);
  static const _ink = Color(0xFF11383D);
  static const _coral = Color(0xFFE76F51);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final pincode = ref.watch(pincodeControllerProvider);

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          AsyncValueView(
            value: categories,
            data: (items) => RefreshIndicator(
              onRefresh: () async {
                final refreshFuture = ref.refresh(categoriesProvider.future);
                await refreshFuture;
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_mist, _cream],
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(26, 18, 26, 28),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _ServicePill(
                                    serviceable: pincode.isServiceable,
                                    onTap: () =>
                                        _showPincodeDialog(context, ref),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () =>
                                          _showPincodeDialog(context, ref),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              color: _ink),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Deliver To',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                Text(
                                                  pincode.pincode,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton.filled(
                                    style: IconButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFFCF6),
                                        foregroundColor: _ink),
                                    onPressed: () => context.go('/profile'),
                                    icon: const Icon(Icons.person_outline),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filled(
                                    style: IconButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFFCF6),
                                        foregroundColor: _ink),
                                    onPressed: () => context.go('/cart'),
                                    icon: const Icon(
                                        Icons.shopping_cart_outlined),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              SearchBar(
                                hintText: 'Search',
                                leading: const Icon(Icons.search),
                                onTap: () => context.go('/search'),
                                onSubmitted: (value) => context.go(
                                    '/search?q=${Uri.encodeComponent(value)}'),
                                elevation: const WidgetStatePropertyAll(0),
                                backgroundColor: const WidgetStatePropertyAll(
                                    Color(0xFFFFFCF6)),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Popular Categories',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: _ink,
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        16, 8, 16, MediaQuery.paddingOf(context).bottom + 110),
                    sliver: SliverGrid.builder(
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.sizeOf(context).width >= 900
                            ? 6
                            : MediaQuery.sizeOf(context).width >= 600
                                ? 4
                                : 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, index) {
                        final category = items[index];
                        return InkWell(
                          onTap: () => context.go('/category/${category.slug}'),
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFCF6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF0D5C63)
                                      .withValues(alpha: 0.10)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_iconFor(category.name),
                                    size: 36, color: _coral),
                                const SizedBox(height: 12),
                                Text(
                                  category.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: _ink,
                                      fontSize: 13,
                                      height: 1.15,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const FloatingCartButton(),
        ],
      ),
    );
  }

  Future<void> _showPincodeDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
        text: ref.read(pincodeControllerProvider).pincode);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter pincode'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6)
          ],
          decoration: const InputDecoration(labelText: 'Pincode'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Check')),
        ],
      ),
    );
    if (result != null && result.length == 6) {
      await ref.read(pincodeControllerProvider.notifier).checkAndSet(result);
    }
  }

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('elect')) {
      return Icons.electrical_services_outlined;
    }
    if (lower.contains('plumb')) {
      return Icons.plumbing_outlined;
    }
    if (lower.contains('wood') || lower.contains('ply')) {
      return Icons.foundation_outlined;
    }
    if (lower.contains('paint')) {
      return Icons.format_paint_outlined;
    }
    return Icons.category_outlined;
  }
}

class _ServicePill extends StatelessWidget {
  const _ServicePill({required this.serviceable, required this.onTap});

  final bool serviceable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor:
            serviceable ? const Color(0xFF0D5C63) : const Color(0xFFE76F51),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      icon: const Icon(Icons.bolt, size: 18),
      label: Text(serviceable ? 'Available' : 'Not Available',
          style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}
