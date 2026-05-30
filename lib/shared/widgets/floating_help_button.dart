import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cart/domain/cart_controller.dart';
import '../utils/support_links.dart';

class FloatingHelpButton extends ConsumerWidget {
  const FloatingHelpButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCart = ref.watch(cartControllerProvider).totalItems > 0;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(right: 16, bottom: hasCart ? 92 : 18),
          child: Material(
            color: const Color(0xFF25D366),
            borderRadius: BorderRadius.circular(999),
            elevation: 10,
            shadowColor: const Color(0xFF25D366).withValues(alpha: 0.28),
            child: InkWell(
              onTap: () =>
                  openExternalLink(context, NestBuddySupport.whatsappUri),
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(12, 9, 14, 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _WhatsAppMark(),
                    SizedBox(width: 8),
                    Text(
                      'Need help?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
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
}

class _WhatsAppMark extends StatelessWidget {
  const _WhatsAppMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.phone_in_talk_rounded,
        color: Color(0xFF25D366),
        size: 15,
      ),
    );
  }
}
