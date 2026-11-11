import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/widgets/monthly_package_choices.dart';

void main() {
  testWidgets(
      'lower packages can be selected and credit increase controls are absent',
      (tester) async {
    int? selected;
    final data = <String, dynamic>{
      'subscription': {
        'active': true,
        'package_id': 2,
        'package_name': 'Gold',
        'allowance': {'base_limit': 5000, 'package_price': 190}
      },
      'packages': [
        {
          'id': 1,
          'name': 'Silver',
          'package_price': 100,
          'purchase_limit': 3000,
          'renewal_price': 10
        },
        {
          'id': 2,
          'name': 'Gold',
          'package_price': 200,
          'purchase_limit': 5000,
          'renewal_price': 20
        },
        {
          'id': 3,
          'name': 'Diamond',
          'package_price': 300,
          'purchase_limit': 10000,
          'renewal_price': 30
        },
      ],
      'increase_offers': [
        {'id': 4, 'price': 10, 'allowance': 100}
      ]
    };
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: MonthlyPackageChoices(
                    data: data,
                    busy: false,
                    onBuy: (id, _) => selected = id,
                    onRenew: (_) {})))));
    expect(find.text('زيادة الحد الائتماني'), findsNothing);
    expect(find.text('باقة غير متاحة للترقية'), findsNothing);
    expect(find.text('تجديد'), findsOneWidget);
    expect(find.text('200 ج.م'), findsOneWidget);
    expect(find.text('190 ج.م'), findsNothing);
    final subscribe = find.widgetWithText(FilledButton, 'اشترك الآن');
    await tester.ensureVisible(subscribe.first);
    await tester.tap(subscribe.first);
    expect(selected, 1);
  });
}
