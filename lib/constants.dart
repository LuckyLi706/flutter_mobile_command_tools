import 'dart:core';

import 'dart:io';

class Constants {
  static String APP_TITLE_NAME = APP_NAME + "_" + APP_VERSION;

  static const String APP_NAME = "MobileTools";
  static const String APP_VERSION = "3.0";

  static const String TOOLS_DIRECTORY_NAME = "tools"; //tools directory name
  static const String CONFIG_DIRECTORY_NAME = "config"; //tools directory name

  static bool isRoot = false; //是否开启root
  static bool isInnerAdb = false; //是否使用内部的adb

  static String adbPath = ""; //真正使用的adb路径
  static String javaPath = ""; //java路径
  static String libDevicePath = ""; //libimobiledevice目录

  static String innerAdbPath = ""; //内置的adb路径
  static String outerAdbPath = ""; //外置的adb路径

  static String innerKey = "innerAdbPath"; //innerAdbPath对应的key
  static String outerKey = "outerAdbPath"; //outerAdbPath对应的key
  static String javaKey = "javaPath";
  static String libDeviceKey = "libDeviceKey";
  static String isRootKey = "isRoot";
  static String isInnerAdbKey = "isInnerAdb";

  static String apksignerPath = "";

  static String currentDevice = ""; //当前的安卓设备
  static String currentIOSDevice = ""; //当前的IOS设备

  static String currentPackageName = "";
  static String currentIOSPackageName = ""; //当前IOS包名

  static String currentSimOpName = ""; //当前的模拟操作
  static int currentSimType = 1;

  static String desktopPath = ""; //桌面路径

  static String userPath = ""; //用户路径

  static const String LOG_SHOW_TEXT = "日志：";

  static const String SCREEN_SHOOT_NAME = "shoot.png";
  static const String SCREEN_RECORD_NAME = "record_screen.mp4";

  //IOS的ideviceinstaller命令行

  static const String IOS_GET_DEVICE = "-l";
  static const String IOS_GET_THIRD_PACKAGE = "-l -o list_user";
  static const String IOS_GET_SYSTEM_PACKAGE = "-l -o list_system";

  //安卓的adb命令行
  static const String ADB_VERSION = "version";
  static const String ADB_CONNECT_DEVICES = "devices";
  static const String ADB_GET_PACKAGE = "shell dumpsys activity";
  static const String ADB_GET_THIRD_PACKAGE = "shell pm list packages -3";
  static const String ADB_GET_SYSTEM_PACKAGE = "shell pm list packages -s";
  static const String ADB_GET_PACKAGE_INFO = "shell dumpsys package ";

  static const String ADB_START_ACTIVITY_NO =
      "shell monkey -p package -c android.intent.category.LAUNCHER 1";
  static const String ADB_START_ACTIVITY = "shell am start -n ";
  static const String ADB_START_BROADCAST_RECEIVER = "shell am broadcast -a ";
  static const String ADB_START_SERVICE = "shell am startservice -n ";
  static const String ADB_STOP_SERVICE = "shell am stopservice -n ";

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
  static const String FASTBOOT_UNLOCK = "flashing unlock";
  static const String FASTBOOT_LOCK = "flashing lock";
  static const String FASTBOOT_LOCK_STATE = "getvar devices-state";

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
  static const String ADB_SIM_KEY_EVENT = "shell input keyevent";
  static const String APK_SIGNER =
      "java -jar apksign sign --ks jks_path --ks-key-alias myalias --ks-pass pass:mypass --key-pass pass:mykeypass --out outapk inputapk";
  static const String VERIFY_APK_SIGNER =
      "java -jar apksign verify -v --print-certs inputapk";

  static const String UI_TOOL_NAME = "uiautomatorviewer";
  static const String APK_TOOL_NAME = "apktool";

  static const String OPEN_UI_TOOL =
      "java -Djava.ext.dirs=. -Dcom.android.uiautomator.bindir=adb_path -jar uiautomatorviewer.jar";
  static const String APKTOOL_DECODE =
      "java -jar ApkTool_path d command Apk_path";
  static const String APKTOOL_REBUILD =
      "java -jar ApkTool_path b command Apk_path -o new.apk";
  static const String Faker_Android =
      "java -jar Faker_Android_path fk Apk_path -o new.apk";

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
