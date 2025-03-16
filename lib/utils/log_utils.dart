import 'package:flutter_mobile_command_tools/global.dart';
import 'package:flutter_mobile_command_tools/notifier/log_change_notifier.dart';
import 'package:provider/provider.dart';

class LogUtils {
  ///Release：const bool.fromEnvironment("dart.vm.product") = true；
  /// Debug：assert(() { ...; return true; });断言语句会被执行；
  /// Profile：上面的两种情况均不会发生。
  static printLog(log) {
    const bool inProduction = const bool.fromEnvironment("dart.vm.product");
    if (!inProduction) {
      print(log);
    }
  }

  /// 展示log日志
  static showLog(log) {
    Provider.of<LogChangeNotifier>(Global.navigatorKey.currentContext!,
            listen: false)
        .addLog(">>>>>> ${log}");
  }
}
