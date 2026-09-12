import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';

class PhaseSixPreview extends StatelessWidget {
  final bool isDark;
  final String page;
  const PhaseSixPreview({super.key, required this.isDark, required this.page});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: isDark ? dark : light(),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: switch (page) {
            'signup' => const _AuthPreview(signup: true),
            'product' => const _ProductPreview(),
            'search' => const _SearchPreview(),
            'fonts' => const _FontsPreview(),
            'about' => const _AboutPreview(),
            'activation' => const _ActivationPreview(approved: false),
            'activated' => const _ActivationPreview(approved: true),
            'payment2' => const _PaymentTwoPreview(),
            'home' => const _BottomPagePreview(index: 0),
            'messages' => const _BottomPagePreview(index: 1),
            'cart' => const _BottomPagePreview(index: 2),
            'orders' => const _BottomPagePreview(index: 3),
            'profile' => const _BottomPagePreview(index: 4),
            'pending-list' => const _PendingOrdersDemo(),
            'purchase-wallet' => const _WalletDetailDemo(insurance: false),
            'insurance-wallet' => const _WalletDetailDemo(insurance: true),
            'checkout' => const _CheckoutDemo(),
            'pending-invoice' => const _PendingInvoiceDemo(),
            _ => const _AuthPreview(signup: false),
          },
        ),
      );
}

class _Page extends StatelessWidget {
  final Widget child;
  final String title;
  const _Page({required this.child, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title), centerTitle: true),
        body: LayoutBuilder(builder: (context, c) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: c.maxWidth > 700 ? 32 : 18, vertical: 18),
          child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: child)),
        )),
      );
}

class _AuthPreview extends StatelessWidget {
  final bool signup;
  const _AuthPreview({required this.signup});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(body: Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFF59C9FA).withValues(alpha: .42), const Color(0xFFC9EEFF).withValues(alpha: .22), t.scaffoldBackgroundColor])),
      child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(18), child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(children: [
          const SizedBox(height: 20),
          Image.asset('assets/images/sigma_primary_logo.png', width: 280, height: 100, fit: BoxFit.contain,
            color: t.brightness == Brightness.dark ? Colors.white : null,
            colorBlendMode: t.brightness == Brightness.dark ? BlendMode.srcIn : null),
          const SizedBox(height: 26),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: t.cardColor, borderRadius: BorderRadius.circular(28),
            border: Border.all(color: t.dividerColor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 30, offset: const Offset(0, 14))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(signup ? 'إنشاء حساب جديد' : 'تسجيل الدخول', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(signup ? 'أدخل بياناتك للبدء مع سيجما.' : 'أهلًا بك مجددًا، أدخل بيانات حسابك.', style: TextStyle(color: t.hintColor)),
              const SizedBox(height: 22),
              if (signup) ...[
                const Row(children: [Expanded(child: _Field('الاسم الأول', Icons.person_outline)), SizedBox(width: 10), Expanded(child: _Field('اسم العائلة', Icons.person_outline))]),
                const SizedBox(height: 12),
              ],
              const _Field('البريد الإلكتروني أو رقم الهاتف', Icons.alternate_email_rounded),
              const SizedBox(height: 12),
              if (signup) ...[const _Field('رقم الهاتف', Icons.phone_outlined), const SizedBox(height: 12)],
              const _Field('كلمة المرور', Icons.lock_outline_rounded, trailing: Icons.visibility_off_outlined),
              if (signup) ...[const SizedBox(height: 12), const _Field('تأكيد كلمة المرور', Icons.verified_user_outlined)],
              const SizedBox(height: 14),
              if (!signup) Row(children: [Checkbox(value: true, onChanged: (_) {}), const Text('تذكرني'), const Spacer(), Text('هل نسيت كلمة المرور؟', style: TextStyle(color: t.primaryColor, fontWeight: FontWeight.w700))]),
              if (signup) const Row(children: [Icon(Icons.check_circle_rounded, color: Color(0xFF11875D)), SizedBox(width: 8), Expanded(child: Text('أوافق على الشروط والأحكام وسياسة الخصوصية.'))]),
              const SizedBox(height: 18),
              SizedBox(height: 54, child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(signup ? 'إنشاء الحساب' : 'تسجيل الدخول', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)))),
              const SizedBox(height: 16),
              Center(child: Text(signup ? 'لديك حساب بالفعل؟  تسجيل الدخول' : 'ليس لديك حساب؟  إنشاء حساب', style: TextStyle(color: t.primaryColor, fontWeight: FontWeight.w700))),
            ])),
        ]),
      )))),
    ));
  }
}

class _Field extends StatelessWidget {
  final String label; final IconData icon; final IconData? trailing;
  const _Field(this.label, this.icon, {this.trailing});
  @override
  Widget build(BuildContext context) => Container(height: 58, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(
    color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: Theme.of(context).dividerColor)),
    child: Row(children: [Icon(icon, color: Theme.of(context).primaryColor), const SizedBox(width: 10), Expanded(child: Text(label, style: TextStyle(color: Theme.of(context).hintColor))), if (trailing != null) Icon(trailing, color: Theme.of(context).hintColor)]));
}

