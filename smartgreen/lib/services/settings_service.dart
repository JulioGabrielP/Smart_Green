import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const _kNotifications = 'notifications_enabled';
  static const _kThemeMode = 'theme_mode';
  static const _kLanguage = 'language';
  static const _kHistory = 'cultivation_history';

  bool _notificationsEnabled = true;
  String _themeMode = 'light'; // 'light' | 'dark' | 'system'
  String _language = 'pt'; // 'pt' | 'en' | ...
  List<String> _history = [];

  bool get notificationsEnabled => _notificationsEnabled;
  String get themeMode => _themeMode;
  String get language => _language;
  List<String> get history => List.unmodifiable(_history);

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _notificationsEnabled = sp.getBool(_kNotifications) ?? true;
    _themeMode = sp.getString(_kThemeMode) ?? 'light';
    _language = sp.getString(_kLanguage) ?? 'pt';
    _history = sp.getStringList(_kHistory) ?? [];
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kNotifications, value);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kThemeMode, mode);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLanguage, lang);
    notifyListeners();
  }

  Future<void> addHistoryItem(String item) async {
    if (item.trim().isEmpty) return;
    _history.insert(0, item.trim());
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kHistory, _history);
    notifyListeners();
  }

  Future<void> removeHistoryItemAt(int index) async {
    if (index < 0 || index >= _history.length) return;
    _history.removeAt(index);
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kHistory, _history);
    notifyListeners();
  }
}
