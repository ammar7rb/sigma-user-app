import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/widgets/checkout_registration_form.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Cairo')..addFont(rootBundle.load('assets/fonts/brand/Cairo.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  testWidgets('minimal registration validates before submitting canonical phone', (tester) async {
    List<String>? submitted;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: CheckoutRegistrationForm(
      onSubmit: (name, phone, password) async => submitted = [name, phone, password], onLogin: () {},
    )))));
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(3));
    await tester.enterText(fields.at(0), 'عميل جديد');
    await tester.enterText(fields.at(1), '٠١٠١٢٣٤٥٦٧٨');
    await tester.enterText(fields.at(2), 'Test-pass-123');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(submitted, ['عميل جديد', '01012345678', 'Test-pass-123']);
  });

  testWidgets('RTL mobile preview', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(theme: ThemeData(fontFamily: 'Cairo', colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1a428a)), useMaterial3: true),
      home: Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBar(title: const Text('إكمال الشراء')),
        body: RepaintBoundary(key: const Key('preview'), child: Padding(padding: const EdgeInsets.all(24), child: CheckoutRegistrationForm(onSubmit: (_, __, ___) async {}, onLogin: () {}))),
      ))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/customer_checkout_registration.png'));
  });
}
