import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';

class PhaseFivePreview extends StatelessWidget {
  final bool isDark;
  final String page;
  const PhaseFivePreview({super.key, required this.isDark, required this.page});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: isDark ? dark : light(),
        home: Directionality(
            textDirection: TextDirection.rtl,
            child: page == 'settings'
                ? const _SettingsPreview()
                : const _CartPreview()),
      );
}

class _ResponsiveBody extends StatelessWidget {
  final List<Widget> children;
  const _ResponsiveBody({required this.children});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth >= 700 ? 32 : 16,
                vertical: 16),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children))),
          ));
}

class _CartPreview extends StatelessWidget {
  const _CartPreview();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('السلة'), centerTitle: true),
      body: _ResponsiveBody(children: [
        Row(children: [
          Expanded(
              child: Text('منتجان محددان',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800))),
          TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('مسح السلة')),
        ]),
        const SizedBox(height: 8),
        const _CartItem(
            icon: Icons.monitor_heart_outlined,
            title: 'جهاز قياس ضغط رقمي',
            price: '850 ج.م',
            quantity: 1),
        const SizedBox(height: 12),
        const _CartItem(
            icon: Icons.medical_information_outlined,
            title: 'شنطة إسعافات أولية',
            price: '299 ج.م',
            quantity: 2),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor)),
          child: const Column(children: [
            _PriceRow('قيمة المنتجات', '1,448 ج.م'),
            _PriceRow('الخصم', '- 100 ج.م'),
            Divider(height: 24),
            _PriceRow('الإجمالي', '1,348 ج.م', strong: true),
          ]),
        ),
        const SizedBox(height: 16),
        SizedBox(
            height: 54,
            child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('متابعة إتمام الطلب',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))))),
      ]),
    );
  }
}

class _CartItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String price;
  final int quantity;
  const _CartItem(
      {required this.icon,
      required this.title,
      required this.price,
      required this.quantity});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .035),
                blurRadius: 14,
                offset: const Offset(0, 5))
          ]),
      child: Row(children: [
        Checkbox(value: true, onChanged: (_) {}),
        Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: theme.primaryColor, size: 36)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          Text(price,
              style: TextStyle(
                  color: theme.primaryColor, fontWeight: FontWeight.w900))
        ])),
        Column(children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_rounded)),
          Container(
              width: 34,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(9)),
              child: Text('$quantity',
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          IconButton(onPressed: () {}, icon: const Icon(Icons.remove_rounded))
        ]),
      ]),
    );
  }
}

class _SettingsPreview extends StatelessWidget {
  const _SettingsPreview();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: _ResponsiveBody(children: [
        Text('تخصيص التطبيق',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('اختيارات بسيطة وواضحة لتجربة تناسبك.',
            style: TextStyle(color: theme.hintColor)),
        const SizedBox(height: 22),
        _SettingCard(
            icon: Icons.dark_mode_outlined,
            title: 'الوضع الداكن',
            subtitle: 'تفعيل المظهر المريح في الإضاءة المنخفضة',
            trailing: Switch.adaptive(
                value: theme.brightness == Brightness.dark, onChanged: (_) {})),
        const SizedBox(height: 12),
        const _SettingCard(
            icon: Icons.language_rounded,
            title: 'اللغة',
            subtitle: 'العربية',
            trailing: Icon(Icons.chevron_left_rounded)),
        const SizedBox(height: 18),
        Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Icon(Icons.payments_outlined, color: theme.primaryColor),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('جميع الأسعار داخل سيجما بالجنيه المصري.'))
            ])),
      ]),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  const _SettingCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.trailing});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor)),
        child: Row(children: [
          Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: theme.primaryColor)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: theme.hintColor))
              ])),
          trailing
        ]));
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final bool strong;
  const _PriceRow(this.title, this.value, {this.strong = false});
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
                color: strong ? Theme.of(context).primaryColor : null,
                fontWeight: strong ? FontWeight.w900 : FontWeight.w600))
      ]));
}
