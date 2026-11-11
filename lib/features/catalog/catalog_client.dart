import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart' as di;
import 'package:flutter_sixvalley_ecommerce/features/catalog/catalog_contract.dart';

class CatalogCall {
  final int? statusCode;
  final dynamic data;
  final String message;
  final bool unavailable;
  const CatalogCall({
    required this.message,
    this.statusCode,
    this.data,
    this.unavailable = false,
  });
  bool get ok => statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

class CatalogClient {
  final DioClient api;
  CatalogClient({DioClient? api}) : api = api ?? di.sl<DioClient>();

  Future<CatalogCall> getList(String path) => _send(() => api.get(path));

  Future<CatalogCall> post(String path, Map<String, dynamic> body) =>
      _send(() => api.post(path, data: body));

  static String requestKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Future<CatalogCall> _send(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      return CatalogCall(
        statusCode: response.statusCode,
        data: response.data,
        message: _message(response.data) ?? 'تم استلام الرد.',
      );
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      final missing = code == 404 || code == 405;
      return CatalogCall(
        statusCode: code,
        data: error.response?.data,
        unavailable: missing,
        message: missing
            ? CatalogContract.unavailable
            : (_message(error.response?.data) ??
                'تعذر الاتصال بالخادم. لم يُسجَّل أي طلب.'),
      );
    } catch (_) {
      return const CatalogCall(
        message: 'تعذر الاتصال بالخادم. لم يُسجَّل أي طلب.',
      );
    }
  }

  String? _message(dynamic data) {
    if (data is Map && data['message'] is String && data['message'] != '') {
      return data['message'] as String;
    }
    return null;
  }
}