class _ProductPreview extends StatelessWidget {
  const _ProductPreview();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return _Page(title: 'تفاصيل المنتج', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(height: 300, decoration: BoxDecoration(color: t.cardColor, borderRadius: BorderRadius.circular(26), border: Border.all(color: t.dividerColor)),
        child: Stack(children: [Center(child: Icon(Icons.monitor_heart_outlined, color: t.primaryColor, size: 130)), Positioned(top: 14, left: 14, child: CircleAvatar(backgroundColor: t.primaryColor.withValues(alpha: .1), child: Icon(Icons.favorite_border, color: t.primaryColor)))])),
      const SizedBox(height: 20),
      const Text('جهاز قياس ضغط رقمي', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text('850 ج.م', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: t.primaryColor)),
      const SizedBox(height: 18),
      Wrap(spacing: 8, runSpacing: 8, children: const [_Chip(Icons.verified_outlined, 'منتج أصلي'), _Chip(Icons.local_shipping_outlined, 'شحن لكل المحافظات'), _Chip(Icons.inventory_2_outlined, 'متوفر')]),
      const SizedBox(height: 22),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: t.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.dividerColor)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تفاصيل المنتج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), SizedBox(height: 10), Text('قياس سريع وواضح مع شاشة كبيرة، وذاكرة لحفظ القراءات السابقة.')])) ,
      const SizedBox(height: 18),
      SizedBox(height: 56, child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.shopping_cart_checkout_rounded), label: const Text('أضف إلى السلة', style: TextStyle(fontWeight: FontWeight.w900)), style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
    ]));
  }
}

class _Chip extends StatelessWidget { final IconData icon; final String text; const _Chip(this.icon, this.text);
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: .08), borderRadius: BorderRadius.circular(30)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: Theme.of(context).primaryColor), const SizedBox(width: 6), Text(text)])); }

class _SearchPreview extends StatelessWidget {
  const _SearchPreview();
  @override Widget build(BuildContext context) { final t = Theme.of(context); return _Page(title: 'البحث عن منتج', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Container(height: 58, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: t.cardColor, borderRadius: BorderRadius.circular(17), border: Border.all(color: t.dividerColor)), child: Row(children: [Icon(Icons.search_rounded, color: t.primaryColor), const SizedBox(width: 10), Expanded(child: Text('ابحث باسم المنتج أو القسم', style: TextStyle(color: t.hintColor))), Container(width: 42, height: 42, decoration: BoxDecoration(color: t.primaryColor.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.tune_rounded, color: t.primaryColor))])),
    const SizedBox(height: 16),
    const SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [_Filter('الكل', true), _Filter('أجهزة القياس', false), _Filter('الإسعافات', false), _Filter('المستلزمات', false)])),
    const SizedBox(height: 22),
    Row(children: [const Expanded(child: Text('نتائج البحث', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))), OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.swap_vert_rounded), label: const Text('الترتيب'))]),
    const SizedBox(height: 12),
    GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .72, children: const [_ProductCard(Icons.monitor_heart_outlined, 'جهاز قياس ضغط', '850 ج.م'), _ProductCard(Icons.medical_information_outlined, 'شنطة إسعافات', '299 ج.م'), _ProductCard(Icons.thermostat_rounded, 'ترمومتر رقمي', '175 ج.م'), _ProductCard(Icons.masks_outlined, 'كمامات طبية', '95 ج.م')]),
  ])); }
}

class _Filter extends StatelessWidget { final String text; final bool active; const _Filter(this.text, this.active);
 @override Widget build(BuildContext context) => Container(margin: const EdgeInsetsDirectional.only(end: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: active ? Theme.of(context).primaryColor : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: active ? Theme.of(context).primaryColor : Theme.of(context).dividerColor)), child: Text(text, style: TextStyle(color: active ? Colors.white : null, fontWeight: FontWeight.w700))); }

class _ProductCard extends StatelessWidget { final IconData icon; final String name; final String price; const _ProductCard(this.icon, this.name, this.price);
 @override Widget build(BuildContext context) { final t=Theme.of(context); return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: t.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.dividerColor)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: t.primaryColor.withValues(alpha: .07), borderRadius: BorderRadius.circular(15)), child: Icon(icon, size: 60, color: t.primaryColor))), const SizedBox(height: 12), Text(name, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(price, style: TextStyle(color: t.primaryColor, fontWeight: FontWeight.w900))])); }}

class _FontsPreview extends StatelessWidget {
  const _FontsPreview();
  @override Widget build(BuildContext context) => _Page(title: 'اختيار خط التطبيق', child: Column(children: const [
    _FontCard('Cairo — القاهرة', 'Cairo', 'كل احتياجاتك الطبية في مكان واحد\nMedical supplies, made simple.'),
    SizedBox(height: 14),
    _FontCard('Noto Kufi Arabic', 'NotoKufiArabic', 'كل احتياجاتك الطبية في مكان واحد\nMedical supplies, made simple.'),
    SizedBox(height: 14),
    _FontCard('SF Pro Rounded — الحالي', 'SF-Pro-Rounded-Regular', 'كل احتياجاتك الطبية في مكان واحد\nMedical supplies, made simple.'),
  ]));
}
class _FontCard extends StatelessWidget { final String name,font,sample; const _FontCard(this.name,this.font,this.sample);
 @override Widget build(BuildContext context)=>Container(width: double.infinity,padding: const EdgeInsets.all(18),decoration: BoxDecoration(color: Theme.of(context).cardColor,borderRadius: BorderRadius.circular(20),border: Border.all(color: Theme.of(context).dividerColor)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:TextStyle(fontFamily:font,fontSize:18,fontWeight:FontWeight.w800,color:Theme.of(context).primaryColor)),const SizedBox(height:10),Text(sample,style:TextStyle(fontFamily:font,fontSize:18,height:1.7))]));}

