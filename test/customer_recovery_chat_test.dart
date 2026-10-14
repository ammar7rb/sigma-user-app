import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/logging_interceptor.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/screens/customer_password_recovery_screen.dart';

class RecoveryAdapter implements HttpClientAdapter {
  bool created = false;
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    if (options.path.endsWith('/request')) created = true;
    final body = options.path.endsWith('/conversation')
        ? {
            'messages': created
                ? [
                    {
                      'id': 1,
                      'sender': 'admin',
                      'body': 'راجع بيانات حسابك مع الإدارة'
                    }
                  ]
                : []
          }
        : {'message': 'تم استلام طلبك'};
    return ResponseBody.fromString(jsonEncode(body),
        !created && options.path.endsWith('/conversation') ? 404 : 200,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late RecoveryAdapter adapter;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    adapter = RecoveryAdapter();
    di.sl.registerSingleton<DioClient>(DioClient(
        'https://example.test', Dio()..httpClientAdapter = adapter,
        loggingInterceptor: LoggingInterceptor(),
        sharedPreferences: await SharedPreferences.getInstance()));
  });
  tearDown(() async => di.sl.reset());
  testWidgets(
      'recovery request and chat keep the same private token after reopening',
      (tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: CustomerPasswordRecoveryScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '01012345678');
    await tester.tap(find.text('إرسال طلب للإدارة'));
    await tester.pumpAndSettle();
    expect(find.text('محادثة الدعم الفني'), findsOneWidget);
    expect(find.text('راجع بيانات حسابك مع الإدارة'), findsOneWidget);
    final request =
        adapter.requests.firstWhere((r) => r.path.endsWith('/request'));
    final token = request.headers['X-Support-Token'];
    expect(token, matches(RegExp('^[a-f0-9]{64}\$')));
    await tester.pumpWidget(const SizedBox());
    await tester
        .pumpWidget(const MaterialApp(home: CustomerPasswordRecoveryScreen()));
    await tester.pumpAndSettle();
    expect(adapter.requests.last.headers['X-Support-Token'], token);
    expect(find.text('راجع بيانات حسابك مع الإدارة'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('required change validates all credentials before submission',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: CustomerPasswordRecoveryScreen(changeRequired: true)));
    await tester.tap(find.text('حفظ كلمة المرور الجديدة'));
    await tester.pumpAndSettle();
    expect(find.text('أدخل الكلمة المؤقتة'), findsOneWidget);
    expect(adapter.requests, isEmpty);
    expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, false);
  });
}
