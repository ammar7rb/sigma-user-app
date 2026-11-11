import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the session token in platform secure storage after one-time migration.
class AuthTokenStore {
  static const _storage = FlutterSecureStorage();
  static String? token;

  static Future<void> initialize(SharedPreferences preferences) async {
    try {
      token = await _storage.read(key: AppConstants.userLoginToken);
    } catch (_) {
      token = null;
    }
    final legacy = preferences.getString(AppConstants.userLoginToken);
    if ((token == null || token!.isEmpty) && legacy != null && legacy.isNotEmpty && legacy != 'null') {
      try {
        await _storage.write(key: AppConstants.userLoginToken, value: legacy);
      } catch (_) {}
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
    token = value;
    try {
      await _storage.write(key: AppConstants.userLoginToken, value: value);
    } catch (_) {}
  }

  static Future<void> clear(SharedPreferences preferences) async {
    token = null;
    try {
      await _storage.delete(key: AppConstants.userLoginToken);
    } catch (_) {}
    await preferences.remove(AppConstants.userLoginToken);
  }
}
