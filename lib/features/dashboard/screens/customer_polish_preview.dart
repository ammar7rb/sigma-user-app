import 'package:flutter/material.dart';

class CustomerPolishPreview extends StatelessWidget {
  final String page;
  final bool isDark;
  const CustomerPolishPreview(
      {super.key, required this.page, required this.isDark});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: _page(),
              ),
            ),
          ),
        ),
      );

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0868D7), brightness: brightness),
      scaffoldBackgroundColor:
          dark ? const Color(0xFF071525) : const Color(0xFFF5F8FC),
      cardColor: dark ? const Color(0xFF11243E) : Colors.white,
    );
  }

  Widget _page() => switch (page) {
        'cart' => const _CartPreview(),
        'checkout' => const _CheckoutPreview(),
        'shipping' => const _ShippingPreview(),
        'address' => const _AddressPreview(),
        'transfer' => const _TransferPreview(),
        'insurance' => const _InsurancePreview(),
        'product' => const _ProductPreview(),
        'profile' => const _ProfilePreview(),
        'activation' => const _ActivationPreview(),
        'onboarding2' => const _OnboardingPreview(index: 2),
        'onboarding3' => const _OnboardingPreview(index: 3),
        _ => const _HomePreview(),
      };
}

class _Page extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottom;
  const _Page({required this.title, required this.child, this.bottom});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          actions: const [
            Padding(
                padding: EdgeInsetsDirectional.only(end: 16),
                child: Icon(Icons.chevron_right_rounded))
          ],
        ),
        body: child,
        bottomNavigationBar: bottom,
      );
}

class _HomePreview extends StatelessWidget {
  const _HomePreview();
  @override
  Widget build(BuildContext context) => _Page(
        title: '',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Image.asset('assets/images/logo_with_name.png', width: 150),
            const Spacer(),
            _icon(context, Icons.notifications_none_rounded),
          ]),
          const SizedBox(height: 18),
          TextField(
              decoration: InputDecoration(
            hintText: 'ابحث عن المنتجات والمستلزمات',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
          )),
          const SizedBox(height: 24),
          const _Heading('الفئات', trailing: 'عرض الكل'),
          const SizedBox(height: 12),
          Row(
              children: List.generate(
                  4,
                  (i) => Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(children: [
                          Container(
                              height: 70,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFEAF3FF),
                                  borderRadius: BorderRadius.circular(18)),
                              child: const Icon(Icons.medical_services_outlined,
                                  color: Color(0xFF0868D7), size: 30)),
                          const SizedBox(height: 6),
                          Text(['عناية', 'أجهزة', 'معمل', 'تعقيم'][i],
                              maxLines: 1),
                        ]),
                      )))),
          const SizedBox(height: 28),
          const _Heading('صفقة اليوم', trailing: 'عرض الكل'),
          const SizedBox(height: 12),
          Container(
            height: 190,
            padding: const EdgeInsets.all(14),
            decoration: _card(context),
            child: Row(children: [
              Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FF),
                          borderRadius: BorderRadius.circular(18)),
                      child: Image.asset('assets/images/placeholder.png',
                          fit: BoxFit.contain))),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE7F7F0),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('عرض لمدة محدودة',
                            style: TextStyle(
                                color: Color(0xFF087A55),
                                fontSize: 11,
                                fontWeight: FontWeight.w700))),
                    const SizedBox(height: 9),
                    const Text('Rapid Test Cards',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Row(children: [
                      Icon(Icons.star_rounded,
                          color: Color(0xFFFFB547), size: 18),
                      Text(' 4.8  (32)')
                    ]),
                    const SizedBox(height: 10),
                    Text('10.00 ج.م',
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor)),
                  ])),
            ]),
          ),
          const SizedBox(height: 24),
          const _Heading('أحدث المنتجات', trailing: 'عرض الكل'),
        ]),
      );
}

