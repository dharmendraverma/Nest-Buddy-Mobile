import 'package:flutter/material.dart';
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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final address = addresses[index];
          return Card(
            color: Colors.white,
            // ignore: deprecated_member_use
            child: RadioListTile<String>(
              value: address.id,
              // ignore: deprecated_member_use
              groupValue: _defaultAddressId(addresses),
              // ignore: deprecated_member_use
              onChanged: (value) => ref
                  .read(addressControllerProvider.notifier)
                  .setDefault(value!),
              title: Text('${address.label} • ${address.fullName}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(
                  '${address.line1}, ${address.line2 ?? ''}\n${address.city}, ${address.state} ${address.pincode}\n${address.phone}'),
            ),
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

  void _showAddressForm(BuildContext context, WidgetRef ref) {
    final label = TextEditingController(text: 'Work');
    final line1 = TextEditingController();
    final city = TextEditingController();
    final state = TextEditingController();
    final pincode = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: label,
                decoration: const InputDecoration(labelText: 'Label')),
            const SizedBox(height: 10),
            TextField(
                controller: line1,
                decoration: const InputDecoration(labelText: 'Address line')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: city,
                        decoration: const InputDecoration(labelText: 'City'))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                        controller: state,
                        decoration: const InputDecoration(labelText: 'State'))),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
                controller: pincode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pincode')),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.read(addressControllerProvider.notifier).upsert(
                      AddressModel(
                        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
                        label: label.text,
                        fullName: 'NestBuddy Customer',
                        phone: '+91 98765 43210',
                        line1: line1.text,
                        city: city.text,
                        state: state.text,
                        pincode: pincode.text,
                      ),
                    );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save address'),
            ),
          ],
        ),
      ),
    );
  }

  String? _defaultAddressId(List<AddressModel> addresses) {
    for (final address in addresses) {
      if (address.isDefault) return address.id;
    }
    return addresses.isEmpty ? null : addresses.first.id;
  }
}
