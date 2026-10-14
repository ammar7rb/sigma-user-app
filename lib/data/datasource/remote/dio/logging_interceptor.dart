import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:provider/provider.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (kDebugMode) {
      print(
          "<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}");
    }

    String responseAsString = response.data.toString();

    if (responseAsString.length > maxCharactersPerLine) {
      int iterations = (responseAsString.length / maxCharactersPerLine).floor();
      for (int i = 0; i <= iterations; i++) {
        int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
        if (endingIndex > responseAsString.length) {
          endingIndex = responseAsString.length;
        }
        if (kDebugMode) {
          // print(responseAsString.substring(i * maxCharactersPerLine, endingIndex));
        }
      }
    } else {
      if (kDebugMode) {
        //  print(response.data);
      }
    }

    if (kDebugMode) {
      print("<-- END HTTP");
    }

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.data is Map &&
        err.response?.data['code'] == 'password_change_required' &&
        Get.context != null) {
      final auth = Get.context!.read<AuthController>();
      auth.setPasswordChangeRequired(true);
      RouterHelper.goRoutes.refresh();
    }
    if (kDebugMode) {
      print(
          "ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");
    }
    return super.onError(err, handler);
  }
}
