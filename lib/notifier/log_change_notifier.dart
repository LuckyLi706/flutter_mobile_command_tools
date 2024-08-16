import 'package:flutter/widgets.dart';

class LogChangeNotifier extends ChangeNotifier {
  ScrollController scrollController = ScrollController();
  List<String> _logList = [];

  List<String> get logList => _logList;

  void addLog(dynamic log) {
    if (log is String) {
      _logList.add(log);
    } else if (log is List) {
      _logList.add(log.join(" "));
    } else {
      _logList.add(log);
    }
    notifyListeners();

    Future.delayed(Duration(milliseconds: 500), () {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
    });
  }

  void clearLog() {
    _logList.clear();
    notifyListeners();
  }
}
