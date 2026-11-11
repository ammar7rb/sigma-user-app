import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyPackageChoices extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool busy;
  final void Function(int? packageId, int? offerId) onBuy;
  final void Function(int packageId)? onRenew;
  const MonthlyPackageChoices(
      {super.key,
      required this.data,
      required this.busy,
      required this.onBuy,
      this.onRenew});

  double number(dynamic value) => double.tryParse('$value') ?? 0;
  String money(dynamic value) =>
      NumberFormat('#,##0.###', 'ar').format(number(value));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscription = data['subscription'] as Map? ?? {};
    final allowance = subscription['allowance'] as Map? ?? {};
    final active = subscription['active'] == true;
    final packages =
        (data['packages'] as List? ?? []).whereType<Map>().toList();
    final baseLimit = number(allowance['base_limit']);
    final atTop =
        active && !packages.any((p) => number(p['purchase_limit']) > baseLimit);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 24),
      Text(active ? 'الباقات المتاحة' : 'اختر باقتك',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700)),
      if (packages.isEmpty)
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('لا توجد باقات متاحة حاليًا.')),
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 800
            ? 3
            : (constraints.maxWidth >= 520 ? 2 : 1);
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final package in packages)
            Builder(builder: (context) {
              final current =
                  active && subscription['package_id'] == package['id'];
              final higher =
                  active && number(package['purchase_limit']) > baseLimit;
              final price = package['package_price'];
              final capacity =
                  current ? allowance['base_limit'] : package['purchase_limit'];
              final renewalPrice = number(package['renewal_price']);
              return SizedBox(
                  width: width,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                            color: current
                                ? theme.colorScheme.primary
                                : theme.dividerColor)),
                    child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text(
                                        '${current ? subscription['package_name'] : package['name']}',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700))),
                                if (current) const Text('الباقة الحالية')
                              ]),
                              const SizedBox(height: 10),
                              Text('${package['description'] ?? ''}',
                                  style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 16),
                              Text('${money(price)} ج.م',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              Text('الحد الائتماني: ${money(capacity)} ج.م'),
                              const SizedBox(height: 18),
                              FilledButton(
                                  onPressed: busy
                                      ? null
                                      : () => onBuy(package['id'] as int, null),
                                  child: Text(current
                                      ? 'تجديد'
                                      : (higher && !atTop
                                          ? 'ترقية'
                                          : 'اشترك الآن'))),
                              if (current &&
                                  renewalPrice > 0 &&
                                  onRenew != null)
                                OutlinedButton(
                                    onPressed: busy
                                        ? null
                                        : () => onRenew!(package['id'] as int),
                                    child: Text(
                                        'تجديد الحد بـ${money(renewalPrice)} ج.م')),
                            ])),
                  ));
            }),
        ]);
      }),
    ]);
  }
}
