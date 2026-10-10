import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/widgets/monthly_subscription_summary.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/domain/models/account_overview_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Cairo')..addFont(rootBundle.load('assets/fonts/brand/Cairo.ttf'))).load();
    await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  test('profile parses authoritative subscription state', () {
    final overview = AccountOverviewModel.fromJson({'subscription':{'active':true,'remaining_days':12}});
    expect(overview.subscriptionActive, isTrue);
    expect(overview.subscriptionRemainingDays,12);
    expect(overview.insuranceEnabled,isFalse);
  });

  testWidgets('pending payment never displays active status or pay again', (tester) async {
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:MonthlySubscriptionSummary(
      subscription: const {'active':false,'status':'inactive','price':100,'currency_code':'EGP','open_payment':{'status':'pending_review'}}, onCheckout:(){}))));
    expect(find.textContaining('الدفع قيد المراجعة'),findsOneWidget);
    expect(find.text('اشتراك فعال'),findsNothing);
    expect(find.byType(FilledButton),findsNothing);
  });

  testWidgets('inactive subscription checkout action and loading', (tester) async {
    bool tapped=false;
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:MonthlySubscriptionSummary(
      subscription: const {'active':false,'status':'inactive','price':100,'currency_code':'EGP'},onCheckout:()=>tapped=true))));
    await tester.tap(find.byType(FilledButton)); expect(tapped,isTrue);
  });

  testWidgets('RTL active subscription preview has no overflow', (tester) async {
    tester.view.physicalSize=const Size(430,932);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(theme:ThemeData(fontFamily:'Cairo',useMaterial3:true,
      colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff1a428a))),
      home:Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('الاشتراك الشهري')),
        body:const Padding(padding:EdgeInsets.all(20),child:MonthlySubscriptionSummary(subscription:{
          'active':true,'status':'active','remaining_days':24,'price':'100.000','currency_code':'EGP','expires_at':'2026-11-03T10:00:00+02:00'
        }))))));
    await tester.pumpAndSettle();expect(tester.takeException(),isNull);
    await expectLater(find.byType(Scaffold),matchesGoldenFile('goldens/customer_monthly_subscription.png'));
  });
}
