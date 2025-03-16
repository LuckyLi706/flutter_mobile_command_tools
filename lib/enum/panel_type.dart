/**
 * @Classname PanelType
 * @Date 2025/3/15 16:07
 * @Created by jacky
 * @Description 左边panel的类型
 */
enum PanelType {
  Android,
  Harmony,
  Setting,
}

extension PanelTypeValue on PanelType {
  String get value {
    String _value = '';
    switch (this) {
      case PanelType.Android:
        _value = '安卓';
        break;
      case PanelType.Harmony:
        _value = '鸿蒙';
        break;
      case PanelType.Setting:
        _value = '设置';
        break;
      default:
    }
    return _value;
  }
}
