import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.calendar_month_outlined,
                size: 32, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(height: 16),
            Text(
                active
                    ? 'اشتراك فعال'
                    : (subscription['status'] == 'expired'
                        ? 'انتهى الاشتراك'
                        : 'لا يوجد اشتراك فعال'),
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
            const SizedBox(height: 8),
            Text(
                active
                    ? 'متبقي ${subscription['remaining_days']} يومًا'
                    : '30 يومًا بعد اعتماد الدفع',
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer)),
            if (expiry != null)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      'تاريخ الانتهاء: ${expiry.year}/${expiry.month}/${expiry.day}',
                      style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer))),
          ])),
      const SizedBox(height: 24),
      Text('سعر الاشتراك الحالي', style: theme.textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(
          subscription['price'] == null
              ? 'لم تحدد الإدارة السعر بعد'
              : '${subscription['price']} ${subscription['currency_code']}',
          style: theme.textTheme.headlineSmall),
      const SizedBox(height: 16),
      const Text(
          'كل دفعة جديدة تبدأ 30 يومًا من وقت اعتمادها، دون تمديد الأيام المتبقية.'),
      const SizedBox(height: 24),
      if (pending)
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12)),
            child: Semantics(
                liveRegion: true,
                child: Text(
                    'الدفع قيد المراجعة\nيبدأ الاشتراك بعد اعتماد الإدارة.',
                    style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer))))
      else if (onCheckout != null)
        FilledButton.icon(
            onPressed: busy ? null : onCheckout,
            icon: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.arrow_back_rounded),
            label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('المتابعة إلى دفع الاشتراك'))),
    ]);
  }
}
