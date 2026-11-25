import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() : _storage = const FlutterSecureStorage();

  static const _storageKey = 'theme_mode';
  final FlutterSecureStorage _storage;
  bool isDark = true;

  Future<void> restore() async {
    final saved = await _storage.read(key: _storageKey);
    isDark = saved != 'light';
    AppColors.setDarkMode(isDark);
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    isDark = value;
    AppColors.setDarkMode(value);
    notifyListeners();
    await _storage.write(key: _storageKey, value: value ? 'dark' : 'light');
  }
}
