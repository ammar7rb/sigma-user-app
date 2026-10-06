import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/domain/models/profile_model.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('new session starts in Arabic despite a saved English preference', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.languageCode: 'en', AppConstants.countryCode: 'US',
    });
    final preferences = await SharedPreferences.getInstance();
    final controller = LocalizationController(sharedPreferences: preferences, dioClient: null);
    expect(controller.locale.languageCode, 'ar');
    expect(controller.isLtr, isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(preferences.getString(AppConstants.languageCode), 'ar');
  });
  test('profile uses the administrative customer number returned by the API', () {
    expect(ProfileModel.fromJson({'id': 42, 'administrative_reference': 'C42'}).accountNumber, 'C42');
    expect(ProfileModel.fromJson({'id': 42}).accountNumber, 'C42');
    expect(ProfileModel().accountNumber, isNull);
  });
}
