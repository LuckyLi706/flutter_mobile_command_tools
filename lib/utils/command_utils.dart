import 'package:flutter_mobile_command_tools/command/adb_command.dart';
import 'package:provider/provider.dart';

import '../enum/adb_command_type.dart';
import '../global.dart';
import '../notifier/panel/android_panel_notifier.dart';

class AndroidCommandUtils {
  static final _adbCommand = new AdbCommand();

  static AdbCommand getAdbCommand() {
    return _adbCommand;
  }

  /// 发送连接设备的指令
  static sendConnectDeviceOrder() {
    _adbCommand
        .runCommand<List<String>>(AdbCommandType.ADB_CONNECT_DEVICES.value)
        .then((value) {
      if (value != null) {
        if (value.isSuccess) {
          Provider.of<AndroidPanelNotifier>(Global.navigatorKey.currentContext!,
                  listen: false)
              .deviceList = value.data!;
        }
      }
    });
  }
}
