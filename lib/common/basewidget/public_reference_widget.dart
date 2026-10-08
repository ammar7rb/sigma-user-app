import 'package:flutter/material.dart';

/// Public identifiers are supplied by the server; payment and routing IDs stay numeric.
class PublicReferenceWidget extends StatelessWidget {
  final dynamic reference;
  const PublicReferenceWidget({super.key, required this.reference});

  @override
  Widget build(BuildContext context) {
    final value = reference?.toString().trim() ?? '';
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SelectableText(value,
          textDirection: TextDirection.ltr,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600)),
    );
  }
}
