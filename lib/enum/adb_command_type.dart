enum AdbCommandType {
  /// 版本
  ADB_VERSION,

  /// 连接的设备
  ADB_CONNECT_DEVICES,

  /// 获取包名
  ADB_GET_PACKAGE,

  /// 获取第三方包名
  ADB_GET_THIRD_PACKAGE,

  /// 获取系统包名
  ADB_GET_SYSTEM_PACKAGE,

  /// 获取冻结包名
  ADB_GET_FREEZE_PACKAGE,

  /// 获取包名信息
  ADB_GET_PACKAGE_INFO,

  /// 获取顶级Activity
  ADB_GET_PACKAGE_INFO_MAIN_ACTIVITY,

  ///关于冷冻/解冻app使用disable/enable命令,
  ///使用hide只是简单的从启动器移除图标而已
  ///https://www.v2ex.com/t/292092   pm hide 和 pm disable 有什么区别
  ///https://blog.csdn.net/zuiaikg703/article/details/72763825/ adb命令之pm hide 与 disable
  ///冻结app
  ADB_FREEZE_PACKAGE,

  /// 解冻app
  ADB_NOT_FREEZE_PACKAGE,

  /// 无线连接
  ADB_WIRELESS_CONNECT,

  /// 断开连接
  ADB_WIRELESS_DISCONNECT,

  /// 模拟指令滑动
  ADB_SIM_OPERATION_SWIPE,

  /// 模拟指令点击
  ADB_SIM_OPERATION_TAP,

  /// 模拟指令输入文本
  ADB_SIM_OPERATION_TEXT,

  /// 模拟指令事件
  ADB_SIM_OPERATION_EVENT,
}

extension AdbCommandTypeValue on AdbCommandType {
  String get value {
    String _value = '';
    switch (this) {
      case AdbCommandType.ADB_VERSION:
        _value = 'version';
        break;
      case AdbCommandType.ADB_CONNECT_DEVICES:
        _value = 'devices';
        break;
      case AdbCommandType.ADB_GET_PACKAGE:
        _value = 'shell dumpsys activity';
        break;
      case AdbCommandType.ADB_GET_THIRD_PACKAGE:
        _value = 'shell pm list packages -3';
        break;
      case AdbCommandType.ADB_GET_SYSTEM_PACKAGE:
        _value = 'shell pm list packages -s';
        break;
      case AdbCommandType.ADB_GET_FREEZE_PACKAGE:
        _value = 'shell pm list packages -d';
        break;
      case AdbCommandType.ADB_GET_PACKAGE_INFO:
        _value = 'shell dumpsys package ';
        break;
      case AdbCommandType.ADB_GET_PACKAGE_INFO_MAIN_ACTIVITY:
        _value = 'shell dumpsys package top ';
        break;
      case AdbCommandType.ADB_FREEZE_PACKAGE:
        _value = 'shell dumpsys package top ';
        break;
      case AdbCommandType.ADB_GET_PACKAGE_INFO_MAIN_ACTIVITY:
        _value = 'shell pm disable package ';
        break;
      case AdbCommandType.ADB_NOT_FREEZE_PACKAGE:
        _value = 'shell pm enable package';
        break;
      case AdbCommandType.ADB_WIRELESS_CONNECT:
        _value = 'connect';
        break;
      case AdbCommandType.ADB_WIRELESS_DISCONNECT:
        _value = 'disconnect';
        break;
      case AdbCommandType.ADB_SIM_OPERATION_SWIPE:
        _value = 'shell input swipe';
        break;
      case AdbCommandType.ADB_SIM_OPERATION_TAP:
        _value = 'shell input tap';
        break;
      case AdbCommandType.ADB_SIM_OPERATION_TEXT:
        _value = 'shell input text';
        break;
      case AdbCommandType.ADB_SIM_OPERATION_EVENT:
        _value = 'shell input keyevent';
        break;
      default:
    }
    return _value;
  }
}
