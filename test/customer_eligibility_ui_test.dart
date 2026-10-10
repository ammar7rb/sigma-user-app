import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/widgets/customer_account_notices.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/models/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/widgets/customer_order_state.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/widgets/monthly_subscription_summary.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/widgets/subscription_expiry_banner.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/domain/models/profile_model.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + 0.05) / ((x > y ? y : x) + 0.05);
}

void main() {
  setUpAll(() async {
    await (FontLoader('Cairo')
          ..addFont(rootBundle.load('assets/fonts/brand/Cairo.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  test('light surfaces have readable text and icons, including pending payment',
      () {
    final theme = light(), c = theme.colorScheme;
    for (final pair in [
      [c.onPrimary, c.primary],
      [c.onPrimaryContainer, c.primaryContainer],
      [c.onSecondaryContainer, c.secondaryContainer],
      [c.onSecondary, c.secondary],
      [c.error, c.surface],
      [c.onError, c.error],
      [theme.hintColor, theme.cardColor],
      [theme.iconTheme.color!, theme.cardColor]
    ]) {
      expect(contrast(pair[0], pair[1]), greaterThanOrEqualTo(4.5));
    }
  });
  test(
      'profile retains separate journey, freeze, activation and subscription states',
      () {
    final p = ProfileModel.fromJson({
      'purchase_eligibility': {
        'onboarding_journey': 'checkout_first',
        'account_activated': false,
        'administratively_frozen': false,
        'can_checkout': true,
        'subscription': {'status': 'expired', 'active': false}
      }
    });
    expect(p.purchaseEligibility?['can_checkout'], true);
    expect(p.toJson()['purchase_eligibility']['subscription']['active'], false);
  });
  testWidgets('subscription banner appears only after expiry', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body:
                SubscriptionExpiryBanner(subscription: {'status': 'active'}))));
    expect(find.textContaining('انتهى اشتراكك'), findsNothing);
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SubscriptionExpiryBanner(
                subscription: {'status': 'expired'}))));
    expect(find.textContaining('انتهى اشتراكك'), findsOneWidget);
  });

  testWidgets(
      'global activation and expiry banners remain independent across content changes',
      (tester) async {
    final auth = _AuthStub();
    final profile = _ProfileStub()
      ..profile = ProfileModel.fromJson({
        'activation': {'is_active': false, 'message': 'حسابك بانتظار التفعيل'},
        'purchase_eligibility': {
          'subscription': {'status': 'expired'}
        }
      });
    var renewals = 0;
    Widget app(String screen) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthController>.value(value: auth),
              ChangeNotifierProvider<ProfileController>.value(value: profile)
            ],
            child: MaterialApp(
                theme: light(),
                home: CustomerAccountNotices(
                    onRenew: () => renewals++,
                    child: Scaffold(body: Text(screen)))));
    await tester.pumpWidget(app('المنتجات'));
    expect(find.text('حسابك بانتظار التفعيل'), findsOneWidget);
    expect(find.textContaining('انتهى اشتراكك'), findsOneWidget);
    await tester.pumpWidget(app('إتمام الشراء'));
    expect(find.text('حسابك بانتظار التفعيل'), findsOneWidget);
    await tester.tap(find.textContaining('انتهى اشتراكك'));
    expect(renewals, 1);
    profile.profile = ProfileModel.fromJson({
      'activation': {'is_active': true},
      'purchase_eligibility': {
        'subscription': {'status': 'expired'}
      }
    });
    profile.notifyListeners();
    await tester.pump();
    expect(find.text('حسابك بانتظار التفعيل'), findsNothing);
    expect(find.textContaining('انتهى اشتراكك'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
    profile.dispose();
  });
  testWidgets('button text follows actual light and dark backgrounds',
      (tester) async {
    for (final surface in [
      const Color(0xFF3B9BFF),
      const Color(0xFFFE961C),
      const Color(0xFF075ACB),
      Colors.white
    ]) {
      await tester.pumpWidget(MaterialApp(
          theme: light(),
          home: Scaffold(
              body: CustomButton(
                  buttonText: 'متابعة',
                  backgroundColor: surface,
                  onTap: () {}))));
      final label = tester.widget<Text>(find.text('متابعة'));
      expect(contrast(label.style!.color!, surface), greaterThanOrEqualTo(4.5));
    }
  });
  for (final entry in [('light', light()), ('dark', dark)]) {
    testWidgets('RTL pending payment and order are readable in ${entry.$1}',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final order = Orders()
        ..orderStatus = 'pending'
        ..customerFulfillmentStatus = 'pending_requirements'
        ..customerPendingReasons = [
          'account_activation',
          'monthly_subscription'
        ];
      await tester.pumpWidget(MaterialApp(
          theme: entry.$2,
          home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                  appBar: AppBar(title: const Text('الاشتراك الشهري')),
                  body: SingleChildScrollView(
                      child: Column(children: [
                    const SubscriptionExpiryBanner(
                        subscription: {'status': 'expired'}),
                    CustomerOrderState(order: order),
                    const Padding(
                        padding: EdgeInsets.all(20),
                        child: MonthlySubscriptionSummary(subscription: {
                          'active': false,
                          'status': 'expired',
                          'price': 100,
                          'currency_code': 'EGP',
                          'open_payment': {'status': 'pending_review'}
                        })),
                  ]))))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('الدفع قيد المراجعة'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_outlined), findsNWidgets(2));
      expect(find.text('تواصل لتفعيل الحساب'), findsOneWidget);
      await expectLater(find.byType(Scaffold),
          matchesGoldenFile('goldens/customer_eligibility_${entry.$1}.png'));
    });
  }
}

class _AuthStub extends ChangeNotifier implements AuthController {
  @override
  bool isLoggedIn() => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProfileStub extends ChangeNotifier implements ProfileController {
  ProfileModel? profile;
  @override
  ProfileModel? get userInfoModel => profile;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