class _CartPreview extends StatelessWidget {
  const _CartPreview();
  @override
  Widget build(BuildContext context) => _Page(
        title: 'سلة المشتريات',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(Icons.shopping_bag_outlined,
                    color: Theme.of(context).primaryColor)),
            const SizedBox(width: 10),
            const Text('منتجاتك',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const Spacer(),
            const Text('منتج واحد', style: TextStyle(color: Colors.grey)),
          ]),
          const SizedBox(height: 14),
          Container(
              padding: const EdgeInsets.all(12),
              decoration: _card(context),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(16)),
                    child: Image.asset('assets/images/placeholder.png')),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Rapid Test Cards',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('10.00 ج.م',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 14),
                      Row(children: [
                        _qty(context, Icons.add_rounded),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text('2',
                                style: TextStyle(fontWeight: FontWeight.w800))),
                        _qty(context, Icons.remove_rounded),
                        const Spacer(),
                        Icon(Icons.delete_outline_rounded,
                            color: Theme.of(context).colorScheme.error),
                      ]),
                    ])),
              ])),
          const SizedBox(height: 14),
          Container(
              padding: const EdgeInsets.all(14),
              decoration: _card(context),
              child: Row(children: [
                Icon(Icons.check_box_rounded,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                const Expanded(
                    child: Text('أوافق على الشروط والأحكام وسياسة الاسترجاع',
                        style: TextStyle(fontWeight: FontWeight.w700))),
              ])),
        ]),
        bottom: _BottomAction(label: 'المتابعة للدفع', total: '20.00 ج.م'),
      );
}

class _CheckoutPreview extends StatelessWidget {
  const _CheckoutPreview();
  @override
  Widget build(BuildContext context) => _Page(
        title: 'إتمام الطلب',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _section(context, Icons.location_on_outlined, 'عنوان التوصيل',
              'اختر عنوانًا لحساب الشحن وموعد الوصول'),
          const SizedBox(height: 12),
          _section(context, Icons.local_offer_outlined, 'كوبون الخصم',
              'أضف الكود إن كان متاحًا'),
          const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.all(12),
              decoration: _card(context),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('طريقة الدفع',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    _paymentChoice(
                        context,
                        Icons.account_balance_wallet_outlined,
                        'رصيد المشتريات',
                        'الدفع من الرصيد المتاح',
                        true),
                    const SizedBox(height: 8),
                    _paymentChoice(context, Icons.phone_android_rounded,
                        'محفظة إلكترونية', 'التحويل ورفع إثبات الدفع', false),
                    const SizedBox(height: 8),
                    _paymentChoice(context, Icons.account_balance_rounded,
                        'إنستا باي', 'التحويل ورفع إثبات الدفع', false),
                  ])),
          const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.all(18),
              decoration: _card(context),
              child: const Column(children: [
                _Amount('المجموع الفرعي', '20.00 ج.م'),
                _Amount('الشحن', 'يحسب بعد العنوان'),
                Divider(height: 26),
                _Amount('الإجمالي', '20.00 ج.م', bold: true),
              ])),
        ]),
        bottom: const _BottomAction(label: 'تأكيد الطلب', total: '20.00 ج.م'),
      );
}

class _ShippingPreview extends StatelessWidget {
  const _ShippingPreview();
  @override
  Widget build(BuildContext context) => _Page(
        title: 'عنوان التوصيل',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
              padding: const EdgeInsets.all(18),
              decoration: _card(context),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(15)),
                    child: Icon(Icons.home_outlined,
                        color: Theme.of(context).primaryColor)),
                const SizedBox(width: 12),
                const Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('المنزل',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      SizedBox(height: 5),
                      Text('القاهرة • شارع التسعين • مبنى 12',
                          style: TextStyle(color: Colors.grey))
                    ])),
                Icon(Icons.check_circle_rounded,
                    color: Theme.of(context).primaryColor),
              ])),
          const SizedBox(height: 22),
          const Text('اختر طريقة الشحن',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _shipping(
              context, true, 'شحن سيجما', 'يصل خلال 1 - 2 يوم عمل', '35 ج.م'),
          const SizedBox(height: 12),
          _shipping(
              context, false, 'شحن عادي', 'يصل خلال 3 - 5 أيام عمل', '25 ج.م'),
        ]),
        bottom: const _BottomAction(label: 'استخدم هذا العنوان'),
      );
}

