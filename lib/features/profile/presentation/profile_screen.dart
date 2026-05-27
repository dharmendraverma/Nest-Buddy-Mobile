import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_back_button.dart';
import '../../auth/data/auth_controller.dart';
import '../../cart/domain/cart_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final cartItems = ref.watch(cartControllerProvider).totalItems;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage:
                        user?.imageUrl == null || user!.imageUrl!.isEmpty
                            ? null
                            : NetworkImage(user.imageUrl!),
                    child: user?.imageUrl == null || user!.imageUrl!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'NestBuddy Customer',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        Text(user?.phone ?? ''),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _showEditProfileSheet(context, ref),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ProfileTile(
              icon: Icons.location_on_outlined,
              title: 'Address management',
              onTap: () => context.go('/address')),
          _ProfileTile(
              icon: Icons.shopping_cart_outlined,
              title: 'Cart & checkout ($cartItems)',
              onTap: () => context.go('/cart')),
          _ProfileTile(
              icon: Icons.receipt_long_outlined,
              title: 'Orders',
              onTap: () => context.go('/orders')),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref) {
    final user = ref.read(authControllerProvider).valueOrNull;
    final name = TextEditingController(text: user?.name ?? '');
    final imageUrl = TextEditingController(text: user?.imageUrl ?? '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit profile',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: imageUrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                try {
                  await ref.read(authControllerProvider.notifier).updateProfile(
                        name: name.text.trim().isEmpty
                            ? 'NestBuddy Customer'
                            : name.text.trim(),
                        imageUrl: imageUrl.text.trim().isEmpty
                            ? null
                            : imageUrl.text.trim(),
                      );
                  if (context.mounted) Navigator.pop(context);
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.toString())),
                    );
                  }
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile(
      {required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
