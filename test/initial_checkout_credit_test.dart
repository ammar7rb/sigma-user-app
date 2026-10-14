import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/logging_interceptor.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/services/auth_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/domain/models/profile_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/widgets/credit_limit_strip.dart';

class AuthServiceFake extends Fake implements AuthServiceInterface {}

class InitialAuth extends AuthController {
  InitialAuth(this.loggedIn) : super(authServiceInterface: AuthServiceFake());
  final bool loggedIn;
  @override
  bool isLoggedIn() => loggedIn;
}

class InitialProfile extends ProfileController {
  InitialProfile() : super(profileServiceInterface: null);
  @override
  ProfileModel get userInfoModel => ProfileModel.fromJson({
        'purchase_eligibility': {'show_credit_indicator': false}
      });
}

class InitialAdapter implements HttpClientAdapter {
  bool canCheckout = true;
  int requests = 0;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests++;
    return ResponseBody.fromString(
        jsonEncode({
          'limit': {
            'unlimited_initial_checkout': true,
            'show_credit_indicator': false
          },
          'eligibility': {
            'can_checkout': canCheckout,
            'message': 'الطلب بانتظار اختيار باقة'
          }
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late InitialAdapter adapter;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    adapter = InitialAdapter();
    di.sl.registerSingleton<DioClient>(DioClient(
        'https://example.test', Dio()..httpClientAdapter = adapter,
        loggingInterceptor: LoggingInterceptor(),
        sharedPreferences: await SharedPreferences.getInstance()));
  });
  tearDown(() async => di.sl.reset());
  Future<void> mount(WidgetTester tester, bool loggedIn, Widget child) async {
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<AuthController>(
          create: (_) => InitialAuth(loggedIn)),
      ChangeNotifierProvider<ProfileController>(
          create: (_) => InitialProfile()),
    ], child: MaterialApp(home: Scaffold(body: child))));
    await tester.pumpAndSettle();
  }

  for (final loggedIn in [false, true]) {
    testWidgets('initial checkout has no indicator or amount cap: $loggedIn',
        (tester) async {
      bool? accepted;
      await mount(
          tester,
          loggedIn,
          Builder(
              builder: (context) => Column(children: [
                    const CreditLimitStrip(cart: true),
                    TextButton(
                        onPressed: () async => accepted =
                            await validateCustomerCartLimit(context, 100000),
                        child: const Text('متابعة')),
                  ])));
      expect(find.text('الحد الائتماني'), findsNothing);
      expect(find.text('مؤشر الأئتمان'), findsNothing);
      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      expect(accepted, true);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
      'paid initial order shows requirements instead of a credit shortage',
      (tester) async {
    adapter.canCheckout = false;
    await mount(
        tester,
        true,
        Builder(
            builder: (context) => TextButton(
                onPressed: () => validateCustomerCartLimit(context, 100000),
                child: const Text('متابعة'))));
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(find.text('متطلبات الشراء'), findsOneWidget);
    expect(find.text('الطلب بانتظار اختيار باقة'), findsOneWidget);
    expect(find.text('الحد الائتماني غير كافٍ'), findsNothing);
  });
}
