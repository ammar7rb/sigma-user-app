import 'package:flutter/material.dart';

/// Keeps Sigma's production pages mobile-first while preventing stretched,
/// clipped layouts on tablets, web and wide accessibility viewports.
class SigmaResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const SigmaResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}
