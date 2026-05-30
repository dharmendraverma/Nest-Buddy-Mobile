import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aliceProvider = Provider<Alice>((ref) {
  return Alice(
    configuration: AliceConfiguration(
      showInspectorOnShake: false,
      showNotification: false,
    ),
  );
});

final aliceDioAdapterProvider = Provider<AliceDioAdapter?>((ref) {
  if (!kDebugMode) return null;
  final alice = ref.watch(aliceProvider);
  final adapter = AliceDioAdapter();
  alice.addAdapter(adapter);
  return adapter;
});
