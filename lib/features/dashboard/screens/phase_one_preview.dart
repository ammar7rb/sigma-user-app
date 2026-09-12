import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

/// A dependency-free visual QA surface for the Phase 1 application shell.
/// It is only opened through SCREENSHOT_MODE and is never reached in production.
class PhaseOnePreview extends StatelessWidget {
  final bool isDark;
  final int headerStyle;

  const PhaseOnePreview({
    super.key,
    required this.isDark,
    this.headerStyle = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = isDark ? dark : light();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: _PreviewPage(isDark: isDark, headerStyle: headerStyle),
      ),
    );
  }
}

class _PreviewPage extends StatelessWidget {
  final bool isDark;
  final int headerStyle;

  const _PreviewPage({required this.isDark, required this.headerStyle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerStyle == 3 ? 88 : 76),
        child: _PreviewHeader(isDark: isDark, style: headerStyle),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 2, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
                  child: Icon(Icons.search_rounded, color: theme.primaryColor),
                ),
                Text('ابحث عن منتج أو علامة تجارية',
                    style: TextStyle(color: theme.hintColor)),
              ]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.palette_outlined,
                        color: theme.primaryColor, size: 28),
                    const SizedBox(height: 14),
                    Text('نظام تصميم موحّد',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                        'ألوان وتباين واضحان، مسافات مريحة، وأيقونات سهلة القراءة في الوضعين.',
                        style: TextStyle(color: theme.hintColor, height: 1.5)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.check_circle_outline_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('جاهز للتجربة',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _PreviewNavigationBar(isDark: isDark),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  final bool isDark;
  final int style;

  const _PreviewHeader({required this.isDark, required this.style});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logo = ColorFiltered(
      colorFilter: ColorFilter.mode(
        isDark ? Colors.white : theme.primaryColor,
        BlendMode.srcIn,
      ),
      child: Image.asset(
        Images.logoWithNameImage,
        width: style == 3 ? 156 : 148,
        fit: BoxFit.contain,
      ),
    );
    final notification = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: style == 2
            ? theme.primaryColor.withValues(alpha: .12)
            : theme.cardColor,
        shape: style == 2 ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: style == 2 ? null : BorderRadius.circular(14),
        border: Border.all(
          color: style == 3
              ? theme.primaryColor.withValues(alpha: .28)
              : theme.dividerColor,
        ),
        boxShadow: style == 1
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Icon(
              Icons.notifications_none_rounded,
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          if (style == 2)
            PositionedDirectional(
              top: 8,
              end: 9,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor),
                ),
              ),
            ),
        ],
      ),
    );

    Widget content = Stack(
      alignment: Alignment.center,
      children: [
        Center(child: logo),
        Positioned(left: 20, child: notification),
      ],
    );

    if (style == 3) {
      content = Container(
        margin: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(child: logo),
            Positioned(left: 10, child: notification),
          ],
        ),
      );
    }

    return Material(
      color: theme.appBarTheme.backgroundColor,
      child: SafeArea(bottom: false, child: content),
    );
  }
}

class _PreviewNavigationBar extends StatelessWidget {
  final bool isDark;

  const _PreviewNavigationBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const items = [
      (Icons.home_rounded, 'الرئيسية'),
      (Icons.chat_bubble_outline_rounded, 'الرسائل'),
      (Icons.shopping_cart_outlined, 'السلة'),
      (Icons.receipt_long_outlined, 'الطلبات'),
      (Icons.person_outline_rounded, 'الملف الشخصي'),
    ];
    return Container(
      height: 82,
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 6),
      decoration: BoxDecoration(
        color: theme.navigationBarTheme.backgroundColor ?? theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 18,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = index == 0;
          final item = items[index];
          return Expanded(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                decoration: BoxDecoration(
                  color: selected
                      ? theme.primaryColor.withValues(alpha: .13)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.$1,
                    size: 24,
                    color: selected ? theme.primaryColor : theme.hintColor),
              ),
              const SizedBox(height: 3),
              Text(item.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? theme.primaryColor : theme.hintColor)),
            ]),
          );
        }),
      ),
    );
  }
}
