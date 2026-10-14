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
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/domain/services/profile_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/subscription/screens/monthly_subscription_screen.dart';

class ProfileServiceFake extends Fake implements ProfileServiceInterface {}

class ProfileForWalletTest extends ProfileController {
  ProfileForWalletTest() : super(profileServiceInterface: ProfileServiceFake());
  @override
  Future<String> getUserInfo(BuildContext context) async => 'success';
}

class WalletAdapter implements HttpClientAdapter {
  final bodies = <Map<String, dynamic>>[];
  bool completed = false;
  bool loseFirstResponse = false;
  bool insufficient = false;
  Map<String, dynamic> get payload => {
        'wallet_policy_version': 2,
        'purchase_wallet_enabled': true,
        'purchase_balance': completed ? 875 : 900,
        'subscription': {
          'active': true,
          'status': 'active',
          'package_name': 'Silver',
          'package_id': 1,
          'remaining_days': 10,
          'starts_at': '2026-10-01T10:00:00+03:00',
          'expires_at': '2026-10-31T09:00:00+02:00',
          'limit_revision': completed ? 1 : 0,
          'open_payment': null,
          'allowance': {
            'subscription_id': 1,
            'base_limit': 3000,
            'package_price': 100,
            'granted_limit': completed ? 6000 : 3000,
            'committed_limit': 3000,
            'available_limit': completed ? 3000 : 0
          }
        },
        'packages': [
          for (final item in [
            [1, 'Silver', 100, 3000],
            [2, 'Gold', 200, 5000],
            [3, 'Diamond', 300, 10000]
          ])
            {
              'id': item[0],
              'name': item[1],
              'package_price': item[2],
              'purchase_limit': item[3],
              'renewal_price': 25,
              'quote_token': 'a' * 64
            },
        ],
        'increase_offers': [],
        'offline_methods': [],
        'payments': {'data': []},
      };
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.method == 'POST') {
      expect(options.path, '/api/v1/customer/subscription/transact');
      final body =
          options.data is String ? jsonDecode(options.data) : options.data;
      bodies.add(Map<String, dynamic>.from(body));
      if (insufficient) {
        return ResponseBody.fromString(
            jsonEncode({
              'errors': {
                'subscription': ['رصيد محفظة المنصة غير كافٍ. اشحن المحفظة.']
              }
            }),
            422,
            headers: {
              Headers.contentTypeHeader: ['application/json']
            });
      }
      completed = true;
      if (loseFirstResponse && bodies.length == 1) {
        throw DioException(
            requestOptions: options, type: DioExceptionType.receiveTimeout);
      }
      return ResponseBody.fromString('{"payment":{"status":"approved"}}', 200,
          headers: {
            Headers.contentTypeHeader: ['application/json']
          });
    }
    return ResponseBody.fromString(jsonEncode(payload), 200, headers: {
      Headers.contentTypeHeader: ['application/json']
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late WalletAdapter adapter;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    adapter = WalletAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    di.sl.registerSingleton<DioClient>(DioClient('https://example.test', dio,
        loggingInterceptor: LoggingInterceptor(),
        sharedPreferences: await SharedPreferences.getInstance()));
  });
  tearDown(() async => di.sl.reset());
  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider<ProfileController>(
        create: (_) => ProfileForWalletTest(),
        child: const MaterialApp(
            home: Directionality(
                textDirection: TextDirection.rtl,
                child: MonthlySubscriptionScreen()))));
    await tester.pumpAndSettle();
  }

  Future<void> renew(WidgetTester tester) async {
    final button = find.widgetWithText(OutlinedButton, 'تجديد الحد بـ25 ج.م');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    for (var scroll = 0;
        scroll < 10 && tester.getCenter(button).dy > 540;
        scroll++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -350));
      await tester.pumpAndSettle();
    }
    await tester.tap(button);
    await tester.pumpAndSettle();
    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'renewal sends one immediate wallet operation and preserves original expiry',
      (tester) async {
    await mount(tester);
    await renew(tester);
    expect(adapter.bodies, hasLength(1));
    expect(adapter.bodies.single['operation'], 'renew_limit');
    expect(adapter.bodies.single['expected_amount'], '25.000');
    expect(adapter.bodies.single['expected_subscription_id'], 1);
    expect(adapter.bodies.single['expected_revision'], 0);
    expect(find.textContaining('تنتهي 2026/10/31'), findsOneWidget);
    expect(find.textContaining('إنستا'), findsNothing);
    expect(find.textContaining('طريقة الدفع'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'lost response retries the same key and original terms after refreshed revision',
      (tester) async {
    adapter.loseFirstResponse = true;
    await mount(tester);
    await renew(tester);
    final retry = find.text('إعادة إرسال العملية نفسها');
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(adapter.bodies, hasLength(2));
    expect(adapter.bodies[1], equals(adapter.bodies[0]));
    expect(adapter.bodies[1]['expected_revision'], 0);
    expect(adapter.completed, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'insufficient funds explains platform wallet funding without an external payment choice',
      (tester) async {
    adapter.insufficient = true;
    await mount(tester);
    await renew(tester);
    expect(adapter.completed, isFalse);
    expect(find.textContaining('رصيد محفظة المنصة غير كاف'), findsOneWidget);
    expect(find.text('شحن محفظة المنصة'), findsOneWidget);
    expect(find.textContaining('إنستا'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
