import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _biometricKey = 'biometric_enabled';
  static const _themeModeKey = 'theme_mode';

  Future<ThemeMode> getThemeMode() async {
    final val = await _storage.read(key: _themeModeKey);
    return switch (val) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _storage.write(key: _themeModeKey, value: mode.name);
  }

  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricKey);
    return val == 'true';
  }

  Future<bool> isBiometricPreferenceSet() async {
    return await _storage.containsKey(key: _biometricKey);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricKey, value: enabled.toString());
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
