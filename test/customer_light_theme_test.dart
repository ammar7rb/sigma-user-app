import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('an existing dark preference cannot switch the customer app out of light mode', () async {
    SharedPreferences.setMockInitialValues({AppConstants.theme: true});
    final preferences = await SharedPreferences.getInstance();
    final controller = ThemeController(sharedPreferences: preferences);
    expect(controller.darkTheme, isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(preferences.getBool(AppConstants.theme), isFalse);
    controller.toggleTheme();
    expect(controller.darkTheme, isFalse);
    expect(preferences.getBool(AppConstants.theme), isFalse);
  });
}
