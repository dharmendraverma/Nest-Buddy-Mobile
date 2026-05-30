import 'package:flutter/material.dart';

class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
    this.backgroundColor,
    this.icon = Icons.inventory_2_outlined,
    this.iconColor,
    this.iconSize = 32,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Color? backgroundColor;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final url = _absoluteImageUrl(imageUrl);
    final fallback = Center(
      child: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
        size: iconSize,
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: url == null
              ? fallback
              : Image.network(
                  url,
                  width: width,
                  height: height,
                  fit: fit,
                  errorBuilder: (_, __, ___) => fallback,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return fallback;
                  },
                ),
        ),
      ),
    );
  }
}

String? _absoluteImageUrl(String? rawUrl) {
  final trimmed = rawUrl?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;
  if (uri.hasScheme) return trimmed;
  if (trimmed.startsWith('/')) {
    return 'https://nestbuddy-backend-production.up.railway.app$trimmed';
  }
  return trimmed;
}
