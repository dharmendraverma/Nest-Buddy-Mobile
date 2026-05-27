import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/auth_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({required this.phone, super.key});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });
    final auth = ref.watch(authControllerProvider);
    final otpSession = ref.watch(otpSessionProvider);
    final phone =
        widget.phone.isNotEmpty ? widget.phone : otpSession.phone ?? '';
    final sendingOtp = otpSession.isSending;
    final canVerify = otpSession.canVerify;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF11383D)),
                  label: const Text('Back',
                      style: TextStyle(color: Color(0xFF11383D), fontSize: 18)),
                ),
              ),
              const SizedBox(height: 34),
              const Icon(Icons.home_work_outlined,
                  color: Color(0xFF0D5C63), size: 58),
              const SizedBox(height: 18),
              const Text(
                'NestBuddy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF11383D),
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Verify your mobile number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF577174),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (sendingOtp) ...[
                const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0D5C63))),
                const SizedBox(height: 16),
                const Text('Sending OTP...', textAlign: TextAlign.center),
                const SizedBox(height: 20),
              ],
              _OtpBoxes(
                controller: _otpController,
                focusNode: _focusNode,
                enabled: canVerify && !sendingOtp,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 26),
              Text.rich(
                TextSpan(
                  text: 'OTP sent to $phone  ',
                  style:
                      const TextStyle(color: Color(0xFF577174), fontSize: 15),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: InkWell(
                        onTap: () => context.go('/login'),
                        child: const Text('Change',
                            style: TextStyle(
                                color: Color(0xFFE76F51),
                                fontWeight: FontWeight.w900,
                                fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              if (!sendingOtp && otpSession.message != null) ...[
                const SizedBox(height: 12),
                Text(
                  otpSession.message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 36),
              SizedBox(
                height: 66,
                child: FilledButton(
                  onPressed: !canVerify ||
                          sendingOtp ||
                          auth.isLoading ||
                          _otpController.text.length != 6
                      ? null
                      : _verify,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5C63),
                    disabledBackgroundColor:
                        const Color(0xFF0D5C63).withValues(alpha: 0.28),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Verify OTP',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verify() async {
    final otpSession = ref.read(otpSessionProvider);
    final phone =
        widget.phone.isNotEmpty ? widget.phone : otpSession.phone ?? '';
    try {
      await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(phone: phone, otp: _otpController.text.trim());
      if (mounted) context.go('/home');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = controller.text;
    return GestureDetector(
      onTap: enabled ? () => focusNode.requestFocus() : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              autofocus: enabled,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 6; i++)
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF6),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0xFF0D5C63), width: 1.7),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D5C63).withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    i < value.length ? value[i] : '',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
