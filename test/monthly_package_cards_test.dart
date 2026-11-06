import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/widgets/monthly_package_choices.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Cairo')
          ..addFont(rootBundle.load('assets/fonts/brand/Cairo.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  testWidgets(
      'active package exposes renewal and upgrade without credit increase',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    int? chosenPackage;
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
            fontFamily: 'Cairo',
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF1A428A))),
        home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
                body: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: MonthlyPackageChoices(
                            busy: false,
                            data: const {
                              'subscription': {
                                'active': true,
                                'package_id': 1,
                                'allowance': {
                                  'base_limit': 3000,
                                  'package_price': 100
                                }
                              },
                              'packages': [
                                {
                                  'id': 1,
                                  'name': 'Silver',
                                  'package_price': 100,
                                  'purchase_limit': 3000
                                },
                                {
                                  'id': 2,
                                  'name': 'Gold',
                                  'package_price': 200,
                                  'purchase_limit': 5000
                                }
                              ],
                              'increase_offers': [
                                {
                                  'id': 1,
                                  'name': 'زيادة الحد',
                                  'price': 50,
                                  'allowance': 1000
                                }
                              ]
                            },
                            onBuy: (package, offer) =>
                                chosenPackage = package)))))));
    expect(find.text('الباقة الحالية'), findsOneWidget);
    expect(find.text('تجديد الباقة'), findsOneWidget);
    expect(find.text('زيادة الحد من رصيد المحفظة'), findsNothing);
    expect(find.text('الاشتراك في الباقة'), findsNothing);
    expect(find.textContaining('حد الشراء'), findsNothing);
    expect(find.textContaining('المدة 30'), findsNothing);
    await tester.ensureVisible(find.text('ترقية الباقة'));
    await tester.tap(find.text('ترقية الباقة'));
    expect(chosenPackage, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    await expectLater(find.byType(Scaffold),
        matchesGoldenFile('goldens/customer_monthly_packages.png'));
  });
}
