import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();
  static const _themeKey = 'preferred_theme_mode';
  static const _languageKey = 'preferred_language';

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSwahili => _locale.languageCode == 'sw';

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _themeMode = preferences.getString(_themeKey) == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light;
      _locale = Locale(preferences.getString(_languageKey) ?? 'en');
    } catch (_) {
      // Keep the in-memory defaults when browser/device storage is unavailable.
    }
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_themeKey, enabled ? 'dark' : 'light');
    } catch (_) {
      // The selection still applies for the current app session.
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode == 'sw' ? 'sw' : 'en');
    notifyListeners();
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_languageKey, _locale.languageCode);
    } catch (_) {
      // The selection still applies for the current app session.
    }
  }
}