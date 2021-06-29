import 'dart:core';

import 'dart:io';

class Constants {
  static const String APP_TITLE_NAME = "MobileTools";

  static String adbPath = "";

  static String currentDevice = ""; //当前的设备

  static String desktopPath = ""; //桌面路径

  static String userPath=""; //用户路径

  static const String SCREEN_SHOOT_NAME = "screen";

  //安卓的adb命令行
  static const String ADB_CONNECT_DEVICES = "devices";
  static const String ADB_GET_PACKAGE = "shell dumpsys activity";
  static const String ADB_SCREEN_SHOT =
      "shell /system/bin/screencap -p /sdcard/" +
          Constants.SCREEN_SHOOT_NAME +
          ".png";
  static const String ADB_PULL_SCREEN_SHOT =
      "pull /sdcard/" + Constants.SCREEN_SHOOT_NAME + ".png";
}
