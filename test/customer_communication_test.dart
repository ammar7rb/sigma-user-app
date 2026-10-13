import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/logging_interceptor.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/domain/models/profile_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/widgets/customer_communication_header.dart';

class FeedAdapter implements HttpClientAdapter {
  String reply = 'الرد الأول';
  bool failure = false;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (failure) {
      return ResponseBody.fromString('{}', 503, headers: {
        Headers.contentTypeHeader: ['application/json']
      });
    }
    final item = {
      'id': 1,
      'title': 'محادثة الدعم',
      'description': reply,
      'created_at': '2026-10-13T12:00:00Z',
      'target': null
    };
    final page = int.tryParse('${options.uri.queryParameters['page']}') ?? 1;
    final body = options.uri.queryParameters['type'] == null
        ? {
            'messages': {
              'total': 22,
              'items': [item]
            },
            'notifications': {
              'total': 1,
              'items': [item]
            }
          }
        : {
            'items': [
              if (page == 1) item else {...item, 'title': 'الصفحة الثانية'}
            ],
            'current_page': page,
            'last_page': 2,
            'total': 22
          };
    return ResponseBody.fromString(jsonEncode(body), 200, headers: {
      Headers.contentTypeHeader: ['application/json']
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FeedAdapter adapter;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    adapter = FeedAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    di.sl.registerSingleton<DioClient>(DioClient('https://example.test', dio,
        loggingInterceptor: LoggingInterceptor(),
        sharedPreferences: preferences));
  });
  tearDown(() async => di.sl.reset());

  test('customer display pads ID without changing request identity', () {
    final profile = ProfileModel()
      ..id = 12
      ..administrativeReference = 'C12';
    expect(profile.accountNumber, 'C000012');
    expect(profile.id, 12);
  });

  Widget host(Widget child) => MaterialApp(
      home: Directionality(
          textDirection: TextDirection.rtl, child: Scaffold(body: child)));

  testWidgets('header opens preview and view all opens the paginated page',
      (tester) async {
    await tester.pumpWidget(host(const CustomerCommunicationHeader()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('الرد الأول'), findsOneWidget);
    await tester.tap(find.text('عرض الكل'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('الصفحة الثانية'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('open feed refreshes automatically and can recover from failure',
      (tester) async {
    await tester
        .pumpWidget(host(const CustomerCommunicationPage(type: 'messages')));
    await tester.pumpAndSettle();
    adapter.reply = 'رد جديد من الإدارة';
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('رد جديد من الإدارة'), findsOneWidget);
    adapter.failure = true;
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    adapter.failure = false;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(find.text('تعذر تحميل التحديثات.'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