class _AboutPreview extends StatelessWidget { const _AboutPreview();
 @override Widget build(BuildContext context)=>_Page(title:'معلومات عنا',child:Column(children:[Image.asset('assets/images/sigma_primary_logo.png',width:280,height:110,fit:BoxFit.contain,color:Theme.of(context).brightness==Brightness.dark?Colors.white:null,colorBlendMode:Theme.of(context).brightness==Brightness.dark?BlendMode.srcIn:null),const SizedBox(height:18),const Text('سيجما للمستلزمات الطبية',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900)),const SizedBox(height:12),Text('نوفر منتجات ومستلزمات طبية موثوقة، مع تجربة شراء واضحة وخدمة توصيل تغطي محافظات مصر.',textAlign:TextAlign.center,style:TextStyle(height:1.8,color:Theme.of(context).hintColor)),const SizedBox(height:24),Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(22),border:Border.all(color:Theme.of(context).dividerColor)),child:const Column(children:[_Info(Icons.verified_user_outlined,'منتجات موثوقة'),Divider(),_Info(Icons.support_agent_rounded,'دعم متخصص'),Divider(),_Info(Icons.local_shipping_outlined,'شحن لجميع المحافظات')])),const SizedBox(height:24),const Text('تابعنا على',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:12),const Row(mainAxisAlignment:MainAxisAlignment.center,children:[_Social(Icons.facebook_rounded),SizedBox(width:12),_Social(Icons.camera_alt_outlined),SizedBox(width:12),_Social(Icons.play_circle_outline_rounded),SizedBox(width:12),_Social(Icons.public_rounded)])]));}
class _Info extends StatelessWidget {final IconData icon;final String text;const _Info(this.icon,this.text);@override Widget build(BuildContext context)=>ListTile(leading:Icon(icon,color:Theme.of(context).primaryColor),title:Text(text,style:const TextStyle(fontWeight:FontWeight.w700)));}
class _Social extends StatelessWidget {final IconData icon;const _Social(this.icon);@override Widget build(BuildContext context)=>CircleAvatar(radius:25,backgroundColor:Theme.of(context).primaryColor.withValues(alpha:.1),child:Icon(icon,color:Theme.of(context).primaryColor));}

class _ActivationPreview extends StatelessWidget {
  final bool approved;
  const _ActivationPreview({required this.approved});
  @override
  Widget build(BuildContext context) {
    final color = approved ? const Color(0xFF11875D) : const Color(0xFFC62828);
    return _Page(
      title: 'تفعيل الحساب',
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Icon(approved ? Icons.verified_rounded : Icons.info_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(
              approved ? 'تم تفعيل حسابك بنجاح. يمكنك الآن استخدام جميع الخدمات.' : 'يلزم تفعيل حسابك لإكمال استخدام خدمات سيجما.',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            )),
            if (!approved) const Icon(Icons.chevron_left_rounded, color: Colors.white),
          ]),
        ),
        const SizedBox(height: 24),
        if (!approved)
          Container(
            height: 570,
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Theme.of(context).dividerColor)),
            child: Column(children: [
              const ListTile(leading: CircleAvatar(child: Icon(Icons.support_agent)), title: Text('فريق تفعيل الحساب', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('متصل الآن'), trailing: Icon(Icons.circle, color: Color(0xFF18A66A), size: 12)),
              const Divider(height: 1),
              Expanded(child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  const Align(alignment: Alignment.centerLeft, child: _Bubble('مرحبًا، أرسل لنا المستندات المطلوبة وسنراجعها فورًا.', false)),
                  const Spacer(),
                  Container(height: 54, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(16)), child: const Row(children: [Icon(Icons.attach_file_rounded), SizedBox(width: 8), Expanded(child: Text('اكتب رسالتك...')), Icon(Icons.image_outlined), SizedBox(width: 8), CircleAvatar(child: Icon(Icons.send_rounded, size: 18))])),
                ]),
              )),
            ]),
          ),
      ]),
    );
  }
}
class _Bubble extends StatelessWidget{final String text;final bool mine;const _Bubble(this.text,this.mine);@override Widget build(BuildContext context)=>Container(constraints:const BoxConstraints(maxWidth:300),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:mine?Theme.of(context).primaryColor:Theme.of(context).primaryColor.withValues(alpha:.1),borderRadius:BorderRadius.circular(16)),child:Text(text,style:TextStyle(color:mine?Colors.white:null)));}

class _PaymentTwoPreview extends StatelessWidget {const _PaymentTwoPreview();@override Widget build(BuildContext context){final t=Theme.of(context);return _Page(title:'استكمال الطلب',child:Column(children:[const Icon(Icons.check_circle_rounded,color:Color(0xFF11875D),size:72),const SizedBox(height:12),const Text('تم سداد قيمة الطلب بنجاح',style:TextStyle(fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:6),Text('تبقت خطوة أخيرة لاستكمال طلبك',style:TextStyle(color:t.hintColor)),const SizedBox(height:24),Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:t.cardColor,borderRadius:BorderRadius.circular(22),border:Border.all(color:t.dividerColor)),child:const Column(children:[_PayRow('التأمين','250 ج.م',Icons.shield_outlined),Divider(height:28),_PayRow('ضريبة 14%','140 ج.م',Icons.receipt_long_outlined),Divider(height:28),_PayRow('الإجمالي المطلوب','390 ج.م',Icons.payments_outlined,strong:true)])),const SizedBox(height:18),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFFFF4E5),borderRadius:BorderRadius.circular(16)),child:const Row(children:[Icon(Icons.warning_amber_rounded,color:Color(0xFFE07800)),SizedBox(width:10),Expanded(child:Text('إذا عدت الآن، سيُنقل الطلب إلى قسم الطلبات المعلقة.'))])),const SizedBox(height:18),SizedBox(width:double.infinity,height:56,child:FilledButton(onPressed:(){},child:const Text('دفع 390 ج.م',style:TextStyle(fontWeight:FontWeight.w900)))),TextButton(onPressed:(){},child:const Text('العودة والدفع لاحقًا'))]));}}
class _PayRow extends StatelessWidget{final String name,value;final IconData icon;final bool strong;const _PayRow(this.name,this.value,this.icon,{this.strong=false});@override Widget build(BuildContext context)=>Row(children:[Icon(icon,color:Theme.of(context).primaryColor),const SizedBox(width:10),Expanded(child:Text(name,style:TextStyle(fontWeight:strong?FontWeight.w900:FontWeight.w600))),Text(value,style:TextStyle(fontWeight:FontWeight.w900,fontSize:strong?19:16,color:strong?Theme.of(context).primaryColor:null))]);}

