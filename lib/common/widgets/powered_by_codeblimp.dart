import 'package:flutter/material.dart';

/// A small "Powered by CodeBlimp" credit row.
///
/// Tapping it opens https://codeblimp.com (best-effort — silently no-ops if a
/// launcher isn't available, so it never crashes the UI).
class PoweredByCodeBlimp extends StatelessWidget {
  /// When true, uses tighter padding for dense footers.
  final bool dense;

  /// Row alignment. Defaults to centered.
  final MainAxisAlignment alignment;

  const PoweredByCodeBlimp({
    super.key,
    this.dense = false,
    this.alignment = MainAxisAlignment.center,
  });

  static const String url = 'https://codeblimp.com';

  void _open() {
    // TODO: Wire up url_launcher when added to dependencies.
    // launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    debugPrint('PoweredByCodeBlimp tapped -> $url');
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    final primary = Theme.of(context).colorScheme.primary;
    
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.max,
      children: [
        InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: dense ? 4 : 8,
              horizontal: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Powered by',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(width: 4),
                Text(
                  'CodeBlimp',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}