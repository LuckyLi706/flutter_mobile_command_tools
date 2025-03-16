import 'package:flutter_mobile_command_tools/notifier/panel/android_panel_notifier.dart';
import 'package:provider/provider.dart';

import '../global.dart';

/**
 * @Classname notifier_utils
 * @Date 2025/3/16 21:18
 * @Created by jacky
 * @Description 获取通知器
 */
class NotifierUtils {
  static AndroidPanelNotifier getAndroidPanelNotifier() {
    return Provider.of<AndroidPanelNotifier>(
        Global.navigatorKey.currentContext!,
        listen: false);
  }
}