class _BottomPagePreview extends StatelessWidget {
  final int index;
  const _BottomPagePreview({required this.index});
  static const titles = ['الرئيسية', 'الرسائل', 'السلة', 'طلباتي', 'الملف الشخصي'];
  static const icons = [Icons.home_rounded, Icons.chat_bubble_outline_rounded, Icons.shopping_cart_outlined, Icons.receipt_long_outlined, Icons.person_outline_rounded];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: _content())),
    bottomNavigationBar: NavigationBar(selectedIndex: index, destinations: List.generate(5, (i) => NavigationDestination(
      icon: Icon(icons[i]),
      selectedIcon: Container(width:54,height:38,decoration:BoxDecoration(color:Theme.of(context).primaryColor,borderRadius:BorderRadius.circular(14)),child:Icon(icons[i],color:Colors.white)),
      label: titles[i],
    ))),
  );

  Widget _content() => switch (index) {
    0 => const _HomeDemo(),
    1 => const _MessagesDemo(),
    2 => const _CartDemo(),
    3 => const _OrdersDemo(),
    _ => const _ProfileDemo(),
  };
}

class _HomeDemo extends StatelessWidget { const _HomeDemo();
  @override Widget build(BuildContext context) { final t=Theme.of(context); return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    Row(children:[Image.asset('assets/images/sigma_primary_logo.png',width:150,height:54,fit:BoxFit.contain,color:t.brightness==Brightness.dark?Colors.white:null,colorBlendMode:t.brightness==Brightness.dark?BlendMode.srcIn:null),const Spacer(),CircleAvatar(backgroundColor:t.primaryColor.withValues(alpha:.1),child:Icon(Icons.notifications_none_rounded,color:t.primaryColor))]),
    const SizedBox(height:14),const _Field('ابحث عن منتج طبي...',Icons.search_rounded,trailing:Icons.tune_rounded),const SizedBox(height:18),
    Container(height:155,padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF59C9FA),Color(0xFF0878F9)]),borderRadius:BorderRadius.circular(24)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('عروض سيجما الطبية',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),SizedBox(height:6),Text('خصم حتى 25% على أجهزة القياس',style:TextStyle(color:Colors.white)),Spacer(),Align(alignment:AlignmentDirectional.centerEnd,child:Icon(Icons.monitor_heart_rounded,color:Colors.white,size:54))])),
    const SizedBox(height:20),const _SectionTitle('الأقسام','عرض الكل'),const SizedBox(height:10),const SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[_Category(Icons.monitor_heart_outlined,'أجهزة القياس'),_Category(Icons.medical_services_outlined,'الإسعافات'),_Category(Icons.masks_outlined,'الحماية'),_Category(Icons.accessible_forward_outlined,'الحركة')])),
    const SizedBox(height:20),const _SectionTitle('صفقة اليوم','عرض الكل'),const SizedBox(height:10),const Row(children:[Expanded(child:_MiniProduct(Icons.thermostat_rounded,'ترمومتر رقمي','175 ج.م')),SizedBox(width:12),Expanded(child:_MiniProduct(Icons.monitor_heart_outlined,'جهاز ضغط','850 ج.م'))])]);}}

class _MessagesDemo extends StatelessWidget {const _MessagesDemo();@override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const _Field('ابحث في المحادثات',Icons.search_rounded),const SizedBox(height:18),const Text('المحادثات الأخيرة',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:10),_Conversation('فريق تفعيل الحساب','تم استلام المستندات وجارٍ مراجعتها','الآن',3,Icons.verified_user_outlined),_Conversation('خدمة العملاء','أهلًا بك، كيف يمكننا مساعدتك؟','10:42 ص',1,Icons.support_agent_rounded),_Conversation('متابعة الطلب #1048','طلبك خرج للتوصيل','أمس',0,Icons.local_shipping_outlined)]);}

class _CartDemo extends StatelessWidget {const _CartDemo();@override Widget build(BuildContext context){final t=Theme.of(context);return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Text('منتجان في السلة',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:12),const _CartItem(Icons.monitor_heart_outlined,'جهاز قياس ضغط رقمي','850 ج.م',1),const _CartItem(Icons.medical_information_outlined,'شنطة إسعافات أولية','299 ج.م',2),const SizedBox(height:12),Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:t.cardColor,borderRadius:BorderRadius.circular(20),border:Border.all(color:t.dividerColor)),child:const Column(children:[_TotalRow('الإجمالي الفرعي','1,448 ج.م'),SizedBox(height:10),_TotalRow('الشحن','يُحسب عند إتمام الطلب'),Divider(height:26),_TotalRow('الإجمالي','1,448 ج.م',strong:true)])),const SizedBox(height:16),SizedBox(height:56,child:FilledButton.icon(onPressed:(){},icon:const Icon(Icons.lock_outline_rounded),label:const Text('متابعة إتمام الطلب',style:TextStyle(fontWeight:FontWeight.w900))))]);}}

