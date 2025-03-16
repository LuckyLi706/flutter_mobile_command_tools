/**
 * @Classname file_name_type
 * @Date 2025/3/15 17:50
 * @Created by jacky
 * @Description 文件名
 */
enum FileNameType { WIRELESS_CONNECT, SIM_OPERATION }

extension FileNameTypeValue on FileNameType {
  String get value {
    String _value = '';
    switch (this) {
      case FileNameType.WIRELESS_CONNECT:
        _value = 'WIRELESS_CONNECT';
        break;
      case FileNameType.SIM_OPERATION:
        _value = 'SIM_OPERATION';
        break;
      default:
    }
    return _value;
  }
}
