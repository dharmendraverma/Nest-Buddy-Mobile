import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/debug/alice_debug.dart';
import '../../../shared/utils/support_links.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/floating_cart_button.dart';
import '../../../shared/widgets/floating_help_button.dart';
import '../../../shared/widgets/network_image_box.dart';
import '../../location/presentation/pincode_controller.dart';
import '../data/catalog_providers.dart';
import '../domain/catalog_models.dart';

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
            onRetry: () => ref.invalidate(categoriesProvider),
            data: (items) => Column(
              children: [
                _HomeHeader(
                  pincode: pincode,
                  onPincodeTap: () => _showPincodeDialog(context, ref),
                  onSearchTap: () => context.go('/search'),
                  onCartTap: () => context.go('/cart'),
                  onProfileTap: () => context.go('/profile'),
                  onApiLogsTap: kDebugMode
                      ? () => ref.read(aliceProvider).showInspector()
                      : null,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final refreshFuture =
                          ref.refresh(categoriesProvider.future);
                      await refreshFuture;
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Popular Categories',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: _ink,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                          sliver: SliverGrid.builder(
                            itemCount: items.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  MediaQuery.sizeOf(context).width >= 900
                                      ? 6
                                      : MediaQuery.sizeOf(context).width >= 600
                                          ? 4
                                          : 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.96,
                            ),
                            itemBuilder: (context, index) {
                              final category = items[index];
                              return _HomeCategoryTile(
                                category: category,
                                icon: _iconFor(category.name),
                                onTap: () =>
                                    context.go('/category/${category.slug}'),
                              );
                            },
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            MediaQuery.paddingOf(context).bottom + 118,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _ParchaBanner(
                              onTap: () => openExternalLink(
                                  context, NestBuddySupport.whatsappUri),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const FloatingCartButton(),
          const FloatingHelpButton(),
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
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: const InputDecoration(labelText: 'Pincode'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Check'),
          ),
        ],
      ),
    );
    if (result != null && result.length == 6) {
      await ref.read(pincodeControllerProvider.notifier).checkAndSet(result);
    }
  }

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('elect')) return Icons.electrical_services_outlined;
    if (lower.contains('plumb')) return Icons.plumbing_outlined;
    if (lower.contains('wood') || lower.contains('ply')) {
      return Icons.foundation_outlined;
    }
    if (lower.contains('paint')) return Icons.format_paint_outlined;
    return Icons.category_outlined;
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.pincode,
    required this.onPincodeTap,
    required this.onSearchTap,
    required this.onCartTap,
    required this.onProfileTap,
    this.onApiLogsTap,
  });

  final PincodeState pincode;
  final VoidCallback onPincodeTap;
  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onApiLogsTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HomeScreen._mist, HomeScreen._cream],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Column(
            children: [
              Row(
                children: [
                  _ServicePill(
                    serviceable: pincode.isServiceable,
                    pincode: pincode.pincode,
                    onTap: onPincodeTap,
                  ),
                  const Spacer(),
                  if (onApiLogsTap != null) ...[
                    _HeaderIconButton(
                      tooltip: 'API logs',
                      icon: Icons.bug_report_outlined,
                      onTap: onApiLogsTap!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  _HeaderIconButton(
                    tooltip: 'Cart',
                    icon: Icons.shopping_cart_outlined,
                    onTap: onCartTap,
                  ),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    tooltip: 'Profile',
                    icon: Icons.person_outline,
                    onTap: onProfileTap,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: SearchBar(
                  hintText: 'Search',
                  leading: const Icon(Icons.search),
                  onTap: onSearchTap,
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor:
                      const WidgetStatePropertyAll(Color(0xFFFFFCF6)),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFFFFCF6),
        foregroundColor: HomeScreen._ink,
      ),
      onPressed: onTap,
      icon: Icon(icon),
    );
  }
}

class _HomeCategoryTile extends StatelessWidget {
  const _HomeCategoryTile({
    required this.category,
    required this.icon,
    required this.onTap,
  });

  final CategoryModel category;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: HomeScreen._ink.withValues(alpha: 0.10)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NetworkImageBox(
                imageUrl: category.imageUrl,
                width: double.infinity,
                height: 78,
                borderRadius: 10,
                backgroundColor: HomeScreen._mist,
                icon: icon,
                iconColor: HomeScreen._coral,
                iconSize: 34,
              ),
              const SizedBox(height: 10),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: HomeScreen._ink,
                  fontSize: 13,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParchaBanner extends StatelessWidget {
  const _ParchaBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: HomeScreen._ink,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: HomeScreen._ink.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    const Icon(Icons.description_outlined, color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need help with your parcha?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Send it on WhatsApp and we will help you pick items.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicePill extends StatelessWidget {
  const _ServicePill({
    required this.serviceable,
    required this.pincode,
    required this.onTap,
  });

  final bool serviceable;
  final String pincode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: serviceable ? HomeScreen._ink : HomeScreen._coral,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999)),
          ),
          icon: const Icon(Icons.bolt, size: 18),
          label: Text(
            serviceable ? 'Available' : 'Not Available',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pincode,
                  style: const TextStyle(
                    color: HomeScreen._ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    size: 16, color: HomeScreen._ink),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