class _OrdersDemo extends StatelessWidget {const _OrdersDemo();@override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[_Filter('الكل',true),_Filter('قيد التنفيذ',false),_Filter('مكتملة',false),_Filter('معلقة',false)])),const SizedBox(height:18),const _OrderCard('#1048','12 سبتمبر 2026','1,448 ج.م','قيد التوصيل',Color(0xFF0878F9),Icons.local_shipping_outlined),const _OrderCard('#1031','2 سبتمبر 2026','390 ج.م','بانتظار سداد المرحلة الثانية',Color(0xFFE07800),Icons.schedule_rounded),const _OrderCard('#998','20 أغسطس 2026','675 ج.م','تم التسليم',Color(0xFF11875D),Icons.check_circle_outline_rounded)]);}

class _ProfileDemo extends StatelessWidget {const _ProfileDemo();@override Widget build(BuildContext context){final t=Theme.of(context);return Column(children:[Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF59C9FA),Color(0xFF0878F9)]),borderRadius:BorderRadius.circular(24)),child:const Row(children:[CircleAvatar(radius:30,backgroundColor:Colors.white24,child:Icon(Icons.person_rounded,color:Colors.white,size:34)),SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('أحمد محمد',style:TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),Text('ahmed@example.com',style:TextStyle(color:Colors.white70))])),Icon(Icons.edit_outlined,color:Colors.white)])),const SizedBox(height:14),Row(children:[Expanded(child:_Balance('رصيد المشتريات','1.2K ج.م',Icons.account_balance_wallet_outlined,onTap:()=>_open(context,const _WalletDetailDemo(insurance:false)))),const SizedBox(width:10),Expanded(child:_Balance('رصيد التأمين','750 ج.م',Icons.shield_outlined,onTap:()=>_open(context,const _WalletDetailDemo(insurance:true))))]),const SizedBox(height:14),Material(color:const Color(0xFFFFF4E5),borderRadius:BorderRadius.circular(18),child:InkWell(borderRadius:BorderRadius.circular(18),onTap:()=>_open(context,const _PendingOrdersDemo()),child:const Padding(padding:EdgeInsets.all(15),child:Row(children:[Icon(Icons.pending_actions_rounded,color:Color(0xFFE07800)),SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('الطلبات المعلقة',style:TextStyle(fontWeight:FontWeight.w900)),Text('طلبان يحتاجان لاستكمال السداد')])),CircleAvatar(radius:15,backgroundColor:Color(0xFFE07800),child:Text('2',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900))),SizedBox(width:5),Icon(Icons.chevron_left_rounded)])))),const SizedBox(height:14),Container(decoration:BoxDecoration(color:t.cardColor,borderRadius:BorderRadius.circular(20),border:Border.all(color:t.dividerColor)),child:const Column(children:[_Menu(Icons.receipt_long_outlined,'طلباتي'),Divider(height:1),_Menu(Icons.location_on_outlined,'العناوين'),Divider(height:1),_Menu(Icons.language_rounded,'اللغة: العربية / English'),Divider(height:1),_Menu(Icons.dark_mode_outlined,'المظهر'),Divider(height:1),_Menu(Icons.privacy_tip_outlined,'سياسة الخصوصية'),Divider(height:1),_Menu(Icons.description_outlined,'الشروط والأحكام'),Divider(height:1),_Menu(Icons.info_outline_rounded,'معلومات عنا')]))]);}
  static void _open(BuildContext context,Widget page)=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>Directionality(textDirection:TextDirection.rtl,child:page)));
}

