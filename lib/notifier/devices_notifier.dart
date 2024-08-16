import 'package:flutter/foundation.dart';

class DevicesChangeNotifier extends ChangeNotifier {
  List<String> _deviceList = [];

  int _index = 0;

  bool _isHidden = true;

  bool get isHidden => _isHidden;

  set isHidden(bool value) {
    _isHidden = value;
    notifyListeners();
  }

  List<String> get deviceList => _deviceList;

  set deviceList(List<String> value) {
    _deviceList = value;
    index = 0;
  }

  int get index => _index;

  set index(int value) {
    _index = value;
    notifyListeners();
  }
}
