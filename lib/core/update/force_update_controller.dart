import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final forceUpdateProvider = FutureProvider<ForceUpdateState>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
  final remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setDefaults(const {
    'force_update_required': false,
    'minimum_build_number': 0,
    'android_min_build_number': 0,
    'ios_min_build_number': 0,
    'web_min_build_number': 0,
    'update_url': '',
    'android_update_url': '',
    'ios_update_url': '',
    'web_update_url': '',
    'force_update_message':
        'A newer version of NestBuddy is available. Please update to continue.',
  });
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 8),
      minimumFetchInterval:
          kDebugMode ? Duration.zero : const Duration(minutes: 5),
    ),
  );
  await remoteConfig.fetchAndActivate();

  final minBuild = _minimumBuild(remoteConfig);
  final requiredFlag = _firstBool(remoteConfig, const [
    'force_update_required',
    'force_update',
    'forceUpdateRequired',
  ]);
  final required = requiredFlag && (minBuild <= 0 || currentBuild < minBuild);
  return ForceUpdateState(
    isRequired: required,
    currentBuild: currentBuild,
    minimumBuild: minBuild,
    message: remoteConfig.getString('force_update_message'),
    updateUrl: _updateUrl(remoteConfig),
  );
});

class ForceUpdateState {
  const ForceUpdateState({
    required this.isRequired,
    required this.currentBuild,
    required this.minimumBuild,
    required this.message,
    required this.updateUrl,
  });

  final bool isRequired;
  final int currentBuild;
  final int minimumBuild;
  final String message;
  final String updateUrl;
}

class ForceUpdateGate extends ConsumerWidget {
  const ForceUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(forceUpdateProvider);
    return update.maybeWhen(
      data: (state) {
        if (!state.isRequired) return child;
        return _ForceUpdateScreen(state: state);
      },
      orElse: () => child,
    );
  }
}

class _ForceUpdateScreen extends StatelessWidget {
  const _ForceUpdateScreen({required this.state});

  final ForceUpdateState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.system_update_alt_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Update required',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _openUpdate(context),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Update now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUpdate(BuildContext context) async {
    final fallback = Uri.parse('https://www.nestbuddy.in/home');
    final uri =
        state.updateUrl.isEmpty ? fallback : Uri.tryParse(state.updateUrl);
    final opened =
        await launchUrl(uri ?? fallback, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open update link.')),
      );
    }
  }
}

int _minimumBuild(FirebaseRemoteConfig remoteConfig) {
  final prefix = _platformPrefix;
  return _firstInt(remoteConfig, [
    if (prefix != null) '${prefix}_min_build_number',
    if (prefix != null) '${prefix}_minimum_build_number',
    if (prefix != null) '${prefix}_min_version_code',
    'minimum_build_number',
    'min_build_number',
    'minimum_version_code',
  ]);
}

String _updateUrl(FirebaseRemoteConfig remoteConfig) {
  final prefix = _platformPrefix;
  return _firstString(remoteConfig, [
    if (prefix != null) '${prefix}_update_url',
    if (prefix != null) '${prefix}_store_url',
    'update_url',
    'store_url',
  ]);
}

bool _firstBool(FirebaseRemoteConfig remoteConfig, List<String> keys) {
  for (final key in keys) {
    if (remoteConfig.getBool(key)) return true;
  }
  return false;
}

int _firstInt(FirebaseRemoteConfig remoteConfig, List<String> keys) {
  for (final key in keys) {
    final value = remoteConfig.getInt(key);
    if (value > 0) return value;
  }
  return 0;
}

String _firstString(FirebaseRemoteConfig remoteConfig, List<String> keys) {
  for (final key in keys) {
    final value = remoteConfig.getString(key);
    if (value.isNotEmpty) return value;
  }
  return '';
}

String? get _platformPrefix {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => null,
  };
}
