import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NestBuddySupport {
  const NestBuddySupport._();

  static const phone = '+91 87963 27838';
  static const phoneDigits = '918796327838';
  static const email = 'mynestbuddy@gmail.com';
  static const address = 'Garden City, Sector 1, Greater Noida West, UP 201306';
  static const whatsappMessage =
      "I'm interested in NestBuddy products. Please provide more information.";

  static Uri get whatsappUri => Uri.parse(
      'https://wa.me/$phoneDigits?text=${Uri.encodeComponent(whatsappMessage)}');

  static Uri get phoneUri => Uri.parse('tel:$phoneDigits');

  static Uri get emailUri => Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': 'NestBuddy support'},
      );
}

Future<void> openExternalLink(BuildContext context, Uri uri) async {
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open this link.')),
    );
  }
}
