import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_back_button.dart';
import '../domain/address_controller.dart';
import '../domain/address_model.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressControllerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/profile'),
        centerTitle: true,
        title: const Text('Addresses'),
      ),
      body: addresses.isEmpty
          ? const _EmptyAddress()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressCard(
                  address: address,
                  onDefault: () => ref
                      .read(addressControllerProvider.notifier)
                      .setDefault(address.id),
                  onEdit: () => _showAddressForm(context, ref, address),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(context, ref),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add address'),
      ),
    );
  }

  void _showAddressForm(BuildContext context, WidgetRef ref,
      [AddressModel? existing]) {
    final label = TextEditingController(text: existing?.label ?? 'Home');
    final fullName =
        TextEditingController(text: existing?.fullName ?? 'NestBuddy Customer');
    final phone = TextEditingController(text: existing?.phone ?? '');
    final line1 = TextEditingController(text: existing?.line1 ?? '');
    final line2 = TextEditingController(text: existing?.line2 ?? '');
    final city = TextEditingController(text: existing?.city ?? '');
    final state = TextEditingController(text: existing?.state ?? '');
    final pincode = TextEditingController(text: existing?.pincode ?? '');
    var makeDefault = existing?.isDefault ?? false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? 'Add address' : 'Edit address',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: label,
                          decoration: const InputDecoration(
                            labelText: 'Label',
                            hintText: 'Home / Work / Site',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: fullName,
                          decoration:
                              const InputDecoration(labelText: 'Full name'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(labelText: 'Mobile number'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: line1,
                    decoration:
                        const InputDecoration(labelText: 'Address line 1'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: line2,
                    decoration: const InputDecoration(
                      labelText: 'Address line 2',
                      hintText: 'Landmark, floor, nearby place',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: city,
                          decoration: const InputDecoration(labelText: 'City'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: state,
                          decoration: const InputDecoration(labelText: 'State'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pincode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(labelText: 'Pincode'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Use as default address'),
                    value: makeDefault,
                    onChanged: (value) =>
                        setModalState(() => makeDefault = value),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final address = AddressModel(
                        id: existing?.id ??
                            'local-${DateTime.now().microsecondsSinceEpoch}',
                        label: label.text.trim().isEmpty
                            ? 'Home'
                            : label.text.trim(),
                        fullName: fullName.text.trim().isEmpty
                            ? 'NestBuddy Customer'
                            : fullName.text.trim(),
                        phone: phone.text.trim(),
                        line1: line1.text.trim(),
                        line2: line2.text.trim().isEmpty
                            ? null
                            : line2.text.trim(),
                        city: city.text.trim(),
                        state: state.text.trim(),
                        pincode: pincode.text.trim(),
                        isDefault: makeDefault,
                      );
                      final saved = await ref
                          .read(addressControllerProvider.notifier)
                          .upsert(address);
                      if (makeDefault && context.mounted) {
                        await ref
                            .read(addressControllerProvider.notifier)
                            .setDefault(saved.id);
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save address'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyAddress extends StatelessWidget {
  const _EmptyAddress();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 58,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              'No address added yet',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a delivery address to place orders faster.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onDefault,
    required this.onEdit,
  });

  final AddressModel address;
  final VoidCallback onDefault;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: address.isDefault
              ? const Color(0xFF0D5C63)
              : const Color(0xFFE0E8E5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onDefault,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  address.isDefault
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: address.isDefault
                      ? const Color(0xFF0D5C63)
                      : Colors.black45,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (address.isDefault)
                        const Chip(
                          label: Text('Default'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${address.fullName} • ${address.phone}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      address.line1,
                      if (address.line2 != null && address.line2!.isNotEmpty)
                        address.line2!,
                      '${address.city}, ${address.state} ${address.pincode}',
                    ].join(', '),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit address',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
