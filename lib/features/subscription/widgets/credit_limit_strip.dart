import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/screens/monthly_subscription_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';

Future<bool> validateCustomerCartLimit(
    BuildContext context, double amount) async {
  try {
    final loggedIn =
        Provider.of<AuthController>(context, listen: false).isLoggedIn();
    if (!loggedIn) return true;
    final response =
        await di.sl<DioClient>().get('/api/v1/customer/purchasing-limit');
    final limit = response.data['limit'] as Map?;
    final eligibility = response.data['eligibility'] as Map?;
    if (limit?['unlimited_initial_checkout'] == true &&
        eligibility?['can_checkout'] == true) {
      return true;
    }
    final available =
        loggedIn ? double.tryParse('${limit?['available_limit']}') ?? 0 : 0.0;
    final reserved = double.tryParse('${limit?['cart_reserved_amount']}') ?? 0;
    final insufficient = limit?['unlimited_initial_checkout'] != true &&
        amount - reserved > available;
    if (!insufficient && (!loggedIn || eligibility?['can_checkout'] == true)) {
      return true;
    }
    if (!context.mounted) return false;
    await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(insufficient
                    ? 'الحد الائتماني غير كافٍ'
                    : 'متطلبات الشراء'),
                content: Text(insufficient
                    ? 'الحد الائتماني المتاح ${available.toStringAsFixed(2)} ج.م. زد الحد أو اختر باقة أعلى أو قلل المنتجات.'
                    : '${eligibility?['message'] ?? 'أكمل تفعيل الحساب والباقة الشهرية.'}'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('العودة للسلة وتقليل المنتجات')),
                  FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const MonthlySubscriptionScreen()));
                      },
                      child: const Text('زيادة الحد أو ترقية الباقة'))
                ]));
    return false;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تعذر التحقق من الحد. أعد المحاولة قبل الدفع.')));
    }
    return false;
  }
}

class CreditLimitStrip extends StatefulWidget {
  final bool cart;
  final bool profile;
  const CreditLimitStrip({super.key, this.cart = false, this.profile = false});
  @override
  State<CreditLimitStrip> createState() => _CreditLimitStripState();
}

class _CreditLimitStripState extends State<CreditLimitStrip>
    with WidgetsBindingObserver {
  Timer? refresh;
  Map<String, dynamic>? limit;
  bool failed = false;
  Future<void> load() async {
    try {
      final response =
          await di.sl<DioClient>().get('/api/v1/customer/purchasing-limit');
      if (mounted) {
        setState(() {
          limit = response.data['limit'] == null
              ? null
              : Map<String, dynamic>.from(response.data['limit']);
          failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh = Timer.periodic(const Duration(seconds: 60), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        load();
      }
    });
    load();
  }

  @override
  void dispose() {
    refresh?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) load();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AuthController>().isLoggedIn()) {
      return const SizedBox.shrink();
    }
    final accountEligibility =
        context.watch<ProfileController>().userInfoModel?.purchaseEligibility;
    if (accountEligibility?['show_credit_indicator'] == false ||
        limit?['show_credit_indicator'] == false) {
      return const SizedBox.shrink();
    }
    if (failed) {
      return TextButton(
          onPressed: load,
          child: const Text('تعذر تحميل الحد الائتماني. إعادة المحاولة'));
    }
    if (limit == null) return const SizedBox.shrink();
    final profileEligibility =
        context.watch<ProfileController>().userInfoModel?.purchaseEligibility;
    final profileSubscription = profileEligibility?['subscription'] as Map?;
    final profileLimit = profileSubscription?['allowance'] as Map?;
    final current = profileLimit != null &&
            (profileLimit['has_active_package'] == true ||
                (profileEligibility?['initial_order_exception_available'] !=
                        true &&
                    profileEligibility?['can_resume_initial_checkout'] != true))
        ? profileLimit
        : limit!;
    final cart = context.watch<CartController>().cartList;
    final amount = cart.where((c) => c.isChecked == true).fold<double>(
        0,
        (sum, c) =>
            sum + ((c.price ?? 0) - (c.discount ?? 0)) * (c.quantity ?? 0));
    final granted = double.tryParse('${current['granted_limit']}') ?? 0;
    final available = double.tryParse('${current['available_limit']}') ?? 0;
    final reserved =
        double.tryParse('${current['open_checkout_reserved_amount']}') ?? 0;
    final projected = available - (amount == reserved ? 0 : amount);
    final ratio = granted > 0 ? projected / granted : 0;
    final color = ratio > .5
        ? const Color(0xFF14613D)
        : ratio > .1
            ? const Color(0xFF885000)
            : const Color(0xFFB42318);
    final text = ratio > .5
        ? 'متاح'
        : ratio > .1
            ? 'انخفض الحد المتبقي'
            : 'الحد المتبقي منخفض';
    return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(12)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.cart ? 'مؤشر الأئتمان' : 'الحد الائتماني',
              style: Theme.of(context).textTheme.titleMedium),
          Text('المتاح ${available.toStringAsFixed(2)} ج.م · $text',
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          if (widget.profile)
            Text(
                'الممنوح ${granted.toStringAsFixed(2)} ج.م · المستخدم أو المحجوز ${current['committed_limit']} ج.م'),
          Text(
              'السلة ${amount.toStringAsFixed(2)} ج.م · المتبقي المتوقع ${projected.toStringAsFixed(2)} ج.م'),
          const Text('سماح بالشراء؛ تدفع قيمة الطلب كاملة بوسيلة دفع فعلية.'),
          if (widget.profile)
            TextButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MonthlySubscriptionScreen()));
                  await load();
                },
                child: Text(current['has_active_package'] == true
                    ? 'زيادة الحد أو ترقية الباقة'
                    : 'اختيار باقة شهرية')),
          if (projected < 0 || available == 0)
            TextButton(
                onPressed: () => showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                            title: const Text('الحد الائتماني غير كافٍ'),
                            content: Text(
                                'الحد المتاح ${available.toStringAsFixed(2)} ج.م. زد الحد أو اختر باقة أعلى أو قلل المنتجات.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('تقليل المنتجات')),
                              FilledButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const MonthlySubscriptionScreen()));
                                  },
                                  child:
                                      const Text('زيادة الحد أو ترقية الباقة'))
                            ])),
                child: const Text('خيارات الحد الائتماني')),
        ]));
  }
}
