
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController with ChangeNotifier {
  final SharedPreferences? sharedPreferences;
  ThemeController({required this.sharedPreferences}) {
    _loadCurrentTheme();
  }

  bool get darkTheme => false;

  void toggleTheme() {
    // SIGMA customer accounts always use the light appearance.
    sharedPreferences?.setBool(AppConstants.theme, false);
  }

  void _loadCurrentTheme() async {
    await sharedPreferences?.setBool(AppConstants.theme, false);
  }

  Color? selectedPrimaryColor;
  Color? selectedSecondaryColor;



  void setThemeColor({Color? primaryColor, Color? secondaryColor}) {
    selectedPrimaryColor = primaryColor;
    selectedPrimaryColor = secondaryColor;

    notifyListeners();
  }



}
