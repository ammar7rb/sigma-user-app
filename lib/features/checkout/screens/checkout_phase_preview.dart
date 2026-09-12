import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';

/// Dependency-free mobile preview used only for Phase 4 visual review.
class CheckoutPhasePreview extends StatelessWidget {
  final bool isDark;
  const CheckoutPhasePreview({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: isDark ? dark : light(),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: _CheckoutPreviewPage(),
        ),
      );
}

class _CheckoutPreviewPage extends StatelessWidget {
  const _CheckoutPreviewPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب'), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _section(
            context,
            Icons.location_on_outlined,
            'عنوان التوصيل',
            Column(children: [
              const Row(children: [
                Expanded(
                    child: Text('محمد أحمد',
                        style: TextStyle(fontWeight: FontWeight.w700))),
                Text('تغيير',
                    style: TextStyle(
                        color: Color(0xff1565c0), fontWeight: FontWeight.w700))
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.pin_drop_outlined, size: 18, color: theme.hintColor),
                const SizedBox(width: 7),
                const Expanded(
                    child: Text('القاهرة، مدينة نصر، شارع مصطفى النحاس'))
              ]),
            ])),
        const SizedBox(height: 14),
        Text('طريقة الشحن',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _shippingCard(context, true, '65 ج.م', '4 - 7 أيام عمل'),
        const SizedBox(height: 10),
        _shippingCard(context, false, '45 ج.م', '10 - 15 يوم عمل'),
        const SizedBox(height: 14),
        _section(
            context,
            Icons.receipt_long_outlined,
            'ملخص الطلب',
            const Column(children: [
              _SummaryRow('قيمة المنتجات', '1,250 ج.م'),
              _SummaryRow('شحن سيجما', '65 ج.م'),
              Divider(height: 24),
              _SummaryRow('الإجمالي المدفوع الآن', '1,315 ج.م', strong: true),
            ])),
        const SizedBox(height: 18),
        SizedBox(
            height: 54,
            child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('المتابعة للدفع',
                    style: TextStyle(fontWeight: FontWeight.w800)))),
      ]),
    );
  }

  Widget _section(
      BuildContext context, IconData icon, String title, Widget child) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: theme.primaryColor)),
          const SizedBox(width: 10),
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800))
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  Widget _shippingCard(
      BuildContext context, bool sigma, String price, String duration) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: sigma
              ? theme.primaryColor.withValues(alpha: .08)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: sigma ? theme.primaryColor : theme.dividerColor,
              width: sigma ? 1.6 : 1)),
      child: Row(children: [
        Icon(sigma ? Icons.radio_button_checked : Icons.radio_button_off,
            color: sigma ? theme.primaryColor : theme.hintColor),
        const SizedBox(width: 10),
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: sigma
                    ? theme.primaryColor
                    : theme.primaryColor.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(13)),
            child: Icon(
                sigma ? Icons.bolt_rounded : Icons.local_shipping_outlined,
                color: sigma ? Colors.white : theme.primaryColor)),
        const SizedBox(width: 11),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(sigma ? 'شحن سيجما' : 'شحن عادي',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            if (sigma) ...[
              const SizedBox(width: 7),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('الأفضل',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)))
            ]
          ]),
          const SizedBox(height: 4),
          Text(duration,
              style: TextStyle(color: theme.hintColor, fontSize: 12)),
        ])),
        Text(price,
            style: TextStyle(
                color: theme.primaryColor, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool strong;
  const _SummaryRow(this.title, this.value, {this.strong = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontWeight: strong ? FontWeight.w800 : FontWeight.w500))),
          Text(value,
              style: TextStyle(
                  fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
                  color: strong ? Theme.of(context).primaryColor : null))
        ]),
      );
}
