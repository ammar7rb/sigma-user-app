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

  static List<Map<String, dynamic>> pageItems(dynamic data) {
    if (data is! Map || data['data'] is! List) return const [];
    return (data['data'] as List)
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
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
    if (data is! Map) return null;
    final errors = data['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return '${value.first}';
        if (value is String && value.isNotEmpty) return value;
      }
    }
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    return null;
  }
}
