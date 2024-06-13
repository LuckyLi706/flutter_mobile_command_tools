import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// @description: 少量数据存储
/// @time 2024/6/4 14:25
/// @author lijie
/// @email jackyli706@gmail.com
class SpUtil {
  static SharedPreferences? _prefs;

  SpUtil._internal();

  factory SpUtil() => _instance;

  static final SpUtil _instance = SpUtil._internal();

  static SpUtil getInstance() {
    return _instance;
  }

  Future<void> initSp() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool?> setThemeIndex(int index) async {
    return await _prefs?.setInt(Constants.THEME_INDEX_KEY, index);
  }

  int getThemeIndex() {
    return _prefs?.getInt(Constants.THEME_INDEX_KEY) ?? 0;
  }

  Future<bool?> setLocaleIndex(int index) async {
    return await _prefs?.setInt(Constants.LOCALE_INDEX_KEY, index);
  }

  int getLocaleIndex() {
    return _prefs?.getInt(Constants.LOCALE_INDEX_KEY) ?? 0;
  }
}
