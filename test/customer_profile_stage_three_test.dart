import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/logging_interceptor.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/widgets/customer_contact_phones.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/domain/models/address_model.dart';

class ContactAdapter implements HttpClientAdapter {
  List<String> saved = ['01212345678'];
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.method == 'PUT') {
      final data = options.data is String
          ? jsonDecode(options.data as String)
          : options.data;
      saved = List<String>.from(data['phones']);
    }
    return ResponseBody.fromString(jsonEncode({'phones': saved}), 200,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late ContactAdapter adapter;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    adapter = ContactAdapter();
    di.sl.registerSingleton<DioClient>(DioClient(
        'https://example.test', Dio()..httpClientAdapter = adapter,
        loggingInterceptor: LoggingInterceptor(),
        sharedPreferences: await SharedPreferences.getInstance()));
  });
  tearDown(() async => di.sl.reset());
  test('address details retain district, area, building and unit independently',
      () {
    final input = {
      'district': 'حي',
      'area': 'منطقة أخرى',
      'building_number': '12',
      'floor': '3',
      'unit_number': '7',
      'company_details': 'مكتب سيجما'
    };
    final address = AddressModel.fromJson(input);
    final output = address.toJson();
    for (final entry in input.entries) {
      expect(output[entry.key], entry.value);
    }
    expect(address.district, isNot(address.area));
  });
  testWidgets(
      'contact numbers can be added saved and removed without affecting login',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(child: CustomerContactPhones()))));
    await tester.pumpAndSettle();
    expect(find.text('01212345678'), findsOneWidget);
    await tester.tap(find.text('إضافة رقم'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, '01512345678');
    await tester.tap(find.text('حفظ أرقام التواصل'));
    await tester.pumpAndSettle();
    expect(adapter.saved, ['01212345678', '01512345678']);
    expect(find.text('تم حفظ أرقام التواصل.'), findsOneWidget);
    await tester.tap(find.byTooltip('إزالة الرقم').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ أرقام التواصل'));
    await tester.pumpAndSettle();
    expect(adapter.saved, ['01512345678']);
    expect(tester.takeException(), isNull);
  });
  testWidgets('invalid and duplicate numbers never reach the save endpoint',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(child: CustomerContactPhones()))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة رقم'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, '01212345678');
    await tester.tap(find.text('حفظ أرقام التواصل'));
    await tester.pumpAndSettle();
    expect(adapter.saved, ['01212345678']);
    expect(
        find.text('أدخل أرقام موبايل مصرية صحيحة وغير مكررة.'), findsOneWidget);
  });
}
