import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlySubscriptionSummary extends StatelessWidget {
  final Map<String, dynamic> subscription;
  final VoidCallback? onCheckout;
  final bool busy;
  const MonthlySubscriptionSummary(
      {super.key,
      required this.subscription,
      this.onCheckout,
      this.busy = false});

  @override
  Widget build(BuildContext context) {
    final active = subscription['active'] == true;
    final pending =
        (subscription['open_payment'] as Map?)?['status'] == 'pending_review';
    final expiry =
        DateTime.tryParse('${subscription['expires_at']}')?.toLocal();
    final allowance = subscription['allowance'] as Map?;
    final theme = Theme.of(context);
    String money(dynamic value) =>
        NumberFormat('#,##0.##', 'ar').format(double.tryParse('$value') ?? 0);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (active) ...[
        Row(children: [
          Expanded(
              child: Text('${subscription['package_name'] ?? 'باقتك الحالية'}',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800))),
          const Icon(Icons.check_circle, size: 18, color: Color(0xFF238451)),
          const SizedBox(width: 6),
          Text('مدفوع',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: const Color(0xFF238451)))
        ]),
        const SizedBox(height: 8),
        Text(
            'متبقي ${subscription['remaining_days']} يومًا${expiry == null ? '' : ' · تنتهي ${expiry.year}/${expiry.month}/${expiry.day}'}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        if (allowance != null) ...[
          const SizedBox(height: 20),
          Wrap(spacing: 28, runSpacing: 14, children: [
            for (final item in <String, String>{
              'granted_limit': 'الحد الائتماني',
              'committed_limit': 'المستخدم أو المحجوز',
              'available_limit': 'المتاح الآن'
            }.entries)
              if (allowance[item.key] != null)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.value,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('${money(allowance[item.key])} ج.م',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ]),
          ]),
        ],
        const SizedBox(height: 20),
        const Divider(),
      ] else
        Text(
            subscription['status'] == 'expired'
                ? 'انتهت باقتك. اختر الباقة المناسبة للمتابعة.'
                : 'اختر باقتك وحدك الائتماني المناسب.',
            style: theme.textTheme.bodyMedium),
      if (pending)
        Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Semantics(
                liveRegion: true,
                child: Text(
                    'الدفع قيد المراجعة\nتُفعّل الباقة بعد اعتماد الإدارة.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant))))
      else if (onCheckout != null)
        Padding(
            padding: const EdgeInsets.only(top: 16),
            child: FilledButton.icon(
                onPressed: busy ? null : onCheckout,
                icon: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.payments_outlined),
                label: const Text('المتابعة إلى دفع الاشتراك'))),
    ]);
  }
}