class _AddressPreview extends StatelessWidget {
  const _AddressPreview();
  @override
  Widget build(BuildContext context) => _Page(
        title: 'إضافة عنوان جديد',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add_location_alt_outlined)),
              const SizedBox(width: 12),
              const Expanded(
                  child: Text(
                      'أضف بيانات التوصيل بدقة لحساب الشحن وموعد الوصول.',
                      style: TextStyle(height: 1.5))),
            ]),
          ),
          const SizedBox(height: 16),
          const _PreviewField(
              label: 'اسم المستلم', icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          const _PreviewField(
              label: 'رقم الهاتف',
              icon: Icons.phone_outlined,
              hint: '+20 10xxxxxxxx'),
          const SizedBox(height: 12),
          const _PreviewField(
              label: 'عنوان التسليم', icon: Icons.location_on_outlined),
          const SizedBox(height: 12),
          const _PreviewField(
              label: 'المحافظة', icon: Icons.apartment_outlined),
          const SizedBox(height: 12),
          const _PreviewField(
              label: 'المدينة', icon: Icons.location_city_outlined),
          const SizedBox(height: 12),
          const _PreviewField(
              label: 'الحي أو المنطقة', icon: Icons.map_outlined),
          const SizedBox(height: 12),
          const _PreviewField(label: 'الشارع', icon: Icons.signpost_outlined),
          const SizedBox(height: 12),
          const _PreviewField(
              label: 'علامة مميزة', icon: Icons.near_me_outlined),
          const SizedBox(height: 90),
        ]),
        bottom: const _BottomAction(label: 'حفظ العنوان'),
      );
}

class _TransferPreview extends StatelessWidget {
  const _TransferPreview();
  @override
  Widget build(BuildContext context) => _Page(
        title: 'بيانات التحويل',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(18)),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('حوّل المبلغ إلى بيانات الحساب التالية',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    SizedBox(height: 7),
                    Text('محفظة سيجما: 0100 000 0000\nالمبلغ: 1,320.00 ج.م')
                  ])),
          const SizedBox(height: 14),
          const _PreviewField(
              label: 'الاسم الثلاثي للمحوّل', icon: Icons.person_outline),
          const SizedBox(height: 12),
          const _PreviewField(
              label: 'رقم المحفظة أو معرّف إنستا باي',
              icon: Icons.numbers_rounded),
          const SizedBox(height: 12),
          Container(
              height: 125,
              decoration: _card(context),
              child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 34),
                    SizedBox(height: 6),
                    Text('إضافة صورة إثبات التحويل')
                  ])),
          const SizedBox(height: 12),
          const _PreviewField(
              label: 'ملاحظة إضافية (اختياري)', icon: Icons.notes_rounded),
        ]),
        bottom: const _BottomAction(label: 'تم الدفع'),
      );
}

class _InsurancePreview extends StatelessWidget {
  const _InsurancePreview();
  @override
  Widget build(BuildContext context) => _Page(
        title: 'تأمين الطلب',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(18)),
              child: const Text(
                  'تم استلام دفع المشتريات. يلزم سداد التأمين لاستكمال مراجعة الطلب. يُعاد التأمين إلى رصيد التأمين بعد المدة التي تحددها الإدارة ويمكن استخدامه مرة أخرى.',
                  style: TextStyle(height: 1.55, fontWeight: FontWeight.w700))),
          const SizedBox(height: 14),
          Container(
              padding: const EdgeInsets.all(16),
              decoration: _card(context),
              child: const Column(children: [
                _Amount('قيمة التأمين', '100.00 ج.م'),
                _Amount('الضريبة', '20.00 ج.م'),
                Divider(),
                _Amount('المطلوب', '120.00 ج.م', bold: true),
              ])),
          const SizedBox(height: 14),
          _paymentChoice(context, Icons.shield_outlined, 'رصيد التأمين',
              'الرصيد غير كافٍ — يمكنك الإيداع', false),
          const SizedBox(height: 8),
          _paymentChoice(context, Icons.phone_android_rounded,
              'محفظة إلكترونية', 'التحويل ورفع إثبات الدفع', true),
          const SizedBox(height: 8),
          _paymentChoice(context, Icons.account_balance_rounded, 'إنستا باي',
              'التحويل ورفع إثبات الدفع', false),
        ]),
        bottom: const _BottomAction(label: 'متابعة الدفع'),
      );
}

