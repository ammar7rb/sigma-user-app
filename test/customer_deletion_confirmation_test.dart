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
    expect(find.byType(TextField), findsNothing);
    expect(find.text('نعم، حذف الحساب'), findsOneWidget);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(adapter.requests, isEmpty);
    expect(find.byType(DeleteAccountBottomSheet), findsNothing);
  });

  testWidgets(
      'confirm submits once without password or reason and shows server errors',
      (tester) async {
    await show(tester);
    await tester.tap(find.text('نعم، حذف الحساب'));
    await tester.tap(find.text('نعم، حذف الحساب'));
    await tester.pumpAndSettle();
    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.path,
        '/api/v1/customer/account-deletion/confirm');
    expect(adapter.requests.single.data, {'confirmation': true});
    expect(find.text('لا يمكن حذف الحساب أثناء وجود طلبات جارية.'),
        findsOneWidget);
    expect(find.byType(DeleteAccountBottomSheet), findsOneWidget);
  });
}