class _SectionTitle extends StatelessWidget{final String title,action;const _SectionTitle(this.title,this.action);@override Widget build(BuildContext context)=>Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900))),Text(action,style:TextStyle(color:Theme.of(context).primaryColor,fontWeight:FontWeight.w700))]);}
class _Category extends StatelessWidget{final IconData icon;final String title;const _Category(this.icon,this.title);@override Widget build(BuildContext context)=>Container(width:102,margin:const EdgeInsetsDirectional.only(end:10),child:Column(children:[Container(height:72,decoration:BoxDecoration(color:Theme.of(context).primaryColor.withValues(alpha:.09),borderRadius:BorderRadius.circular(20)),child:Center(child:Icon(icon,color:Theme.of(context).primaryColor,size:34))),const SizedBox(height:7),Text(title,textAlign:TextAlign.center,maxLines:1)]));}
class _MiniProduct extends StatelessWidget{final IconData icon;final String name,price;const _MiniProduct(this.icon,this.name,this.price);@override Widget build(BuildContext context)=>Container(height:180,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(20),border:Border.all(color:Theme.of(context).dividerColor)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Center(child:Icon(icon,color:Theme.of(context).primaryColor,size:55))),Text(name,style:const TextStyle(fontWeight:FontWeight.w800)),Text(price,style:TextStyle(color:Theme.of(context).primaryColor,fontWeight:FontWeight.w900))]));}
class _Conversation extends StatelessWidget{final String title,message,time;final int unread;final IconData icon;const _Conversation(this.title,this.message,this.time,this.unread,this.icon);@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(18),border:Border.all(color:Theme.of(context).dividerColor)),child:Row(children:[CircleAvatar(radius:25,backgroundColor:Theme.of(context).primaryColor.withValues(alpha:.1),child:Icon(icon,color:Theme.of(context).primaryColor)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),Text(message,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:Theme.of(context).hintColor))])),Column(children:[Text(time,style:TextStyle(fontSize:11,color:Theme.of(context).hintColor)),if(unread>0)Container(margin:const EdgeInsets.only(top:7),width:22,height:22,decoration:BoxDecoration(color:Theme.of(context).primaryColor,shape:BoxShape.circle),child:Center(child:Text('$unread',style:const TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.bold))))]) ]));}
class _CartItem extends StatelessWidget{final IconData icon;final String name,price;final int count;const _CartItem(this.icon,this.name,this.price,this.count);@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(18),border:Border.all(color:Theme.of(context).dividerColor)),child:Row(children:[Container(width:80,height:80,decoration:BoxDecoration(color:Theme.of(context).primaryColor.withValues(alpha:.08),borderRadius:BorderRadius.circular(14)),child:Icon(icon,size:40,color:Theme.of(context).primaryColor)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:8),Text(price,style:TextStyle(color:Theme.of(context).primaryColor,fontWeight:FontWeight.w900))])),Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:6),decoration:BoxDecoration(color:Theme.of(context).primaryColor.withValues(alpha:.08),borderRadius:BorderRadius.circular(12)),child:Text('−  $count  +',style:TextStyle(color:Theme.of(context).primaryColor,fontWeight:FontWeight.w900))) ]));}
class _TotalRow extends StatelessWidget{final String name,value;final bool strong;const _TotalRow(this.name,this.value,{this.strong=false});@override Widget build(BuildContext context)=>Row(children:[Expanded(child:Text(name,style:TextStyle(fontWeight:strong?FontWeight.w900:FontWeight.w500))),Text(value,style:TextStyle(fontWeight:FontWeight.w900,fontSize:strong?18:14,color:strong?Theme.of(context).primaryColor:null))]);}
class _OrderCard extends StatelessWidget{final String number,date,total,status;final Color color;final IconData icon;const _OrderCard(this.number,this.date,this.total,this.status,this.color,this.icon);@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(19),border:Border.all(color:Theme.of(context).dividerColor)),child:Column(children:[Row(children:[CircleAvatar(backgroundColor:color.withValues(alpha:.1),child:Icon(icon,color:color)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('طلب $number',style:const TextStyle(fontWeight:FontWeight.w900)),Text(date,style:TextStyle(color:Theme.of(context).hintColor,fontSize:12))])),Text(total,style:const TextStyle(fontWeight:FontWeight.w900))]),const SizedBox(height:13),Align(alignment:AlignmentDirectional.centerStart,child:Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:7),decoration:BoxDecoration(color:color.withValues(alpha:.1),borderRadius:BorderRadius.circular(30)),child:Text(status,style:TextStyle(color:color,fontWeight:FontWeight.w800,fontSize:12))))]));}
class _Balance extends StatelessWidget{final String name,value;final IconData icon;final VoidCallback? onTap;const _Balance(this.name,this.value,this.icon,{this.onTap});@override Widget build(BuildContext context)=>Material(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(18),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(18),child:Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),border:Border.all(color:Theme.of(context).dividerColor)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(icon,color:Theme.of(context).primaryColor),const Spacer(),const Icon(Icons.chevron_left_rounded,size:18)]),const SizedBox(height:10),Text(name,style:TextStyle(fontSize:12,color:Theme.of(context).hintColor)),Text(value,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900))]))));}
class _Menu extends StatelessWidget{final IconData icon;final String title;const _Menu(this.icon,this.title);@override Widget build(BuildContext context)=>ListTile(leading:Icon(icon,color:Theme.of(context).primaryColor),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w700)),trailing:const Icon(Icons.chevron_left_rounded));}

class _PendingOrdersDemo extends StatelessWidget {const _PendingOrdersDemo();@override Widget build(BuildContext context)=>_Page(title:'الطلبات المعلقة',child:Column(children:[
  Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFFFF4E5),borderRadius:BorderRadius.circular(16)),child:const Row(children:[Icon(Icons.info_outline_rounded,color:Color(0xFFE07800)),SizedBox(width:10),Expanded(child:Text('هذه الطلبات بانتظار سداد المرحلة الثانية لاستكمالها.'))])),
  const SizedBox(height:14),const _PendingCard('#1031','250 ج.م','140 ج.م','390 ج.م'),const _PendingCard('#1027','600 ج.م','280 ج.م','880 ج.م')
]));}
class _PendingCard extends StatelessWidget{final String order,insurance,tax,total;const _PendingCard(this.order,this.insurance,this.tax,this.total);@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(20),border:Border.all(color:Theme.of(context).dividerColor)),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Row(children:[Expanded(child:Text('طلب $order',style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900))),TextButton.icon(onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const Directionality(textDirection:TextDirection.rtl,child:_PendingInvoiceDemo()))),icon:const Icon(Icons.receipt_long_outlined,size:18),label:const Text('عرض الفاتورة'))]),const Divider(height:20),_TotalRow('التأمين',insurance),const SizedBox(height:7),_TotalRow('ضريبة 14%',tax),const Divider(height:22),_TotalRow('المبلغ المطلوب',total,strong:true),const SizedBox(height:14),SizedBox(height:48,child:FilledButton(onPressed:(){},child:const Text('استكمال الدفع',style:TextStyle(fontWeight:FontWeight.w900))))]));}