class _PreviewField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? hint;
  const _PreviewField({required this.label, required this.icon, this.hint});
  @override
  Widget build(BuildContext context) => TextField(
          decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      ));
}

class _PreviewChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  const _PreviewChoice(this.label, this.icon, this.selected);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor.withValues(alpha: .1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor),
        ),
        child: Column(children: [
          Icon(icon,
              color: selected ? Theme.of(context).primaryColor : Colors.grey),
          const SizedBox(height: 4),
          Text(label)
        ]),
      );
}

class _ProductPreview extends StatelessWidget {
  const _ProductPreview();
  @override
  Widget build(BuildContext context) => _Page(
        title: 'تفاصيل المنتج',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
              height: 310,
              decoration: _card(context),
              child: Stack(children: [
                Positioned.fill(
                    child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Image.asset('assets/images/placeholder.png',
                            fit: BoxFit.contain))),
                PositionedDirectional(
                    top: 14,
                    end: 14,
                    child: _icon(context, Icons.favorite_border_rounded)),
                const Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(radius: 4),
                          SizedBox(width: 5),
                          CircleAvatar(radius: 4, backgroundColor: Colors.grey),
                          SizedBox(width: 5),
                          CircleAvatar(radius: 4, backgroundColor: Colors.grey)
                        ])),
              ])),
          const SizedBox(height: 14),
          Container(
              padding: const EdgeInsets.all(18),
              decoration: _card(context),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rapid Test Cards',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('10.00 ج.م',
                          style: TextStyle(
                              fontSize: 22,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w900)),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: Color(0xFFFFB547)),
                      const Text(' 4.8')
                    ]),
                    const SizedBox(height: 14),
                    const Wrap(spacing: 8, children: [
                      Chip(label: Text('متوفر')),
                      Chip(label: Text('توصيل آمن')),
                      Chip(label: Text('منتج طبي'))
                    ]),
                  ])),
          const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.all(18),
              decoration: _card(context),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مواصفات المنتج',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w900)),
                    SizedBox(height: 10),
                    Text(
                        'كروت اختبار سريعة مع عرض واضح للتفاصيل وبيانات الصلاحية.',
                        style: TextStyle(height: 1.6)),
                  ])),
        ]),
        bottom: const _BottomAction(
            label: 'أضف إلى سلة المشتريات', total: '10.00 ج.م'),
      );
}

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview();
  @override
  Widget build(BuildContext context) => _Page(
        title: 'الملف الشخصي',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF075ACB), Color(0xFF25A4EC)]),
                  borderRadius: BorderRadius.circular(26)),
              child: Column(children: [
                const Row(children: [
                  CircleAvatar(
                      radius: 29,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person_outline_rounded,
                          color: Colors.white, size: 30)),
                  SizedBox(width: 14),
                  Expanded(
                      child: Text('مرحبًا بك في سيجما',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900)))
                ]),
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                        onPressed: null,
                        icon: Icon(Icons.login_rounded),
                        label: Text('تسجيل الدخول'),
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.white),
                            foregroundColor:
                                WidgetStatePropertyAll(Color(0xFF075ACB))))),
              ])),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child: _quick(
                    context, Icons.shopping_cart_outlined, 'سلة المشتريات')),
            const SizedBox(width: 10),
            Expanded(
                child:
                    _quick(context, Icons.favorite_border_rounded, 'المفضلة')),
            const SizedBox(width: 10),
            Expanded(
                child: _quick(context, Icons.local_offer_outlined, 'العروض'))
          ]),
          const SizedBox(height: 24),
          const Text('عام',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
              decoration: _card(context),
              child: const Column(children: [
                ListTile(
                    leading: Icon(Icons.receipt_long_outlined),
                    title: Text('طلباتي'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.local_shipping_outlined),
                    title: Text('تتبع الطلب'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('العناوين'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.confirmation_number_outlined),
                    title: Text('الكوبونات'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.notifications_none_rounded),
                    title: Text('الإشعارات'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('الإعدادات'),
                    trailing: Icon(Icons.chevron_left_rounded)),
              ])),
          const SizedBox(height: 24),
          const Text('المساعدة والدعم',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
              decoration: _card(context),
              child: const Column(children: [
                ListTile(
                    leading: Icon(Icons.chat_bubble_outline_rounded),
                    title: Text('الدعم'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.call_outlined),
                    title: Text('اتصل بنا'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.support_agent_rounded),
                    title: Text('تذاكر الدعم'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.description_outlined),
                    title: Text('سياسة الاسترداد'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.description_outlined),
                    title: Text('سياسة الإرجاع'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.cancel_outlined),
                    title: Text('سياسة الإلغاء'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.help_outline_rounded),
                    title: Text('الأسئلة الشائعة'),
                    trailing: Icon(Icons.chevron_left_rounded)),
              ])),
          const SizedBox(height: 24),
          const Text('القانونية والخصوصية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
              decoration: _card(context),
              child: const Column(children: [
                ListTile(
                    leading: Icon(Icons.article_outlined),
                    title: Text('الشروط والأحكام'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.verified_user_outlined),
                    title: Text('سياسة الخصوصية'),
                    trailing: Icon(Icons.chevron_left_rounded)),
                Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.groups_outlined),
                    title: Text('من نحن'),
                    trailing: Icon(Icons.chevron_left_rounded)),
              ])),
          const SizedBox(height: 100),
        ]),
      );
}

