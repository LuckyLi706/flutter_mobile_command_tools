import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/enum/click_type.dart';
import 'package:flutter_mobile_command_tools/enum/file_name_type.dart';
import 'package:flutter_mobile_command_tools/global.dart';
import 'package:flutter_mobile_command_tools/mixin/android_panel_mixin.dart';
import 'package:flutter_mobile_command_tools/utils/toast_utils.dart';
import 'package:provider/provider.dart';

import '../notifier/panel/android_panel_notifier.dart';
import '../utils/command_utils.dart';
import '../utils/dialog_utils.dart';

/**
 * @Classname main_mixin
 * @Date 2025/3/15 16:17
 * @Created by jacky
 * @Description 主页的功能逻辑
 */
mixin MainMixin  {
  onClick(ClickType clickType, {dynamic params}) {
    switch (clickType) {
      case ClickType.REFRESH_DEVICE:
        _refreshDevice();
        break;
      case ClickType.WIRELESS_CONNECT:
        _wirelessConnectDevice();
        break;
      case ClickType.DISCONNECT_DEVICE:
        _disconnectDevice();
        break;
      case ClickType.NEW_SIM_SCRIPT:
        _newSimScript();
        break;
    }
  }

  /// 刷新设备
  _refreshDevice() {
    AndroidCommandUtils.sendConnectDeviceOrder();
  }

  /// 无线连接
  _wirelessConnectDevice() {
    DialogUtils.showInputDialog(
            title: "无线连接",
            fileNameType: FileNameType.WIRELESS_CONNECT,
            confirmText: '连接')
        .then((result) {
      AndroidCommandUtils.sendWirelessConnectDeviceOrder(result);
    });
  }

  /// 断开连接设备
  _disconnectDevice() {
    if (!isExistDevice()) {
      return;
    }
    DialogUtils.showTextDialog(
        contents: [
          "确定要断开设备",
          Global.navigatorKey.currentContext!
                  .read<AndroidPanelNotifier>()
                  .deviceList[
              Global.navigatorKey.currentContext!
                  .read<AndroidPanelNotifier>()
                  .deviceIndex],
          "嘛？"
        ],
        colorChangeIndex: [
          1
        ],
        contentChangeColor: [
          Colors.red
        ],
        title: ClickType.DISCONNECT_DEVICE.value,
        onConfirm: () {
          AndroidCommandUtils.sendDisConnectDeviceOrder(Global
                  .navigatorKey.currentContext!
                  .read<AndroidPanelNotifier>()
                  .deviceList[
              Global.navigatorKey.currentContext!
                  .read<AndroidPanelNotifier>()
                  .deviceIndex]);
        });
  }

  /// 新建虚拟操作脚本
  _newSimScript() {
    DialogUtils.showNewOperationScriptDialog();
  }

  /// 当前是否存在设备
  isExistDevice({bool isShowToast = true}) {
    if (Global.navigatorKey.currentContext!
        .read<AndroidPanelNotifier>()
        .deviceList
        .isEmpty) {
      if (isShowToast) {
        showToast(
            message: '当前无连接设备，请先刷新设备再操作',
            title: "操作失败：",
            severity: InfoBarSeverity.error);
      }
      return false;
    }
    return true;
  }
}
