/**
 * @Classname click_type
 * @Date 2025/3/15 15:56
 * @Created by jacky
 * @Description 点击类型
 */
enum ClickType {
  REFRESH_DEVICE,
  WIRELESS_CONNECT,
  DISCONNECT_DEVICE,
  NEW_SIM_SCRIPT,
}

enum AndroidPanelClickType {
  SIM_OPERATION_START,
  SIM_OPERATION_STOP,
}

extension ClickTypeValue on ClickType {
  String get value {
    String _value = '';
    switch (this) {
      case ClickType.REFRESH_DEVICE:
        _value = '刷新设备';
        break;
      case ClickType.WIRELESS_CONNECT:
        _value = '无线连接';
        break;
      case ClickType.DISCONNECT_DEVICE:
        _value = '断开连接';
        break;
      case ClickType.NEW_SIM_SCRIPT:
        _value = '新建脚本';
        break;
      default:
    }
    return _value;
  }
}

extension AndroidPanelClickValue on AndroidPanelClickType {
  String get value {
    String _value = '';
    switch (this) {
      case AndroidPanelClickType.SIM_OPERATION_START:
        _value = '开始执行';
        break;
      case AndroidPanelClickType.SIM_OPERATION_STOP:
        _value = '停止执行';
        break;
      default:
    }
    return _value;
  }
}