class _WalletDetailDemo extends StatelessWidget {final bool insurance;const _WalletDetailDemo({required this.insurance});@override Widget build(BuildContext context){final color=insurance?const Color(0xFF11875D):Theme.of(context).primaryColor;return _Page(title:insurance?'رصيد التأمين':'رصيد المشتريات',child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:LinearGradient(colors:[color.withValues(alpha:.72),color]),borderRadius:BorderRadius.circular(24)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(insurance?Icons.shield_outlined:Icons.account_balance_wallet_outlined,color:Colors.white,size:30),const SizedBox(height:18),Text(insurance?'الرصيد المتاح':'الرصيد الحالي',style:const TextStyle(color:Colors.white70)),Text(insurance?'750 ج.م':'1.2K ج.م',style:const TextStyle(color:Colors.white,fontSize:30,fontWeight:FontWeight.w900)),const SizedBox(height:14),SizedBox(width:double.infinity,child:FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:Colors.white,foregroundColor:color),onPressed:(){},icon:const Icon(Icons.add_rounded),label:const Text('إيداع رصيد',style:TextStyle(fontWeight:FontWeight.w900))))])),
  const SizedBox(height:14),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:color.withValues(alpha:.08),borderRadius:BorderRadius.circular(16)),child:Row(children:[Icon(Icons.info_outline_rounded,color:color),const SizedBox(width:9),Expanded(child:Text(insurance?'رصيد التأمين مخصص لتأمين الطلبات فقط، ويمكن استخدامه مرة أخرى بعد المدة المحددة.':'رصيد المشتريات يُستخدم في المشتريات فقط.',style:const TextStyle(height:1.55)))])),
  const SizedBox(height:20),const Text('سجل الإيداعات',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:9),const _Ledger('500 ج.م','12 سبتمبر 2026 · 10:35 ص'),const _Ledger('250 ج.م','2 سبتمبر 2026 · 6:20 م'),
  if(insurance)...[const SizedBox(height:15),const Text('التأمينات المنتظر استردادها',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:9),_Refund('#1048','جهاز قياس ضغط رقمي','250 ج.م','يُسترد في 22 سبتمبر 2026'),_Refund('#1039','جهاز أكسجين محمول','600 ج.م','يُسترد في 28 سبتمبر 2026')]
]));}}
class _Ledger extends StatelessWidget{final String value,date;const _Ledger(this.value,this.date);@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(17),border:Border.all(color:Theme.of(context).dividerColor)),child:Row(children:[CircleAvatar(backgroundColor:const Color(0xFF11875D).withValues(alpha:.1),child:const Icon(Icons.check_rounded,color:Color(0xFF11875D))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('تم الإيداع بنجاح',style:TextStyle(fontWeight:FontWeight.w800)),Text(date,style:TextStyle(color:Theme.of(context).hintColor,fontSize:11))])),Text(value,style:const TextStyle(color:Color(0xFF11875D),fontWeight:FontWeight.w900))]));}
class _Refund extends StatelessWidget{final String order,product,value,date;const _Refund(this.order,this.product,this.value,this.date);@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(17),border:Border.all(color:Theme.of(context).dividerColor)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text('الطلب $order',style:const TextStyle(fontWeight:FontWeight.w900))),Text(value,style:const TextStyle(color:Color(0xFF11875D),fontWeight:FontWeight.w900))]),Text(product,style:TextStyle(color:Theme.of(context).hintColor)),const SizedBox(height:7),Row(children:[const Icon(Icons.event_available_outlined,size:18,color:Color(0xFF11875D)),const SizedBox(width:6),Text(date,style:const TextStyle(color:Color(0xFF11875D),fontWeight:FontWeight.w700,fontSize:12))]) ]));}

