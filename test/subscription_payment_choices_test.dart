import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/widgets/subscription_payment_choices.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('Cairo')
          ..addFont(rootBundle.load('assets/fonts/brand/Cairo.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets(
        'Explicit payment choice without automatic wallet payment: $brightness',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final selections = <String>[];
      await tester.pumpWidget(MaterialApp(
          theme: brightness == Brightness.dark ? dark : light(),
          home: Scaffold(
              body: SubscriptionPaymentChoices(
                  amount: '5000.00 ج.م',
                  walletEnabled: true,
                  methods: const [
                    {
                      'id': 2,
                      'method_name': 'InstaPay',
                      'payment_channel': 'instapay'
                    },
                    {
                      'id': 1,
                      'method_name': 'محفظة كاش',
                      'payment_channel': 'wallet'
                    }
                  ],
                  onSelected: selections.add))));
      await tester.pumpAndSettle();
      await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
              'goldens/subscription_choice_${brightness.name}.png'));
      expect(selections, isEmpty);
      expect(find.textContaining('لا يكفي'), findsNothing);
      expect(find.text('اختر طريقة الدفع'), findsOneWidget);
      for (final id in ['2', '1', 'wallet']) {
        await tester.tap(find.byKey(ValueKey('payment-choice-$id')));
        expect(selections.last, id);
      }
      expect(selections, ['2', '1', 'wallet']);
      expect(tester.takeException(), isNull);
    });
  }
}
