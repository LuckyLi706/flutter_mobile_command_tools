import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/global.dart';

/**
 * @Classname screen_utils
 * @Date 2025/3/15 14:45
 * @Created by jacky
 * @Description 屏幕相关的工具类
 */
class WindowUtils {
  /// 获取长度
  static double getWindowWidth() {
    return MediaQuery.of(Global.navigatorKey.currentContext!).size.width;
  }

  /// 获取宽度
  static double getWindowHeight() {
    return MediaQuery.of(Global.navigatorKey.currentContext!).size.height;
  }
}
