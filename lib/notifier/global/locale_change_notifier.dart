import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/utils/sp_util.dart';

/// @description: 全局语言切换器
/// @time 2024/5/23 15:48
/// @author lijie
/// @email jackyli706@gmail.com
/// https://blog.csdn.net/Calvin_zhou/article/details/119084704 语言配置参考
class LocaleChangeNotifier extends ChangeNotifier {
  List<Locale> localeList = [const Locale('zh'), const Locale('en')];

  late Locale _locale = localeList[SpUtil.getInstance().getLocaleIndex()];

  Locale get locale => _locale;

  void setLanguage(int index) {
    _locale = localeList[index];
    notifyListeners();
  }
}
