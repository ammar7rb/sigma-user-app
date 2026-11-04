import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/logging_interceptor.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/widgets/account_deletion_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';

class DeletionAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    if (options.path.endsWith('/begin')) {
      return ResponseBody.fromString(
          '{"stage":2,"flow_token":"test-flow"}', 200,
          headers: {
            Headers.contentTypeHeader: ['application/json']
          });
    }
    if (options.path.endsWith('/reason')) {
      return ResponseBody.fromString('{"stage":3}', 200, headers: {
        Headers.contentTypeHeader: ['application/json']
      });
    }
    return ResponseBody.fromString(
        '{"errors":{"deletion":["لا يمكن حذف الحساب أثناء وجود طلبات جارية."]}}',
        422,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late DeletionAdapter adapter;
  late LocalizationController localization;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    adapter = DeletionAdapter();
    final client = DioClient(
        'https://example.test', Dio()..httpClientAdapter = adapter,
        loggingInterceptor: LoggingInterceptor(),
        sharedPreferences: preferences);
    di.sl.registerSingleton<DioClient>(client);
    localization = LocalizationController(
        sharedPreferences: preferences, dioClient: client);
  });
  tearDown(() async {
    localization.dispose();
    await di.sl.reset();
  });

  Future<void> show(WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: localization,
        child: MaterialApp(
            home: Builder(
                builder: (context) => Scaffold(
                    body: TextButton(
                        onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => const DeleteAccountBottomSheet(
                                customerId: '123')),
                        child: const Text('Open')))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('cancel closes confirmation without making a deletion request',
      (tester) async {
    await show(tester);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(adapter.requests, isEmpty);
    expect(find.byType(DeleteAccountBottomSheet), findsNothing);
  });

  testWidgets(
      'password reason and reconfirmation are required and server rejection preserves the account',
      (tester) async {
    await show(tester);
    await tester.enterText(find.byType(TextField), 'abc123');
    await tester.tap(find.text('متابعة'));
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(adapter.requests, hasLength(1));
    await tester.enterText(find.byType(TextField), 'Account deletion test');
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(adapter.requests, hasLength(2));
    await tester.enterText(find.byType(TextField), 'abc123');
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'حذف الحساب'));
    await tester.tap(find.widgetWithText(FilledButton, 'حذف الحساب'));
    await tester.pumpAndSettle();
    expect(adapter.requests, hasLength(3));
    expect(adapter.requests.map((request) => request.path), [
      '/api/v1/customer/account-deletion/begin',
      '/api/v1/customer/account-deletion/reason',
      '/api/v1/customer/account-deletion/finish',
    ]);
    expect(adapter.requests.first.data, {'password': 'abc123'});
    expect(adapter.requests[1].data,
        {'flow_token': 'test-flow', 'reason': 'Account deletion test'});
    expect(adapter.requests.last.data, {
      'flow_token': 'test-flow',
      'password': 'abc123',
      'confirmation': true
    });
    expect(find.text('لا يمكن حذف الحساب أثناء وجود طلبات جارية.'),
        findsOneWidget);
    expect(find.byType(DeleteAccountBottomSheet), findsOneWidget);
  });
}
