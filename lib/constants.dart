import 'dart:core';

import 'dart:io';

class Constants {
  static const String APP_TITLE_NAME = "MobileTools";

  static String adbPath = "";
  static String apksignerPath = "";

  static String currentDevice = ""; //当前的设备

  static String desktopPath = ""; //桌面路径

  static String userPath = ""; //用户路径

  static const String LOG_SHOW_TEXT = "日志：";

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
  static const String ADB_INSTALL_APK = "install";
  static const String ADB_UNINSTALL_APK = "uninstall";
  static const String ADB_REBOOT = "reboot";
  static const String ADB_REBOOT_BOOTLOADER = "reboot bootloader";
  static const String ADB_IP = "shell ifconfig | grep 192.168";
  static const String ADB_FORWARD_PORT = "tcpip 5555";
  static const String ADB_WIRELESS_CONNECT = "connect";
  static const String ADB_WIRELESS_DISCONNECT = "disconnect";
  static const String ADB_PUSH_FILE = "push";
  static const String ADB_PULL_ANR = "bugreport";
  static const String ADB_PULL_CRASH = "shell dumpsys dropbox | grep crash";
  static const String ADB_PULL_CRASH_FILE = "shell dumpsys dropbox";
  static const String ADB_SEARCH_ALL_FILE_PATH = "shell ls";
  static const String ADB_PULL_FILE = "pull";
  static const String ADB_SIM_SWIPE = "shell input swipe"; //滑动
  static const String ADB_SIM_TAP = "shell input tap"; //点击
  static const String ADB_SIM_INPUT = "shell input text"; //输入
  static const String ADB_SIM_BACK = "shell input keyevent 4"; //后退
  static const String ADB_APK_SIGNER =
      "sign --ks jks_path --ks-key-alias myalias --ks-pass pass: mypass -key-pass pass: mykeypass -out newapkpath outapkpath";

  static const List<String> ALL_SIM_OPERATION = ["输入", "滑动", "点击", "后退"];
}
