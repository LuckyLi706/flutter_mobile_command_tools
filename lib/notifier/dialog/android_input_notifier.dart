import 'package:fluent_ui/fluent_ui.dart';

/**
 * @Classname android_wireless_notifier
 * @Date 2025/3/15 19:37
 * @Created by jacky
 * @Description 无线连接的通知
 */
class AndroidInputNotifier extends ChangeNotifier {
  String _connectDevice = '';
  List<String> _connectDeviceList = [];

  List<String> get connectDeviceList => _connectDeviceList;

  set connectDeviceList(List<String> value) {
    _connectDeviceList = value;
    notifyListeners();
  }

  String get connectDevice => _connectDevice;

  set connectDevice(String value) {
    _connectDevice = value;
    notifyListeners();
  }
}
