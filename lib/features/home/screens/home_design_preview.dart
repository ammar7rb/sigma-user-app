import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class HomeDesignPreview extends StatelessWidget {
  final int design;
  final bool isDark;

  const HomeDesignPreview({
    super.key,
    required this.design,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? dark : light(),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            child: switch (design) {
              2 => const _BoldHome(),
              3 => const _PremiumHome(),
              _ => const _CleanHome(),
            },
          ),
          bottomNavigationBar: const _HomeBottomBar(),
        ),
      ),
    );
  }
}

class _CleanHome extends StatelessWidget {
  const _CleanHome();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _Header()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
          sliver: SliverList.list(children: [
            const _SearchBar(),
            const SizedBox(height: 16),
            _HeroBanner(
              title: 'خصم يصل إلى 25%',
              subtitle: 'على مستلزمات العناية اليومية',
              icon: Icons.health_and_safety_rounded,
              colors: const [Color(0xFF075ACB), Color(0xFF29A7FF)],
              buttonText: 'تسوق الآن',
            ),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'تسوق حسب القسم'),
            const SizedBox(height: 12),
            const _CategoryRow(style: 1),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'صفقة اليوم', action: 'عرض الكل'),
            const SizedBox(height: 12),
            const _DealCard(style: 1),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'الأكثر طلباً', action: 'عرض الكل'),
            const SizedBox(height: 12),
            const _ProductRow(style: 1),
          ]),
        ),
      ],
    );
  }
}

class _BoldHome extends StatelessWidget {
  const _BoldHome();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF073E91), Color(0xFF087CEC)],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Column(children: [
            const _Header(onColor: Colors.white, compact: true),
            const SizedBox(height: 10),
            const _SearchBar(filled: true),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SIGMA WEEK',
                          style: TextStyle(
                              color: Color(0xFFB9DDFF),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6)),
                      const SizedBox(height: 5),
                      const Text('جهّز عيادتك\nبأفضل الأسعار',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              height: 1.25,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 7),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('اكتشف العروض',
                            style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w700)),
                      ),
                    ]),
              ),
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .13),
                    shape: BoxShape.circle),
                child: const Icon(Icons.medical_services_rounded,
                    color: Colors.white, size: 65),
              ),
            ]),
          ]),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        sliver: SliverList.list(children: const [
          _SectionTitle(title: 'الأقسام الرئيسية', action: 'الكل'),
          SizedBox(height: 12),
          _CategoryRow(style: 2),
          SizedBox(height: 22),
          _DealCard(style: 2),
          SizedBox(height: 22),
          _SectionTitle(title: 'مختارات سيجما', action: 'عرض المزيد'),
          SizedBox(height: 12),
          _ProductRow(style: 2),
        ]),
      ),
    ]);
  }
}

class _PremiumHome extends StatelessWidget {
  const _PremiumHome();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      const SliverToBoxAdapter(child: _Header()),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        sliver: SliverList.list(children: [
          const _SearchBar(),
          const SizedBox(height: 16),
          Stack(children: [
            _HeroBanner(
              title: 'العناية تبدأ هنا',
              subtitle: 'منتجات موثوقة لك ولعائلتك',
              icon: Icons.favorite_rounded,
              colors: const [Color(0xFF10294D), Color(0xFF174A78)],
              buttonText: 'اكتشف المجموعة',
              tall: true,
            ),
            const Positioned(top: 14, left: 14, child: _BannerDots()),
          ]),
          const SizedBox(height: 20),
          const _SectionTitle(title: 'اكتشف منتجاتنا'),
          const SizedBox(height: 12),
          const _CategoryRow(style: 3),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(
                child: _MiniPromo(
                    title: 'شحن سيجما',
                    subtitle: 'أسرع وأوفر',
                    icon: Icons.local_shipping_outlined)),
            const SizedBox(width: 10),
            Expanded(
                child: _MiniPromo(
                    title: 'منتجات أصلية',
                    subtitle: 'جودة مضمونة',
                    icon: Icons.verified_outlined)),
          ]),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'وصل حديثاً', action: 'استكشف'),
          const SizedBox(height: 12),
          const _ProductRow(style: 3),
        ]),
      ),
    ]);
  }
}

class _Header extends StatelessWidget {
  final Color? onColor;
  final bool compact;

  const _Header({this.onColor, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = onColor ??
        (theme.brightness == Brightness.dark
            ? Colors.white
            : theme.primaryColor);
    return SizedBox(
      height: compact ? 54 : 72,
      child: Stack(alignment: Alignment.center, children: [
        Center(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            child: Image.asset(Images.logoWithNameImage,
                width: compact ? 136 : 152),
          ),
        ),
        Positioned(
          left: 20,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: onColor == null
                  ? theme.cardColor
                  : Colors.white.withValues(alpha: .14),
              shape: BoxShape.circle,
              border: Border.all(
                  color: onColor == null ? theme.dividerColor : Colors.white24),
            ),
            child:
                Icon(Icons.notifications_none_rounded, color: color, size: 23),
          ),
        ),
      ]),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final bool filled;
  const _SearchBar({this.filled = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: filled ? Colors.white : theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border:
            Border.all(color: filled ? Colors.transparent : theme.dividerColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Icon(Icons.search_rounded,
            color: filled ? const Color(0xFF075ACB) : theme.primaryColor),
        const SizedBox(width: 10),
        Text('ابحث عن منتج...',
            style: TextStyle(
                color: filled ? const Color(0xFF7B8797) : theme.hintColor)),
        const Spacer(),
        Icon(Icons.tune_rounded,
            size: 20,
            color: filled ? const Color(0xFF7B8797) : theme.hintColor),
      ]),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final String buttonText;
  final bool tall;

  const _HeroBanner(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.colors,
      required this.buttonText,
      this.tall = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tall ? 180 : 158,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: colors),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(children: [
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style:
                      const TextStyle(color: Color(0xFFDCEBFF), fontSize: 13)),
              const SizedBox(height: 13),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(buttonText,
                    style: TextStyle(
                        color: colors.first,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ])),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(24)),
          child: Icon(icon, color: Colors.white, size: 58),
        ),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.bodyLarge?.color)),
      const Spacer(),
      if (action != null)
        Text(action!,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12)),
    ]);
  }
}

