import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../address/data/address_api_service.dart';

final pincodeControllerProvider =
    NotifierProvider<PincodeController, PincodeState>(PincodeController.new);

class PincodeState {
  const PincodeState({
    this.pincode = '560001',
    this.isServiceable = true,
  });

  final String pincode;
  final bool isServiceable;

  PincodeState copyWith({String? pincode, bool? isServiceable}) {
    return PincodeState(
      pincode: pincode ?? this.pincode,
      isServiceable: isServiceable ?? this.isServiceable,
    );
  }
}

class PincodeController extends Notifier<PincodeState> {
  @override
  PincodeState build() => const PincodeState();

  Future<void> checkAndSet(String pincode) async {
    var isServiceable = true;
    try {
      isServiceable = await ref
          .read(addressApiServiceProvider)
          .isPincodeServiceable(pincode);
    } on DioException {
      // Keep pincode usable if the serviceability API is temporarily unavailable.
    }
    state = state.copyWith(
      pincode: pincode,
      isServiceable: isServiceable,
    );
  }
}