class _ActivationPreview extends StatelessWidget {
  const _ActivationPreview();
  @override
  Widget build(BuildContext context) => _Page(
        title: 'تفعيل الحساب',
        child: Column(children: [
          Expanded(
              child: ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  children: [
                Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(18)),
                        child: const Text(
                            'تم فتح طلب تفعيل حسابك. أرسل المستندات المطلوبة وستراجعها الإدارة.',
                            style: TextStyle(height: 1.5)))),
              ])),
          SafeArea(
              top: false,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                          top: BorderSide(
                              color: Theme.of(context).dividerColor))),
                  child: Row(children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add_photo_alternate_outlined,
                            size: 21, color: Theme.of(context).primaryColor)),
                    Expanded(
                        child: TextField(
                            decoration: InputDecoration(
                                hintText: 'اكتب رسالتك…',
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none)))),
                    const SizedBox(width: 6),
                    IconButton.filled(
                        onPressed: () {},
                        icon: const Icon(Icons.send_rounded, size: 20)),
                  ]))),
        ]),
      );
}

class _OnboardingPreview extends StatelessWidget {
  final int index;
  const _OnboardingPreview({required this.index});
  @override
  Widget build(BuildContext context) {
    final second = index == 2;
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Row(children: [
                    Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(Icons.health_and_safety_outlined,
                            color: Theme.of(context).primaryColor)),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: const Text('تخطي'))
                  ]),
                  const SizedBox(height: 10),
                  Expanded(
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(32)),
                          child: Image.asset(
                              second
                                  ? 'assets/images/onboarding_secure_payment.png'
                                  : 'assets/images/onboarding_medical_delivery.png',
                              fit: BoxFit.contain))),
                  const SizedBox(height: 22),
                  Text(second ? 'دفع آمن وبسيط' : 'توصيل أسرع وأكثر أمانًا',
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text(
                      second
                          ? 'اختر مستلزماتك وأكمل الدفع من خلال تجربة واضحة ومحمية.'
                          : 'تابع طلبك خطوة بخطوة حتى يصل إليك بأمان وفي الموعد المتوقع.',
                      style: const TextStyle(
                          height: 1.6, color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center),
                  const Spacer(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          3,
                          (i) => Container(
                              width: i == index - 1 ? 28 : 8,
                              height: 8,
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: i == index - 1
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).dividerColor,
                                  borderRadius: BorderRadius.circular(8))))),
                  const SizedBox(height: 18),
                  SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('متابعة'))),
                ]))));
  }
}

