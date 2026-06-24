import 'package:flutter/material.dart';
import 'package:saathi/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  ThemeProvider({required this.prefs}) {
    _dark = prefs.getBool(AppConstants.themeMode) ?? false;
  }

  bool _dark = false;
  bool get isDark => _dark;
  ThemeMode get themeMode => _dark ? ThemeMode.dark : ThemeMode.light;

  void toggle() {
    _dark = !_dark;
    prefs.setBool(AppConstants.themeMode, _dark);
    notifyListeners();
  }
}
