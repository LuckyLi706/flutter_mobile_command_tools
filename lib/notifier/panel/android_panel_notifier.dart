import 'package:fluent_ui/fluent_ui.dart';

class AndroidPanelNotifier extends ChangeNotifier {
  /// 设备列表监听
  List<String> _deviceList = [];

  /// 设备选择
  int _deviceIndex = 0;

  /// 包名列表监听
  List<String> _packageList = [];

  /// 包名选择
  int _packageIndex = 0;

  /**
   *  模拟操作相关
   */

  /// 脚本列表监听
  List<String> _simOperationKeyList = [];

  /// 脚本选择
  int _simOperationKeyIndex = 0;

  /// 脚本是否在执行
  bool _isRunning = false;

  /// 是否循环执行
  bool _isRepeat = true;

  /// 随机间隔
  String _randomPeriod = '599,600';

  bool get isRunning => _isRunning;

  set isRunning(bool value) {
    _isRunning = value;
    notifyListeners();
  }

  int get simOperationKeyIndex => _simOperationKeyIndex;

  set simOperationKeyIndex(int value) {
    _simOperationKeyIndex = value;
    notifyListeners();
  }

  List<String> get simOperationKeyList => _simOperationKeyList;

  set simOperationKeyList(List<String> value) {
    _simOperationKeyList = value;
    notifyListeners();
  }

  List<String> get packageList => _packageList;

  set packageList(List<String> value) {
    _packageList = value;
    packageIndex = 0;
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

  bool get isRepeat => _isRepeat;

  set isRepeat(bool value) {
    _isRepeat = value;
    notifyListeners();
  }

  String get randomPeriod => _randomPeriod;

  set randomPeriod(String value) {
    _randomPeriod = value;
    notifyListeners();
  }
}
