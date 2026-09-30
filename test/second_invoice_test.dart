import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_insurance/controllers/customer_order_insurance_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_insurance/domain/models/customer_order_insurance_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_insurance/domain/repositories/customer_order_insurance_repository.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_insurance/screens/customer_order_insurance_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/app_localization.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart' as app;
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';
import 'package:provider/provider.dart';

Map<String, dynamic> invoice(
        {double tax = 14,
        String status = 'pending_payment',
        bool payable = true}) =>
    {
      'claim': {
        'order_reference': '#100010',
        'purchase_amount': 100,
        'tax': {'amount': tax},
        'insurance': {
          'amount': 50,
          'status': status,
          'payment_status': 'unpaid'
        },
        'insurance_balance_paid': 0,
        'total_amount': 50 + tax,
        'external_amount_due': 50 + tax,
        'can_pay': payable,
        'support_available': true,
      },
      'insurance_balance': {'available_balance': 60, 'held_balance': 100},
      'payment_options': {
        'insurance_balance': true,
        'offline_payment': true,
        'offline_methods': [
          {'id': '1', 'method_name': 'InstaPay', 'payment_channel': 'instapay'}
        ]
      },
    };

class _Repository implements CustomerOrderInsuranceRepository {
  Map<String, dynamic> data = invoice();
  @override
  Future<ApiResponseModel> getClaim(int orderId) async =>
      ApiResponseModel.withSuccess(Response(
          data: data,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/claim/$orderId')));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Splash extends SplashController {
  _Splash() : super(splashServiceInterface: null);
  @override
  ConfigModel get configModel => ConfigModel(
      currencyModel: 'single_currency',
      currencySymbolPosition: 'right',
      decimalPointSettings: 2);
  @override
  CurrencyList get myCurrency => CurrencyList(symbol: 'EGP', exchangeRate: 1);
}

class _LoadedLocalization extends LocalizationsDelegate<AppLocalization> {
  final AppLocalization value;
  const _LoadedLocalization(this.value);
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<AppLocalization> load(Locale locale) => SynchronousFuture(value);
  @override
  bool shouldReload(_LoadedLocalization old) => old.value != value;
}

void main() {
  test('server payability and remaining insurance control payment access', () {
    final data = invoice();
    data['claim']['insurance_balance_paid'] = 50;
    final claim = CustomerOrderInsuranceEnvelope.fromJson(data).claim;
    expect(claim.insuranceAmountDue, 0);
    expect(
        CustomerOrderInsuranceEnvelope.fromJson(invoice(payable: false))
            .claim
            .canPay,
        isFalse);
    expect(
        CustomerOrderInsuranceEnvelope.fromJson(invoice(status: 'cancelled'))
            .claim
            .canPay,
        isFalse);
    expect(
        CustomerOrderInsuranceEnvelope.fromJson(
                invoice(status: 'pending_review'))
            .claim
            .canPay,
        isFalse);
  });

  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final isDark in [false, true]) {
      testWidgets(
          'invoice refreshes and renders ${locale.languageCode}, dark=$isDark',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = _Repository();
        final controller = CustomerOrderInsuranceController(repository: repo);
        final splash = _Splash();
        final localization = AppLocalization(locale);
        await tester.runAsync(localization.load);
        await tester.pumpWidget(MultiProvider(
            providers: [
              ChangeNotifierProvider<CustomerOrderInsuranceController>.value(
                  value: controller),
              ChangeNotifierProvider<SplashController>.value(value: splash),
            ],
            child: MaterialApp(
              key: ValueKey('invoice-${locale.languageCode}-$isDark'),
              navigatorKey: app.navigatorKey,
              locale: locale,
              theme: isDark ? dark : light(),
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: [
                _LoadedLocalization(localization),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              home: const CustomerOrderInsuranceScreen(orderId: 100010),
            )));
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pumpAndSettle();
        final context =
            tester.element(find.byType(CustomerOrderInsuranceScreen));
        final taxLabel = getTranslated('tax_amount_due', context)!;
        expect(find.text(taxLabel), findsOneWidget);
        expect(find.text(getTranslated('second_invoice_heading', context)!),
            findsOneWidget);
        final supportLabel = getTranslated('contact_admin_support', context)!;
        await tester.scrollUntilVisible(find.text(supportLabel), 250,
            scrollable: find.byType(Scrollable).first);
        final support = tester.widget<OutlinedButton>(find
            .ancestor(
                of: find.text(supportLabel),
                matching: find.byType(OutlinedButton))
            .first);
        final foreground = support.style!.foregroundColor!.resolve({})!;
        final background = Theme.of(context).scaffoldBackgroundColor;
        final a = foreground.computeLuminance(),
            b = background.computeLuminance();
        expect(((a > b ? a : b) + .05) / ((a > b ? b : a) + .05),
            greaterThan(4.5));
        expect(tester.takeException(), isNull);

        repo.data = invoice(tax: 0);
        await controller.load(100010, silent: true);
        await tester.pumpAndSettle();
        expect(controller.envelope!.claim.taxAmount, 0);
        expect(controller.envelope!.claim.externalAmountDue, 50);
        await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
        await tester.pumpAndSettle();
        expect(find.text(taxLabel), findsNothing);

        repo.data = invoice(tax: 0, status: 'cancelled', payable: false);
        await controller.load(100010, silent: true);
        await tester.pumpAndSettle();
        expect(controller.envelope!.claim.canPay, isFalse);
        expect(find.text(getTranslated('insurance_status_cancelled', context)!),
            findsWidgets);
        expect(find.text(getTranslated('pay_from_insurance_wallet', context)!),
            findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
        splash.dispose();
      });
    }
  }
}
