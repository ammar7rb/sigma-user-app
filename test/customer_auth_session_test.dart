import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('only a saved usable login token grants customer navigation', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = AuthRepository(dioClient: null, sharedPreferences: preferences);
    expect(repository.isLoggedIn(), isFalse);
    for (final token in ['', '   ', 'null']) {
      await preferences.setString(AppConstants.userLoginToken, token);
      expect(repository.isLoggedIn(), isFalse);
    }
    await preferences.setString(AppConstants.userLoginToken, 'test-auth-session');
    expect(repository.isLoggedIn(), isTrue);
    await preferences.remove(AppConstants.userLoginToken);
    expect(repository.isLoggedIn(), isFalse);
  });
}