class _CategoryRow extends StatelessWidget {
  final int style;
  const _CategoryRow({required this.style});

  @override
  Widget build(BuildContext context) {
    const data = [
      (Icons.science_outlined, 'تحاليل'),
      (Icons.monitor_heart_outlined, 'أجهزة'),
      (Icons.medication_outlined, 'عناية'),
      (Icons.healing_outlined, 'إسعافات'),
    ];
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: data.map((item) {
        return SizedBox(
          width: 82,
          child: Column(children: [
            Container(
              width: style == 2 ? 70 : 64,
              height: style == 2 ? 70 : 64,
              decoration: BoxDecoration(
                color: style == 2
                    ? theme.primaryColor.withValues(alpha: .1)
                    : theme.cardColor,
                shape: style == 1 ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: style == 1
                    ? null
                    : BorderRadius.circular(style == 3 ? 20 : 16),
                border: Border.all(
                    color:
                        style == 2 ? Colors.transparent : theme.dividerColor),
              ),
              child: Icon(item.$1, color: theme.primaryColor, size: 29),
            ),
            const SizedBox(height: 7),
            Text(item.$2,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color)),
          ]),
        );
      }).toList(),
    );
  }
}

class _DealCard extends StatelessWidget {
  final int style;
  const _DealCard({required this.style});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 126,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: style == 2 ? const Color(0xFFFFF3E5) : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: style == 2 ? const Color(0xFFFFD7A8) : theme.dividerColor),
      ),
      child: Row(children: [
        Container(
          width: 96,
          decoration: BoxDecoration(
              color: const Color(0xFFE8F2FF),
              borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.science_rounded,
              color: Color(0xFF1672D5), size: 52),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Text('جهاز قياس السكر',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 5),
              Row(children: [
                Text('299 ج.م',
                    style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 17)),
                const SizedBox(width: 8),
                Text('375 ج.م',
                    style: TextStyle(
                        color: theme.hintColor,
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough)),
              ]),
              const SizedBox(height: 9),
              Row(
                  children: List.generate(
                      3,
                      (index) => Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(7)),
                          child: Text(
                              index == 0
                                  ? '02 س'
                                  : index == 1
                                      ? '18 د'
                                      : '34 ث',
                              style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700))))),
            ])),
        Icon(Icons.favorite_border_rounded, color: theme.primaryColor),
      ]),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final int style;
  const _ProductRow({required this.style});

  @override
  Widget build(BuildContext context) {
    const products = [
      (Icons.health_and_safety_outlined, 'جهاز ضغط رقمي', '850 ج.م'),
      (Icons.medication_liquid_outlined, 'جهاز استنشاق', '620 ج.م'),
    ];
    final theme = Theme.of(context);
    return Row(
        children: products
            .map((item) => Expanded(
                    child: Container(
                  margin: EdgeInsetsDirectional.only(
                      end: item == products.first ? 10 : 0),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(style == 3 ? 22 : 18),
                      border: Border.all(color: theme.dividerColor)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: 92,
                            decoration: BoxDecoration(
                                color: style == 3
                                    ? const Color(0xFFF0F6FD)
                                    : theme.primaryColor.withValues(alpha: .08),
                                borderRadius: BorderRadius.circular(14)),
                            child: Center(
                                child: Icon(item.$1,
                                    color: theme.primaryColor, size: 46))),
                        const SizedBox(height: 9),
                        Text(item.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(item.$3,
                            style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                      ]),
                )))
            .toList());
  }
}

class _MiniPromo extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _MiniPromo(
      {required this.title, required this.subtitle, required this.icon});

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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: theme.primaryColor, size: 23)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          Text(subtitle, style: TextStyle(color: theme.hintColor, fontSize: 10))
        ])),
      ]),
    );
  }
}

class _BannerDots extends StatelessWidget {
  const _BannerDots();
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 18,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(9))),
        const SizedBox(width: 4),
        ...List.generate(
            2,
            (_) => Container(
                margin: const EdgeInsets.only(right: 4),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: Colors.white54, shape: BoxShape.circle))),
      ]);
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const items = [
      (Icons.home_rounded, 'الرئيسية'),
      (Icons.chat_bubble_outline_rounded, 'الرسائل'),
      (Icons.shopping_cart_outlined, 'السلة'),
      (Icons.receipt_long_outlined, 'الطلبات'),
      (Icons.person_outline_rounded, 'حسابي'),
    ];
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(6, 7, 6, 5),
      decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(top: BorderSide(color: theme.dividerColor)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .07),
                blurRadius: 16,
                offset: const Offset(0, -3))
          ]),
      child: Row(
          children: List.generate(items.length, (index) {
        final selected = index == 0;
        return Expanded(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: selected
                      ? theme.primaryColor.withValues(alpha: .12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(items[index].$1,
                  size: 23,
                  color: selected ? theme.primaryColor : theme.hintColor)),
          const SizedBox(height: 3),
          Text(items[index].$2,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? theme.primaryColor : theme.hintColor)),
        ]));
      })),
    );
  }
}
