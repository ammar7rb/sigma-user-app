import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/services/auth_service.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart' as app;
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('both splash guest creation branches await before dashboard navigation', () {
    final source = File('lib/features/splash/screens/splash_screen.dart')
        .readAsStringSync();
    final guestCalls = RegExp(r'\.getGuestIdUrl\(\)').allMatches(source);
    expect(guestCalls, hasLength(2));
    final awaitedRoutes = RegExp(
      r'await Provider\.of<AuthController>\(\s*Get\.context!,\s*'
      r'listen: false,\s*\)\.getGuestIdUrl\(\);\s*'
      r'RouterHelper\.getDashboardRoute\(\s*action: RouteAction\.(\w+),',
    ).allMatches(source);
    expect(awaitedRoutes.map((match) => match.group(1)),
        ['pushReplacement', 'pushNamedAndRemoveUntil']);
  });

  for (final loggedIn in [false, true]) {
    for (final structuredError in [false, true]) {
      testWidgets(
          '401 preserves guest credentials only when logged out '
          '(loggedIn=$loggedIn, structuredError=$structuredError)',
          (tester) async {
        SharedPreferences.setMockInitialValues({
          AppConstants.guestId: '42',
          AppConstants.guestOrderToken: '42.private-signature',
          if (loggedIn) AppConstants.userLoginToken: 'customer-session',
        });
        final preferences = await SharedPreferences.getInstance();
        final repository = AuthRepository(
            dioClient: null, sharedPreferences: preferences);
        final auth = AuthController(
            authServiceInterface: AuthService(authRepoInterface: repository));
        addTearDown(auth.dispose);
        await tester.pumpWidget(ChangeNotifierProvider<AuthController>.value(
          value: auth,
          child: MaterialApp(
            navigatorKey: app.navigatorKey,
            home: const SizedBox(),
          ),
        ));
        final options = RequestOptions(path: '/guest-request');
        final error = DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: 401,
            data: structuredError
                ? {
                    'errors': [
                      {'code': 'unauthorized', 'message': 'Unauthorized'}
                    ]
                  }
                : {'message': 'Unauthorized'},
          ),
        );

        expect(ApiErrorHandler.getMessage(error), 'Unauthorized');
        await tester.pumpAndSettle();

        expect(auth.isLoggedIn(), isFalse);
        expect(preferences.getString(AppConstants.guestId),
            loggedIn ? isNull : '42');
        expect(preferences.getString(AppConstants.guestOrderToken),
            loggedIn ? isNull : '42.private-signature');
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
