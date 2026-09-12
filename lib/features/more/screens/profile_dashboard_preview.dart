import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';

class ProfileDashboardPreview extends StatelessWidget {
  final bool isDark;
  const ProfileDashboardPreview({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: isDark ? dark : light(),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: SafeArea(child: _ProfileBody())),
        ),
      );
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
        child: Row(children: [
          Text('الملف الشخصي',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface)),
          const Spacer(),
          _circleButton(context, Icons.language_rounded, 'AR'),
          const SizedBox(width: 9),
          _circleButton(context, Icons.dark_mode_rounded, ''),
        ]),
      )),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        sliver: SliverList.list(children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF075ACB), Color(0xFF249DEB)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(children: [
              Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline_rounded,
                      color: Colors.white, size: 32)),
              const SizedBox(width: 14),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('أهلًا بك في سيجما',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                    SizedBox(height: 4),
                    Text('سجّل الدخول لمتابعة طلباتك وأرصدتك',
                        style:
                            TextStyle(color: Color(0xFFDDEEFF), fontSize: 12)),
                  ])),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Text('تسجيل الدخول',
                      style: TextStyle(
                          color: Color(0xFF075ACB),
                          fontWeight: FontWeight.w800))),
            ]),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child: _balanceCard(
                    context,
                    'رصيد المشتريات',
                    '1.25K ج.م',
                    Icons.account_balance_wallet_rounded,
                    const Color(0xFF075ACB))),
            const SizedBox(width: 12),
            Expanded(
                child: _balanceCard(context, 'رصيد التأمين', '850 ج.م',
                    Icons.verified_user_rounded, const Color(0xFF17A673))),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF4DD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD78A))),
            child: Row(children: [
              Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFA51F).withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.pending_actions_rounded,
                      color: Color(0xFFE88700))),
              const SizedBox(width: 12),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('طلبات تحتاج استكمال',
                        style: TextStyle(
                            color: Color(0xFF513400),
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    SizedBox(height: 3),
                    Text('طلبان في انتظار سداد التأمين أو الضريبة',
                        style:
                            TextStyle(color: Color(0xFF7B5A1B), fontSize: 12)),
                  ])),
              Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE88700), shape: BoxShape.circle),
                  child: const Text('2',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
            ]),
          ),
          const SizedBox(height: 22),
          Text('حسابي',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface)),
          const SizedBox(height: 10),
          Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cs.outline.withValues(alpha: .16))),
              child: const Column(children: [
                _MenuRow(Icons.receipt_long_rounded, 'طلباتي',
                    'تتبع وإدارة الطلبات'),
                _MenuRow(Icons.location_on_outlined, 'العناوين',
                    'عناوين الشحن المحفوظة'),
                _MenuRow(Icons.favorite_border_rounded, 'قائمة الرغبات',
                    'المنتجات التي حفظتها'),
                _MenuRow(Icons.local_offer_outlined, 'الكوبونات والعروض',
                    'وفر في طلبك القادم',
                    last: true),
              ])),
          const SizedBox(height: 18),
          Text('الشروط والخصوصية',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface)),
          const SizedBox(height: 10),
          Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cs.outline.withValues(alpha: .16))),
              child: const Column(children: [
                _MenuRow(Icons.gavel_rounded, 'الشروط والأحكام',
                    'تعرف على شروط استخدام المنصة'),
                _MenuRow(Icons.privacy_tip_outlined, 'سياسة الخصوصية',
                    'كيف نحمي بياناتك ونستخدمها',
                    last: true),
              ])),
          const SizedBox(height: 18),
          Text('الدعم والإعدادات',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface)),
          const SizedBox(height: 10),
          Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cs.outline.withValues(alpha: .16))),
              child: const Column(children: [
                _MenuRow(Icons.support_agent_rounded, 'الدعم الفني',
                    'تواصل معنا بسهولة'),
                _MenuRow(Icons.notifications_none_rounded, 'الإشعارات',
                    'تحكم في تنبيهاتك'),
                _MenuRow(Icons.settings_outlined, 'الإعدادات',
                    'الخصوصية وتفضيلات الحساب',
                    last: true),
              ])),
        ]),
      ),
    ]);
  }

  Widget _circleButton(BuildContext context, IconData icon, String label) =>
      Container(
          height: 42,
          constraints: const BoxConstraints(minWidth: 42),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color:
                      Theme.of(context).dividerColor.withValues(alpha: .45))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 20),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700))
            ]
          ]));

  Widget _balanceCard(BuildContext context, String title, String value,
          IconData icon, Color color) =>
      Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: .18))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 21)),
              const Spacer(),
              Icon(Icons.arrow_back_ios_new_rounded, color: color, size: 14)
            ]),
            const SizedBox(height: 13),
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 3),
            Text(title,
                style: TextStyle(
                    color: Theme.of(context).hintColor, fontSize: 12)),
            const SizedBox(height: 10),
            Text('إيداع رصيد',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 12)),
          ]));
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool last;
  const _MenuRow(this.icon, this.title, this.subtitle, {this.last = false});
  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(13)),
                  child: Icon(icon,
                      color: Theme.of(context).primaryColor, size: 22)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: Theme.of(context).hintColor, fontSize: 11))
                  ])),
              const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
            ])),
        if (!last)
          Divider(
              height: 1,
              indent: 68,
              color: Theme.of(context).dividerColor.withValues(alpha: .3)),
      ]);
}
