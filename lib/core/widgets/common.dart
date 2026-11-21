import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pictogram.dart';
import '../l10n.dart';

/// Small upper-case caption above a value or section.
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.upper(text),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: AppColors.of(context).muted,
      ),
    );
  }
}

/// Large page title used by the tab screens.
class PageTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PageTitle(this.title, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 30,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: c.ink,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: TextStyle(fontSize: 15, color: c.muted)),
        ],
      ],
    );
  }
}

/// Centered pictogram with a short explanation.
class EmptyState extends StatelessWidget {
  final Picto picto;
  final String title;
  final String body;

  const EmptyState({
    super.key,
    required this.picto,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Pictogram(picto, size: 72, color: c.line),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.4, color: c.muted),
          ),
        ],
      ),
    );
  }
}

/// Flat bordered surface used for cards and tiles.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
