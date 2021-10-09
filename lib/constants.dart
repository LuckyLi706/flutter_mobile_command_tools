import 'dart:core';

import 'dart:io';

class Constants {
  static const String APP_TITLE_NAME = "MobileTools_v1.0";

  static bool isRoot = false; //是否开启root
  static bool isInnerAdb = false; //是否使用内部的adb

  static String adbPath = "";
  static String apksignerPath = "";

  static String currentDevice = ""; //当前的设备

  static String desktopPath = ""; //桌面路径

  static String userPath = ""; //用户路径

  static const String LOG_SHOW_TEXT = "日志：";

  static const String SCREEN_SHOOT_NAME = "shoot.png";
  static const String SCREEN_RECORD_NAME = "record.mp4";

  //安卓的adb命令行
  static const String ADB_CONNECT_DEVICES = "devices";
  static const String ADB_GET_PACKAGE = "shell dumpsys activity";
  static const String ADB_CURRENT_ACTIVITY = "shell dumpsys  activity";
  static const String ADB_CLEAR_DATA = "shell pm clear";
  static const String ADB_SCREEN_SHOT =
      "shell screencap -p /sdcard/" + Constants.SCREEN_SHOOT_NAME;

  /// --bit-rate 6000000 比特率，默认4Mbps
  /// --size 1280*720 分辨率，默认手机分辨率
  /// --time-limit  时间，默认180s
  /// --verbose 显示log信息
  static const String ADB_SCREEN_RECORD =
      "shell screenrecord --time-limit times /sdcard/" + SCREEN_RECORD_NAME;
  static const String ADB_PULL_SCREEN_SHOT =
      "pull /sdcard/" + Constants.SCREEN_SHOOT_NAME;
  static const String ADB_PULL_SCREEN_RECORD =
      "pull /sdcard/" + Constants.SCREEN_RECORD_NAME;
  static const String ADB_INSTALL_APK = "install";
  static const String ADB_UNINSTALL_APK =
      "shell  pm uninstall --user 0 package";
  static const String ADB_APK_PATH = "shell pm path package";
  static const String ADB_REBOOT = "reboot";
  static const String ADB_REBOOT_BOOTLOADER = "reboot bootloader";
  static const String ADB_REBOOT_RECOVERY = "reboot recovery";

  static const String WIFI_MAC_ADDRESS =
      "shell cat /sys/class/net/wlan0/address";
  static const String BLUE_MAC_ADDRESS =
      "shell settings get secure bluetooth_address";
  static const String IP_ADDRESS = "shell ifconfig | grep Mask";
  static const String WINDOW_INFO =
      "shell  dumpsys window displays | grep init";
  static const String CPU_INFO = "shell cat /proc/cpuinfo";
  static const String BATTERY_INFO = "shell dumpsys battery";
  static const String MEMORY_INFO = "shell cat /proc/meminfo";
  static const String PHONE_INFO = "shell cat /system/build.prop";

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
  static const String APK_SIGNER =
      "java -jar apksign sign --ks jks_path --ks-key-alias myalias --ks-pass pass:mypass --key-pass pass:mykeypass --out outapk inputapk";
  static const String VERIFY_APK_SIGNER =
      "java -jar apksign verify -v --print-certs inputapk";

  static const List<String> ALL_SIM_OPERATION = ["输入", "滑动", "点击", "后退"];

  static late File signerPath;
  static late File jksPath;
  static late File signerJarPath;

  static String getPhoneInfo(int index) {
    switch (index) {
      case 0:
        return isRoot
            ? _shellRoot(Constants.BLUE_MAC_ADDRESS)
            : Constants.BLUE_MAC_ADDRESS;
      case 1:
        return isRoot
            ? _shellRoot(Constants.WIFI_MAC_ADDRESS)
            : Constants.WIFI_MAC_ADDRESS;
      case 2:
        return isRoot ? _shellRoot(Constants.IP_ADDRESS) : Constants.IP_ADDRESS;
      case 3:
        return isRoot
            ? _shellRoot(Constants.WINDOW_INFO)
            : Constants.WINDOW_INFO;
      case 4:
        return isRoot ? _shellRoot(Constants.CPU_INFO) : Constants.CPU_INFO;
      case 5:
        return isRoot
            ? _shellRoot(Constants.BATTERY_INFO)
            : Constants.BATTERY_INFO;
      case 6:
        return isRoot
            ? _shellRoot(Constants.MEMORY_INFO)
            : Constants.MEMORY_INFO;
      case 7:
        return isRoot ? _shellRoot(Constants.PHONE_INFO) : Constants.PHONE_INFO;
    }
    return "";
  }

  static String _shellRoot(String command) {
    return command.replaceAll("shell", "shell su -c"); //有些命令需要使用-t su -c
  }
}
