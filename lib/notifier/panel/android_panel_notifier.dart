import 'package:fluent_ui/fluent_ui.dart';

class AndroidPanelNotifier extends ChangeNotifier {
  /// 设备列表监听
  List<String> _deviceList = [];

  /// 设备选择
  int _deviceIndex = 0;

  /// 脚本列表监听
  List<String> _scriptList = [];

  /// 脚本选择
  int _scriptIndex = 0;

  /// 包名列表监听
  List<String> _packageList = [];

  /// 包名选择
  int _packageIndex = 0;

  List<String> get packageList => _packageList;

  set packageList(List<String> value) {
    _packageList = value;
    packageIndex = 0;
    notifyListeners();
  }

  int get scriptIndex => _scriptIndex;

  set scriptIndex(int value) {
    _scriptIndex = value;
  }

  List<String> get scriptList => _scriptList;

  set scriptList(List<String> value) {
    _scriptList = value;
    scriptIndex = 0;
    notifyListeners();
  }

  List<String> get deviceList => _deviceList;

  set deviceList(List<String> value) {
    _deviceList = value;
    deviceIndex = 0;
    notifyListeners();
  }

  int get deviceIndex => _deviceIndex;

  set deviceIndex(int value) {
    _deviceIndex = value;
  }

  int get packageIndex => _packageIndex;

  set packageIndex(int value) {
    _packageIndex = value;
  }
}
