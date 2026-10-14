import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyPackageChoices extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool busy;
  final void Function(int? packageId, int? offerId) onBuy;
  final void Function(int offerId, int quantity)? onIncrease;
  final void Function(int packageId)? onRenew;
  const MonthlyPackageChoices(
      {super.key,
      required this.data,
      required this.busy,
      required this.onBuy,
      this.onIncrease,
      this.onRenew});
  @override
  State<MonthlyPackageChoices> createState() => _MonthlyPackageChoicesState();
}

class _MonthlyPackageChoicesState extends State<MonthlyPackageChoices> {
  int quantity = 1;
  int? selectedOfferId;
  double number(dynamic value) => double.tryParse('$value') ?? 0;
  String money(dynamic value) =>
      NumberFormat('#,##0.###', 'ar').format(number(value));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final sub = widget.data['subscription'] as Map? ?? {};
    final allowance = sub['allowance'] as Map? ?? {};
    final active = sub['active'] == true;
    final pending = sub['open_payment'] as Map?;
    final locked = widget.busy;
    final packages = widget.data['packages'] as List? ?? [];
    final offers =
        List<dynamic>.from(widget.data['increase_offers'] as List? ?? []);
    final offer = offers.isEmpty
        ? null
        : offers.firstWhere((item) => item['id'] == selectedOfferId,
            orElse: () => offers.first) as Map;
    final accent = dark ? const Color(0xFFFFB985) : const Color(0xFFAB430C);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 24),
      Text('باقة تناسبك، وحد ائتماني أكبر',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Text('الحد الائتماني ليس رصيدًا في المحفظة، وتُدفع قيمة الطلب كاملة.',
          style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
      if (active)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('طوّر باقتك على راحتك',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                  'اختر باقة أعلى للترقية، أو حدد زيادة الحد المناسبة لك أدناه.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
            ])),
      if (packages.isEmpty)
        const Padding(
            padding: EdgeInsets.all(24),
            child: Text('لا توجد باقات متاحة حاليًا.')),
      for (int i = 0; i < packages.length; i++)
        Builder(builder: (_) {
          final p = packages[i] as Map;
          final current = active && sub['package_id'] == p['id'];
          final selected = pending?['package_id'] == p['id'];
          final title = current
              ? (sub['package_name'] ?? p['name'])
              : selected
                  ? pending!['terms_name']
                  : p['name'];
          final price = current
              ? allowance['package_price']
              : selected
                  ? pending!['quoted_amount']
                  : p['package_price'];
          final capacity = current
              ? allowance['base_limit']
              : selected
                  ? pending!['granted_allowance']
                  : p['purchase_limit'];
          final eligible = !active ||
              (p['id'] != sub['package_id'] &&
                  number(p['purchase_limit']) >
                      number(allowance['base_limit']));
          final emphasized = i % 3 == 1;
          final border = current
              ? const Color(0xFF238451)
              : selected
                  ? theme.colorScheme.primary
                  : emphasized
                      ? accent
                      : theme.dividerColor;
          return Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: emphasized
                      ? (dark
                          ? const Color(0xFF35261D)
                          : const Color(0xFFFFF8F1))
                      : theme.colorScheme.surface,
                  border: Border.all(
                      color: border, width: current || selected ? 2 : 1),
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text('$title',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800))),
                      if (current || selected)
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: current
                                    ? const Color(0xFFE4F4EA)
                                    : theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                                current ? 'مدفوع · الباقة الحالية' : 'مختارة',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: current
                                        ? const Color(0xFF14613D)
                                        : theme
                                            .colorScheme.onPrimaryContainer))),
                    ]),
                    const SizedBox(height: 12),
                    Text(
                        '${p['description'] ?? 'باقة بحد ائتماني يناسب احتياجاتك.'}',
                        style:
                            theme.textTheme.bodyMedium?.copyWith(color: muted)),
                    const SizedBox(height: 22),
                    Text('${money(price)} ج.م',
                        style: theme.textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    Text('سعر الباقة',
                        style:
                            theme.textTheme.bodySmall?.copyWith(color: muted)),
                    const SizedBox(height: 20),
                    if (!current && eligible)
                      FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: emphasized
                                  ? const Color(0xFFAB430C)
                                  : const Color(0xFF242D3D),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48)),
                          onPressed: locked
                              ? null
                              : () => widget.onBuy(p['id'] as int, null),
                          child: Text(active
                              ? 'ترقية من رصيد المحفظة'
                              : 'اشتراك من رصيد المحفظة'))
                    else
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                              current
                                  ? 'باقتك الحالية'
                                  : 'باقة غير متاحة للترقية',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: muted))),
                    const SizedBox(height: 20),
                    if (current) ...[
                      Text('تجديد الحد فقط؛ يبقى تاريخ انتهاء الباقة كما هو.',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: muted)),
                      const SizedBox(height: 8),
                      OutlinedButton(
                          onPressed: locked ||
                                  widget.onRenew == null ||
                                  number(p['renewal_price']) <= 0
                              ? null
                              : () => widget.onRenew!(p['id'] as int),
                          child: Text(number(p['renewal_price']) > 0
                              ? 'تجديد الحد بـ${money(p['renewal_price'])} ج.م'
                              : 'رسوم تجديد الحد لم تُحدد بعد')),
                      const SizedBox(height: 12),
                    ],
                    Text('الاشتراك الجديد: 30 يومًا',
                        style:
                            theme.textTheme.bodySmall?.copyWith(color: muted)),
                    Divider(color: theme.dividerColor),
                    const SizedBox(height: 12),
                    Row(children: [
                      Icon(Icons.check_circle_outline, color: accent, size: 20),
                      const SizedBox(width: 8),
                      const Text('الحد الائتماني')
                    ]),
                    const SizedBox(height: 8),
                    Text('${money(capacity)} ج.م',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('حد متاح للشراء، وليس رصيدًا في المحفظة.',
                        style:
                            theme.textTheme.bodySmall?.copyWith(color: muted)),
                  ]));
        }),
      if (active) ...[
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 20),
        Text('زيادة الحد الائتماني',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('اختيارات بسيطة على قدر احتياجك. تنتهي الزيادة مع باقتك الحالية.',
            style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
        const SizedBox(height: 18),
        if (offer == null)
          const Text('لا توجد عروض زيادة متاحة حاليًا.')
        else ...[
          if (offers.length > 1)
            DropdownButtonFormField<int>(
                initialValue: offer['id'] as int,
                decoration: const InputDecoration(labelText: 'عرض الزيادة'),
                items: [
                  for (final item in offers)
                    DropdownMenuItem(
                        value: item['id'] as int,
                        child: Text('${item['name']}'))
                ],
                onChanged: locked
                    ? null
                    : (value) => setState(() {
                          selectedOfferId = value;
                          quantity = 1;
                        }))
          else
            Text('${offer['name']}', style: theme.textTheme.titleSmall),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 600 ? 5 : 2;
            final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
            return Wrap(spacing: 10, runSpacing: 10, children: [
              for (int count = 1; count <= 5; count++)
                SizedBox(
                    width: width,
                    child: Semantics(
                        selected: quantity == count,
                        button: true,
                        label:
                            'زيادة ${money(number(offer['allowance']) * count)} جنيه، دفع ${money(number(offer['price']) * count)} جنيه',
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 8),
                                backgroundColor: quantity == count
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surface,
                                foregroundColor: theme.colorScheme.onSurface,
                                side: BorderSide(
                                    color: quantity == count
                                        ? theme.colorScheme.primary
                                        : theme.dividerColor,
                                    width: quantity == count ? 2 : 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            onPressed: locked
                                ? null
                                : () => setState(() => quantity = count),
                            child: Column(children: [
                              Text(
                                  '${money(number(offer['allowance']) * count)} ج.م',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                  'دفع ${money(number(offer['price']) * count)} ج.م',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: muted)),
                            ])))),
            ]);
          }),
          const SizedBox(height: 18),
          Text('المبلغ المطلوب ${money(number(offer['price']) * quantity)} ج.م',
              style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: locked
                  ? null
                  : () {
                      if (widget.onIncrease != null) {
                        widget.onIncrease!(offer['id'] as int, quantity);
                      } else {
                        widget.onBuy(null, offer['id'] as int);
                      }
                    },
              child: const Text('زيادة الحد من رصيد المحفظة')),
        ],
      ],
    ]);
  }
}
