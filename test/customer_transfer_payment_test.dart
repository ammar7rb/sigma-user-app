import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/screens/monthly_subscription_screen.dart';
import 'package:flutter_sixvalley_ecommerce/theme/light_theme.dart';
import 'package:flutter_sixvalley_ecommerce/theme/dark_theme.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('Cairo')
          ..addFont(rootBundle.load('assets/fonts/brand/Cairo.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  for (final channel in ['instapay', 'wallet']) {
    for (final darkMode in [false, true]) {
      testWidgets(
          '$channel subscription locks quoted amount and only copies recipient number ${darkMode ? 'dark' : 'light'}',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1100));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        String? copied;
        tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = call.arguments['text'];
          }
          return null;
        });
        addTearDown(() => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null));
        await tester.pumpWidget(MaterialApp(
            theme: darkMode ? dark : light(),
            home: Directionality(
                textDirection: TextDirection.rtl,
                child: SubscriptionTransferScreen(
                  payment: const {
                    'id': 1,
                    'quoted_amount': '5000.000',
                    'currency_code': 'EGP'
                  },
                  method: {
                    'id': 1,
                    'payment_channel': channel,
                    'method_fields': [
                      {
                        'input_name': 'رقم المحفظة',
                        'input_data': '01012345678'
                      },
                      {
                        'input_name': 'اسم صاحب الحساب',
                        'input_data': 'حساب تجريبي'
                      }
                    ]
                  },
                ))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
        expect(find.text('مرجع التحويل'), findsNothing);
        final amount =
            tester.widgetList<TextFormField>(find.byType(TextFormField)).first;
        expect(
            tester.widgetList<TextField>(find.byType(TextField)).first.readOnly,
            isTrue);
        expect(amount.initialValue, '5000.00');
        expect(find.text('الرقم الذي حولت منه'), findsOneWidget);
        expect(
            find.text(channel == 'instapay'
                ? 'اسم الحساب الخاص بك'
                : 'اسم المحفظة الخاصة بك'),
            findsOneWidget);
        await expectLater(
            find.byType(Scaffold),
            matchesGoldenFile(
                'goldens/transfer_${channel}_${darkMode ? 'dark' : 'light'}.png'));
        await tester.tap(find.byIcon(Icons.copy_rounded));
        await tester.pumpAndSettle();
        expect(copied, '01012345678');
      });
    }
  }
}
