import 'package:flutter/material.dart';

import '../../../shared/utils/support_links.dart';
import '../../../shared/widgets/app_back_button.dart';

enum InfoPageKind { about, contact }

class InfoScreen extends StatelessWidget {
  const InfoScreen({required this.kind, super.key});

  final InfoPageKind kind;

  @override
  Widget build(BuildContext context) {
    final isAbout = kind == InfoPageKind.about;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/profile'),
        centerTitle: true,
        title: Text(isAbout ? 'About us' : 'Contact us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAbout) ...[
                    Image.asset('assets/branding/nestbuddy_logo.png',
                        height: 72, fit: BoxFit.contain),
                    const SizedBox(height: 18),
                    Text(
                      'NestBuddy is your trusted partner for premium home building materials. From foundation to finishing, we provide plywood, hardware, electrical essentials, and plumbing solutions for home projects.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'We focus on quick access, reliable product information, and practical support for construction and home improvement needs.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ] else ...[
                    _ContactTile(
                      icon: Icons.call_outlined,
                      title: 'Phone',
                      subtitle: NestBuddySupport.phone,
                      onTap: () =>
                          openExternalLink(context, NestBuddySupport.phoneUri),
                    ),
                    _ContactTile(
                      icon: Icons.mail_outline,
                      title: 'Email',
                      subtitle: NestBuddySupport.email,
                      onTap: () =>
                          openExternalLink(context, NestBuddySupport.emailUri),
                    ),
                    _ContactTile(
                      icon: Icons.chat_outlined,
                      title: 'WhatsApp',
                      subtitle: 'Chat with NestBuddy support',
                      onTap: () => openExternalLink(
                          context, NestBuddySupport.whatsappUri),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: onTap == null ? null : const Icon(Icons.open_in_new),
      onTap: onTap,
    );
  }
}