class _Heading extends StatelessWidget {
  final String title;
  final String trailing;
  const _Heading(this.title, {required this.trailing});
  @override
  Widget build(BuildContext context) => Row(children: [
        Text(title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const Spacer(),
        Text(trailing,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w700))
      ]);
}

class _BottomAction extends StatelessWidget {
  final String label;
  final String? total;
  const _BottomAction({required this.label, this.total});
  @override
  Widget build(BuildContext context) => SafeArea(
      top: false,
      child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: .08), blurRadius: 18)
              ]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (total != null)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    const Text('الإجمالي',
                        style: TextStyle(color: Colors.grey)),
                    const Spacer(),
                    Text(total!,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w900))
                  ])),
            SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                    onPressed: () {},
                    child: Text(label,
                        style: const TextStyle(fontWeight: FontWeight.w800))))
          ])));
}

class _Progress extends StatelessWidget {
  const _Progress();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(20)),
      child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(children: [
              CircleAvatar(child: Icon(Icons.shopping_cart_checkout_rounded)),
              SizedBox(height: 4),
              Text('السلة')
            ]),
            Icon(Icons.more_horiz),
            Column(children: [
              CircleAvatar(child: Icon(Icons.local_shipping_outlined)),
              SizedBox(height: 4),
              Text('التوصيل')
            ]),
            Icon(Icons.more_horiz),
            Column(children: [
              CircleAvatar(child: Icon(Icons.wallet_outlined)),
              SizedBox(height: 4),
              Text('الدفع')
            ])
          ]));
}

class _Amount extends StatelessWidget {
  final String title;
  final String amount;
  final bool bold;
  const _Amount(this.title, this.amount, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text(title,
            style: TextStyle(
                fontWeight: bold ? FontWeight.w900 : FontWeight.w500)),
        const Spacer(),
        Flexible(
            child: Text(amount,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
                    color: bold ? Theme.of(context).primaryColor : null)))
      ]));
}

Widget _section(
        BuildContext context, IconData icon, String title, String subtitle) =>
    Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: _card(context),
        child: Row(children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Theme.of(context).primaryColor)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12))
              ])),
          const Icon(Icons.chevron_left_rounded)
        ]));

Widget _shipping(BuildContext context, bool selected, String title,
        String subtitle, String price) =>
    Container(
        padding: const EdgeInsets.all(16),
        decoration: _card(context).copyWith(
            border: Border.all(
                color: selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
                width: selected ? 2 : 1)),
        child: Row(children: [
          CircleAvatar(
              backgroundColor: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withValues(alpha: .1),
              child: Icon(
                  selected ? Icons.bolt_rounded : Icons.local_shipping_outlined,
                  color: selected
                      ? Colors.white
                      : Theme.of(context).primaryColor)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                Text(subtitle, style: const TextStyle(color: Colors.grey))
              ])),
          Text(price,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w900))
        ]));

Widget _paymentChoice(BuildContext context, IconData icon, String title,
        String subtitle, bool selected) =>
    Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor.withValues(alpha: .07)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor),
        ),
        child: Row(children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )),
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Theme.of(context).primaryColor : Colors.grey),
        ]));

Widget _quick(BuildContext context, IconData icon, String title) => Container(
    height: 110,
    padding: const EdgeInsets.all(10),
    decoration: _card(context),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: Theme.of(context).primaryColor, size: 28),
      const SizedBox(height: 8),
      Text(title, textAlign: TextAlign.center, maxLines: 2)
    ]));
Widget _icon(BuildContext context, IconData icon) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10)
        ]),
    child: Icon(icon, color: Theme.of(context).primaryColor));
Widget _qty(BuildContext context, IconData icon) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10)),
    child: Icon(icon, size: 18, color: Theme.of(context).primaryColor));
BoxDecoration _card(BuildContext context) => BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: .35)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .035),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ]);
