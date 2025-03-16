import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobile_command_tools/enum/panel_type.dart';

class Global {
  static String adbPath = ""; //真正使用的adb路径

  static PanelType panelType = PanelType.Android;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
}