class _CheckoutDemo extends StatefulWidget {const _CheckoutDemo();@override State<_CheckoutDemo> createState()=>_CheckoutDemoState();}
class _CheckoutDemoState extends State<_CheckoutDemo>{int payment=0;bool coupon=false;@override Widget build(BuildContext context){final t=Theme.of(context);return _Page(title:'مراجعة ودفع الطلب',child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  const Text('عنوان التوصيل',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:9),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:t.cardColor,borderRadius:BorderRadius.circular(18),border:Border.all(color:t.dividerColor)),child:const Row(children:[Icon(Icons.location_on_outlined,color:Color(0xFF0878F9)),SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('القاهرة · مدينة نصر',style:TextStyle(fontWeight:FontWeight.w900)),Text('12 شارع عباس العقاد، الدور الثاني')])),Icon(Icons.edit_outlined)])),
  const SizedBox(height:18),const Text('طريقة الشحن',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:9),const Row(children:[Expanded(child:_ShippingOption('شحن سيجما','60 ج.م','4–7 أيام',true)),SizedBox(width:10),Expanded(child:_ShippingOption('شحن عادي','40 ج.م','10–15 يومًا',false))]),
  const SizedBox(height:18),const Text('ملخص الفاتورة',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:9),Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:t.cardColor,borderRadius:BorderRadius.circular(18),border:Border.all(color:t.dividerColor)),child:Column(children:[const _TotalRow('قيمة المنتجات','1,149 ج.م'),const SizedBox(height:8),const _TotalRow('شحن سيجما','60 ج.م'),if(coupon)...[const SizedBox(height:8),const _TotalRow('خصم الكوبون','−115 ج.م')],const Divider(height:24),_TotalRow('الإجمالي',coupon?'1,094 ج.م':'1,209 ج.م',strong:true),const SizedBox(height:12),InkWell(onTap:()=>setState(()=>coupon=!coupon),child:Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:11),decoration:BoxDecoration(color:t.primaryColor.withValues(alpha:.07),borderRadius:BorderRadius.circular(13)),child:Row(children:[Icon(Icons.local_offer_outlined,color:t.primaryColor),const SizedBox(width:8),Expanded(child:Text(coupon?'تم تطبيق الكوبون SIGMA10':'هل لديك كوبون خصم؟',style:const TextStyle(fontWeight:FontWeight.w800))),Icon(coupon?Icons.check_circle_rounded:Icons.chevron_left_rounded,color:coupon?const Color(0xFF11875D):t.primaryColor)])))])),
  const SizedBox(height:18),const Text('طريقة الدفع',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:9),_PaymentChoice(0,payment,'رصيد المشتريات','رصيدك 1.2K ج.م',Icons.account_balance_wallet_outlined,onTap:()=>setState(()=>payment=0),action:'إيداع رصيد'),_PaymentChoice(1,payment,'فيزا أو ماستركارد','دفع آمن من خلال بوابة الدفع',Icons.credit_card_rounded,onTap:()=>setState(()=>payment=1)),_PaymentChoice(2,payment,'محفظة إلكترونية','فودافون كاش والمحافظ المدعومة',Icons.phone_android_rounded,onTap:()=>setState(()=>payment=2)),
  const SizedBox(height:12),SizedBox(height:55,child:FilledButton.icon(onPressed:(){},icon:const Icon(Icons.lock_outline_rounded),label:Text(payment==0?'الدفع من رصيد المشتريات':'الانتقال إلى بوابة الدفع',style:const TextStyle(fontWeight:FontWeight.w900))))
]));}}
class _ShippingOption extends StatelessWidget{final String title,price,time;final bool selected;const _ShippingOption(this.title,this.price,this.time,this.selected);@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:selected?Theme.of(context).primaryColor.withValues(alpha:.08):Theme.of(context).cardColor,borderRadius:BorderRadius.circular(17),border:Border.all(color:selected?Theme.of(context).primaryColor:Theme.of(context).dividerColor,width:selected?2:1)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(selected?Icons.radio_button_checked:Icons.radio_button_off,color:Theme.of(context).primaryColor,size:19),const SizedBox(width:5),Expanded(child:Text(title,style:const TextStyle(fontWeight:FontWeight.w900)))]),const SizedBox(height:7),Text(price,style:TextStyle(color:Theme.of(context).primaryColor,fontWeight:FontWeight.w900)),Text(time,style:TextStyle(color:Theme.of(context).hintColor,fontSize:11))]));}
class _PaymentChoice extends StatelessWidget{final int value,selected;final String title,subtitle;final IconData icon;final VoidCallback onTap;final String? action;const _PaymentChoice(this.value,this.selected,this.title,this.subtitle,this.icon,{required this.onTap,this.action});@override Widget build(BuildContext context){final active=value==selected;return Container(margin:const EdgeInsets.only(bottom:9),decoration:BoxDecoration(color:active?Theme.of(context).primaryColor.withValues(alpha:.07):Theme.of(context).cardColor,borderRadius:BorderRadius.circular(17),border:Border.all(color:active?Theme.of(context).primaryColor:Theme.of(context).dividerColor)),child:ListTile(onTap:onTap,leading:CircleAvatar(backgroundColor:Theme.of(context).primaryColor.withValues(alpha:.1),child:Icon(icon,color:Theme.of(context).primaryColor)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text(subtitle),trailing:action!=null?Text(action!,style:TextStyle(color:Theme.of(context).primaryColor,fontWeight:FontWeight.w800)):Icon(active?Icons.radio_button_checked:Icons.radio_button_off,color:Theme.of(context).primaryColor)));}}

class _PendingInvoiceDemo extends StatelessWidget{const _PendingInvoiceDemo();@override Widget build(BuildContext context)=>_Page(title:'فاتورة الطلب #1031',child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const _InvoiceProduct(Icons.monitor_heart_outlined,'جهاز قياس ضغط رقمي','1 × 850 ج.م'),const _InvoiceProduct(Icons.medical_information_outlined,'شنطة إسعافات أولية','1 × 299 ج.م'),const SizedBox(height:10),Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(18),border:Border.all(color:Theme.of(context).dividerColor)),child:const Column(children:[_TotalRow('قيمة المنتجات','1,149 ج.م'),SizedBox(height:8),_TotalRow('الشحن','60 ج.م'),Divider(height:24),_TotalRow('المرحلة الأولى المدفوعة','1,209 ج.م',strong:true)])),const SizedBox(height:12),Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFFFFF4E5),borderRadius:BorderRadius.circular(18)),child:const Column(children:[_TotalRow('التأمين','250 ج.م'),SizedBox(height:8),_TotalRow('ضريبة 14%','140 ج.م'),Divider(height:24),_TotalRow('المتبقي','390 ج.م',strong:true)])),const SizedBox(height:14),SizedBox(height:54,child:FilledButton(onPressed:(){},child:const Text('استكمال الدفع',style:TextStyle(fontWeight:FontWeight.w900))))]));}
class _InvoiceProduct extends StatelessWidget{final IconData icon;final String title,meta;const _InvoiceProduct(this.icon,this.title,this.meta);@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(17),border:Border.all(color:Theme.of(context).dividerColor)),child:Row(children:[Container(width:68,height:68,decoration:BoxDecoration(color:Theme.of(context).primaryColor.withValues(alpha:.08),borderRadius:BorderRadius.circular(13)),child:Icon(icon,color:Theme.of(context).primaryColor,size:34)),const SizedBox(width:11),Expanded(child:Text(title,style:const TextStyle(fontWeight:FontWeight.w900))),Text(meta,style:TextStyle(color:Theme.of(context).primaryColor,fontWeight:FontWeight.w800))]));}
