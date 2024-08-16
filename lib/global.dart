import 'package:flutter/widgets.dart';

class Global {
  static String adbPath = ""; //真正使用的adb路径

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
