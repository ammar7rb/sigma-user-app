import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/widgets/transfer_recipient_card.dart';
import 'package:flutter_sixvalley_ecommerce/localization/app_localization.dart';

void main() {
  testWidgets('recipient details render in Arabic, English, light and dark',
      (tester) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      for (final dark in const [false, true]) {
        await tester.pumpWidget(MaterialApp(
          key: ValueKey('${locale.languageCode}-$dark'),
          locale: locale,
          theme: dark ? ThemeData.dark() : ThemeData.light(),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(
            body: SingleChildScrollView(
              child: TransferRecipientCard(
                channel: 'instapay',
                details: [
                  TransferRecipientDetail('Recipient', 'instapay-recipient'),
                ],
              ),
            ),
          ),
        ));
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.byType(TransferRecipientCard), findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is SelectableText &&
                widget.data == 'instapay-recipient'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is SelectableText && widget.data == 'wallet-recipient'),
            findsNothing);
        expect(
            find.textContaining(
                locale.languageCode == 'ar' ? 'لقطة شاشة' : 'screenshot'),
            findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(MaterialApp(
          locale: locale,
          theme: dark ? ThemeData.dark() : ThemeData.light(),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(
            body: SingleChildScrollView(
              child: TransferRecipientCard(
                channel: 'wallet',
                details: [
                  TransferRecipientDetail('Recipient', 'wallet-recipient'),
                ],
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(
            find.byWidgetPredicate((widget) =>
                widget is SelectableText && widget.data == 'wallet-recipient'),
            findsOneWidget);
        expect(find.text('instapay-recipient'), findsNothing);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
