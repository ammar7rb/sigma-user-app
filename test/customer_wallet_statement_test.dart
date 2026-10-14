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
import 'package:flutter_sixvalley_ecommerce/features/wallet/screens/customer_wallet_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';

class WalletSplash extends SplashController {
  WalletSplash() : super(splashServiceInterface: null);
  @override
  ConfigModel get configModel => ConfigModel(currencyModel: 'single_currency');
}

class StatementAdapter implements HttpClientAdapter {
  final queries = <Map<String, dynamic>>[];
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
      Future<void>? cancelFuture) async {
    queries.add(Map.from(options.queryParameters));
    return ResponseBody.fromString(
        jsonEncode({
          'purchase_balance': 1200,
          'purchase_enabled': true,
          'offline_methods': [],
          'digital_methods': [],
          'subscription': {'active': false},
          'deposits': {'data': [], 'next_page_url': null},
          'purchase_entries': {
            'data': [
              {
                'entry_label': 'تجديد الحد الائتماني',
                'package_name': 'Silver',
                'credit': 0,
                'credited_amount': 0,
                'debit': 100,
                'balance': 1200,
                'created_at': '2026-10-14',
                'payment_method': 'محفظة المنصة',
                'reference_label': 'PKG-5',
                'customer_note': 'تمت المطابقة',
                'orders': [
                  {'order_id': 12, 'invoice_number': 'INV-12'}
                ]
              }
            ],
            'next_page_url': 'page2'
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
  late StatementAdapter adapter;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    adapter = StatementAdapter();
    di.sl.registerSingleton<DioClient>(DioClient(
        'https://example.test', Dio()..httpClientAdapter = adapter,
        loggingInterceptor: LoggingInterceptor(),
        sharedPreferences: await SharedPreferences.getInstance()));
  });
  tearDown(() async => di.sl.reset());
  testWidgets(
      'statement renders operation method reference invoice and admin note, pages independently',
      (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider<SplashController>(
        create: (_) => WalletSplash(),
        child: const MaterialApp(home: CustomerWalletScreen())));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('تجديد الحد الائتماني · Silver'), 300);
    await tester.pumpAndSettle();
    expect(find.text('تجديد الحد الائتماني · Silver'), findsOneWidget);
    expect(find.textContaining('PKG-5'), findsOneWidget);
    expect(find.textContaining('INV-12'), findsOneWidget);
    expect(find.textContaining('ملاحظة الإدارة: تمت المطابقة'), findsOneWidget);
    await tester.ensureVisible(find.text('wallet_next').last);
    await tester.tap(find.text('wallet_next').last);
    await tester.pumpAndSettle();
    expect(adapter.queries.last['entries_page'], 2);
    expect(adapter.queries.last['deposits_page'], 1);
  });
}
