import 'package:flutter/foundation.dart';

class LogChangeNotifier extends ChangeNotifier {
  List<String> _logList = [];

  List<String> get logList => _logList;

  void addLog(String log) {
    _logList.add(log);
    notifyListeners();
  }
}
