import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the session token in platform secure storage after one-time migration.
class AuthTokenStore {
  static const _storage = FlutterSecureStorage();
  static String? token;

  static Future<void> initialize(SharedPreferences preferences) async {
    token = await _storage.read(key: AppConstants.userLoginToken);
    final legacy = preferences.getString(AppConstants.userLoginToken);
    if ((token == null || token!.isEmpty) && legacy != null && legacy.isNotEmpty && legacy != 'null') {
      await _storage.write(key: AppConstants.userLoginToken, value: legacy);
      token = legacy;
    }
    if (legacy != null) {
      await preferences.remove(AppConstants.userLoginToken);
    }
    await preferences.remove(AppConstants.userPassword);
    await preferences.remove(AppConstants.userEmail);
    final remembered = preferences.getString(AppConstants.userLogData);
    if (remembered != null) {
      try {
        final data = jsonDecode(remembered) as Map<String, dynamic>;
        if (data.containsKey('password')) {
          data.remove('password');
          await preferences.setString(AppConstants.userLogData, jsonEncode(data));
        }
      } catch (_) {
        await preferences.remove(AppConstants.userLogData);
      }
    }
  }

  static Future<void> save(String value) async {
    await _storage.write(key: AppConstants.userLoginToken, value: value);
    token = value;
  }

  static Future<void> clear(SharedPreferences preferences) async {
    token = null;
    await _storage.delete(key: AppConstants.userLoginToken);
    await preferences.remove(AppConstants.userLoginToken);
  }
}
