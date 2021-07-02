/// 所有的模拟操作
class SimOperation {
  String _name = "";
  String _x1 = "";

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String _y1 = "";
  String _x2 = "";
  String _y2 = "";
  String _data = "";
  int _duration = 0;

  String get x1 => _x1;

  set x1(String value) {
    _x1 = value;
  }

  String get y1 => _y1;

  set y1(String value) {
    _y1 = value;
  }

  String get x2 => _x2;

  set x2(String value) {
    _x2 = value;
  }

  String get y2 => _y2;

  set y2(String value) {
    _y2 = value;
  }

  String get data => _data;

  int get duration => _duration;

  set duration(int value) {
    _duration = value;
  }

  set data(String value) {
    _data = value;
  }
}
