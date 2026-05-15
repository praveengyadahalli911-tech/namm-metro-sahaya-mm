import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/translation_service.dart';

class SettingsViewModel extends ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _isAdmin = false;

  Locale get locale => _locale;
  bool get isAdmin => _isAdmin;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(langCode);
    _isAdmin = prefs.getBool('is_admin') ?? false;
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _locale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    notifyListeners();
  }

  Future<void> setAdminMode(bool enabled) async {
    _isAdmin = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_admin', enabled);
    notifyListeners();
  }

  String translate(String key) {
    return TranslationService.translate(key, _locale.languageCode);
  }
}
