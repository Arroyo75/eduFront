import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _bypassLocksKey = 'bypass_locks';
  static const String _debugModeKey = 'debug_mode';

  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  //bypass
  bool get bypassLocks => _prefs.getBool(_bypassLocksKey) ?? false;

  Future<void> setBypassLocks(bool value) async {
    await _prefs.setBool(_bypassLocksKey, value);
  }

  //debug mode
  bool get debugMode => _prefs.getBool(_debugModeKey) ?? false;

  Future<void> setDebugMode(bool value) async {
    await _prefs.setBool(_debugModeKey, value);
  }
}