import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationController extends ChangeNotifier {
  final SharedPreferences? sharedPreferences;
  final DioClient? dioClient;

  LocalizationController({required this.sharedPreferences, required this.dioClient}) {
    _loadCurrentLanguage();
  }

  Locale _locale = const Locale('ar', 'SA');
  bool _isLtr = false;
  int? _languageIndex;

  Locale get locale => _locale;
  bool get isLtr => _isLtr;
  int? get languageIndex => _languageIndex;

  void setLanguage(Locale locale) {
    _locale = locale;
    _isLtr = _locale.languageCode != 'ar';
    dioClient?.updateHeader(null, locale.languageCode);
    Provider.of<AuthController>(Get.context!, listen: false).setCurrentLanguage(locale.languageCode);
    for(int index=0; index<AppConstants.languages.length; index++) {
      if(AppConstants.languages[index].languageCode == locale.languageCode) {
        _languageIndex = index;
        break;
      }
    }
    _saveLanguage(_locale);
    notifyListeners();
  }

  Future<void> _loadCurrentLanguage() async {
    // Each new app session starts in Arabic; manual switching remains available.
    _locale = const Locale('ar', 'SA');
    dioClient?.updateHeader(null, 'ar');
    await _saveLanguage(_locale);
    _isLtr = _locale.languageCode != 'ar';
    for(int index=0; index<AppConstants.languages.length; index++) {
      if(AppConstants.languages[index].languageCode == locale.languageCode) {
        _languageIndex = index;
        break;
      }
    }
    notifyListeners();
  }

  Future<void> _saveLanguage(Locale locale) async {
    await sharedPreferences!.setString(AppConstants.languageCode, locale.languageCode);
    await sharedPreferences!.setString(AppConstants.countryCode, locale.countryCode!);
  }


  String? getCurrentLanguage() {
    return sharedPreferences!.getString(AppConstants.countryCode) ?? "SA";
  }
}