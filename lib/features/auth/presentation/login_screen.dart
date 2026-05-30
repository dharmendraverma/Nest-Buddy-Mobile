import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/auth_controller.dart';
import '../../../shared/widgets/no_internet_view.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sendingOtp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).cancelOtp();
      setState(() => _sendingOtp = false);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/branding/nestbuddy_logo.png',
                        height: 86,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Quick delivery for hardware, plywood, electrical, and plumbing essentials.',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))
                      ],
                      decoration: const InputDecoration(
                          prefixText: '+91 ', labelText: 'Mobile number'),
                      validator: (value) => (value == null || value.length < 10)
                          ? 'Enter a valid mobile number'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _sendingOtp ? null : _continue,
                      icon: _sendingOtp
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.sms_outlined),
                      label: const Text('Send OTP'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = _normalizePhone(_phoneController.text);
    setState(() => _sendingOtp = true);
    try {
      final authController = ref.read(authControllerProvider.notifier);
      authController.cancelOtp();
      await authController
          .requestOtp(phone)
          .timeout(const Duration(seconds: 22));
      if (!mounted) return;
      final session = ref.read(otpSessionProvider);
      if (session.canVerify) {
        setState(() => _sendingOtp = false);
        context.go('/otp?phone=${Uri.encodeComponent(phone)}');
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(session.message ?? 'Unable to send OTP.')),
        );
      }
    } on TimeoutException {
      ref.read(authControllerProvider.notifier).cancelOtp();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP request timed out. Please try again.'),
          ),
        );
      }
    } catch (error) {
      ref.read(authControllerProvider.notifier).cancelOtp();
      if (mounted) {
        if (isNetworkIssue(error)) {
          showNoInternetSnackBar(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  String _normalizePhone(String value) {
    final trimmed = value.trim().replaceAll(RegExp(r'\s+|-'), '');
    if (trimmed.startsWith('+')) return trimmed;
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    return '+91$digits';
  }
}
