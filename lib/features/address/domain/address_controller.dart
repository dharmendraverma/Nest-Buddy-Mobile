import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/address_api_service.dart';
import 'address_model.dart';

final addressControllerProvider =
    NotifierProvider<AddressController, List<AddressModel>>(
        AddressController.new);

class AddressController extends Notifier<List<AddressModel>> {
  @override
  List<AddressModel> build() {
    Future.microtask(refresh);
    return const [
      AddressModel(
        id: 'local-home',
        label: 'Home',
        fullName: 'NestBuddy Customer',
        phone: '+91 98765 43210',
        line1: '221, Green Avenue',
        line2: 'Near City Market',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560001',
        isDefault: true,
      ),
    ];
  }

  Future<void> refresh() async {
    try {
      final remote = await ref.read(addressApiServiceProvider).getAddresses();
      if (remote.isNotEmpty) state = _ensureDefault(remote);
    } catch (_) {
      // Keep the local fallback address while offline or unauthenticated.
    }
  }

  Future<void> upsert(AddressModel address) async {
    state = _ensureDefault(_upsertLocal(state, address));
    try {
      final saved = address.id.startsWith('local-') || address.id.isEmpty
          ? await ref.read(addressApiServiceProvider).addAddress(address)
          : await ref.read(addressApiServiceProvider).updateAddress(address);
      state = _ensureDefault(_upsertLocal(state, saved));
    } catch (_) {
      // The optimistic address remains available for checkout.
    }
  }

  Future<void> setDefault(String id) async {
    AddressModel? selected;
    for (final address in state) {
      if (address.id == id) {
        selected = address;
        break;
      }
    }
    state = [
      for (final address in state)
        address.copyWith(isDefault: address.id == id),
    ];
    if (selected == null) return;
    try {
      final saved =
          await ref.read(addressApiServiceProvider).markDefault(selected);
      state = _ensureDefault(_upsertLocal(state, saved));
    } catch (_) {
      // Keep the local default even if the backend is temporarily unavailable.
    }
  }

  List<AddressModel> _upsertLocal(
      List<AddressModel> addresses, AddressModel address) {
    final exists = addresses.any((item) => item.id == address.id);
    if (!exists) return [...addresses, address];
    return [
      for (final item in addresses)
        if (item.id == address.id) address else item,
    ];
  }

  List<AddressModel> _ensureDefault(List<AddressModel> addresses) {
    if (addresses.isEmpty || addresses.any((address) => address.isDefault)) {
      return addresses;
    }
    return [
      addresses.first.copyWith(isDefault: true),
      ...addresses.skip(1),
    ];
  }
}

final selectedAddressProvider = Provider<AddressModel?>((ref) {
  final addresses = ref.watch(addressControllerProvider);
  for (final address in addresses) {
    if (address.isDefault) return address;
  }
  return addresses.isEmpty ? null : addresses.first;
});
