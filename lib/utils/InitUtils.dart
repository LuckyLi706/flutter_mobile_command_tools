import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';

import '../constants.dart';
import 'FileUtils.dart';

class InitUtils {
  static Future init(Map<String, dynamic> map) async {
    await _initSetting(map);
    _initDesktop();
    _initApkSigner();
    _initInnerAdb();
    _initMutualAppFile();
  }

  //获取桌面路径
  static void _initDesktop() async {
    if (Platform.isWindows) {
      Process.run(r"echo %USERPROFILE%", [], runInShell: true)
          .then((value) async {
        if (value.stdout != "") {
          Constants.userPath =
              value.stdout.toString().split(PlatformUtils.getLineBreak())[0];
          Constants.desktopPath = Constants.userPath + r"\Desktop";
          if (!await FileUtils.isExistFolder(Constants.userPath)) {
            Constants.desktopPath = Directory.current.path;
          }
          _initAdbPath();
        } else {
          Constants.desktopPath = Directory.current.path;
        }
      });
    } else if (Platform.isMacOS) {
      Process.run(r"id", ["-un"], runInShell: true).then((value) async {
        if (value.stdout != "") {
          Constants.userPath = "/Users/" +
              value.stdout.toString().split(PlatformUtils.getLineBreak())[0];
          Constants.desktopPath = Constants.userPath + r"/Desktop";
          if (!await FileUtils.isExistFolder(Constants.userPath)) {
            String? path = await FileUtils.localPath(dir: FileUtils.TEMP_DIR);
            Constants.desktopPath = path == null ? "" : path;
          }
          _initAdbPath();
        } else {
          Constants.desktopPath = Directory.current.path;
        }
      });
    } else if (Platform.isLinux) {
      Process.run(r"id", ["-un"], runInShell: true).then((value) async {
        if (value.stdout != "") {
          Constants.userPath = "/home/" +
              value.stdout.toString().split(PlatformUtils.getLineBreak())[0];
          Constants.desktopPath = Constants.userPath + r"/Desktop";
          if (!await FileUtils.isExistFolder(Constants.userPath)) {
            Constants.desktopPath = Directory.current.path;
          }
          _initAdbPath();
        } else {
          Constants.desktopPath = Directory.current.path;
        }
      });
    }
  }

  //获取系统默认的adb目录
  static void _initAdbPath() {
    if (Constants.adbPath.isNotEmpty) {
      return;
    }
    if (Platform.isWindows) {
      Constants.adbPath = Constants.outerAdbPath = Constants.userPath +
          r"\AppData\Local\Android\sdk\platform-tools\adb.exe";
    } else if (Platform.isMacOS) {
      Constants.adbPath = Constants.outerAdbPath =
          Constants.userPath + r"/Library/Android/sdk/platform-tools/adb";
    } else if (Platform.isLinux) {
      Constants.adbPath = Constants.outerAdbPath =
          Constants.userPath + r"/Android/Sdk/platform-tools/adb";
    }
  }

  //初始化配置
  static _initSetting(Map<String, dynamic> mapSettings) async {
    String value = await FileUtils.readSetting();
    if (value.isNotEmpty) {
      Map<String, dynamic> map = jsonDecode(value);
      if (map[Constants.javaKey] != null) {
        Constants.javaPath = map[Constants.javaKey];
      }
      if (map[Constants.libDeviceKey] != null) {
        Constants.libDevicePath = map[Constants.libDeviceKey];
      }
      if (map[Constants.isInnerAdbKey] != null) {
        Constants.isInnerAdb = map[Constants.isInnerAdbKey];
      }
      if (map[Constants.outerKey] != null) {
        Constants.outerAdbPath = map[Constants.outerKey];
        if (!Constants.isInnerAdb) {
          Constants.adbPath = await FileUtils.getInnerAdbPath();
        }
      }
      if (map[Constants.innerKey] != null) {
        Constants.innerAdbPath = map[Constants.innerKey];
        if (Constants.isInnerAdb) {
          Constants.adbPath = await FileUtils.getInnerAdbPath();
        }
      }
      if (map[Constants.isRootKey] != null) {
        Constants.isRoot = map[Constants.isRootKey];
      }
      mapSettings.addAll(map);
    }
  }

  ///初始化签名文件
  static _initApkSigner() async {
    Constants.signerPath =
        await FileUtils.localFile("apksigner.json", subDir: "apksigner");
    String signer = await FileUtils.readFile(Constants.signerPath);
    if (signer.isEmpty) {
      signer = await rootBundle.loadString('assets/apksigner.json');
      FileUtils.writeFile(signer, Constants.signerPath);
    }

    Constants.jksPath =
        await FileUtils.localFile("apk.jks", subDir: "apksigner");
    if (!await FileUtils.isExistFile(Constants.jksPath.path)) {
      var buffer = await rootBundle.load('assets/apk.jks');
      FileUtils.writeBytesFile(buffer, Constants.jksPath);
    }

    Constants.signerJarPath =
        await FileUtils.localFile("apksigner.jar", subDir: "apksigner");
    if (!await FileUtils.isExistFile(Constants.signerJarPath.path)) {
      var buffer = await rootBundle.load('assets/apksigner.jar');
      FileUtils.writeBytesFile(buffer, Constants.signerJarPath);
    }
  }

  //初始化内部的adb
  static _initInnerAdb() async {
    String pathInner = await FileUtils.getInnerAdbPath();
    if (pathInner.isNotEmpty) {
      return;
    }
    String assetsAdbPath;
    if (Platform.isWindows) {
      assetsAdbPath = "assets/windows/tools.zip";
    } else if (Platform.isMacOS) {
      assetsAdbPath = "assets/macos/tools.zip";
    } else {
      assetsAdbPath = "assets/linux/tools.zip";
    }
    Directory directoryAdb = Directory('${await FileUtils.getBasePath()}' +
        PlatformUtils.getSeparator() +
        Constants.TOOLS_DIRECTORY_NAME);
    var path = directoryAdb.path + ".zip";
    if (!await directoryAdb.exists()) {
      var buffer = await rootBundle.load(assetsAdbPath);
      await FileUtils.writeBytesFile(buffer, File(path));
    }
    FileUtils.unZipFiles(directoryAdb.path, path);
  }

  static void _initMutualAppFile() async {
    FileUtils.createFile(await FileUtils.getMutualAppPath("Activity"));
    FileUtils.createFile(await FileUtils.getMutualAppPath("Service"));
    if (!await FileUtils.isExistFile(
        await FileUtils.getMutualAppPath("BroadcastReceiver"))) {
      FileUtils.createFile(
          await FileUtils.getMutualAppPath("BroadcastReceiver"));
      String content = "";
      broadcastReceiver.forEach((element) {
        content = content + element + PlatformUtils.getLineBreak();
      });
      FileUtils.writeFile(
          content, File(await FileUtils.getMutualAppPath("BroadcastReceiver")));
    }
  }

  static List<String> broadcastReceiver = [
    "android.net.conn.CONNECTIVITY_CHANGE",
    //网络连接发生变化
    "android.intent.action.SCREEN_ON",
    //屏幕点亮
    "android.intent.action.SCREEN_OFF",
    //屏幕熄灭
    "android.intent.action.BATTERY_LOW",
    //电量低，会弹出电量低提示框
    "android.intent.action.BATTERY_OKAY",
    //电量恢复了
    "android.intent.action.BOOT_COMPLETED",
    //设备启动完毕
    "android.intent.action.DEVICE_STORAGE_LOW",
    //存储空间过低
    "android.intent.action.DEVICE_STORAGE_OK",
    //存储空间恢复
    "android.intent.action.PACKAGE_ADDED",
    //安装了新的应用
    "android.net.wifi.STATE_CHANGE",
    //WiFi 连接状态发生变化
    "android.net.wifi.WIFI_STATE_CHANGED",
    //WiFi 状态变为启用/关闭/正在启动/正在关闭/未知
    "android.intent.action.BATTERY_CHANGED",
    //电池电量发生变化
    "android.intent.action.INPUT_METHOD_CHANGED",
    //系统输入法发生变化
    "android.intent.action.ACTION_POWER_CONNECTED",
    //外部电源连接
    "android.intent.action.ACTION_POWER_DISCONNECTED",
    //外部电源断开连接
    "android.intent.action.DREAMING_STARTED",
    //系统开始休眠
    "android.intent.action.DREAMING_STOPPED",
    //系统停止休眠
    "android.intent.action.WALLPAPER_CHANGED",
    //壁纸发生变化
    "android.intent.action.HEADSET_PLUG",
    //插入耳机
    "android.intent.action.MEDIA_UNMOUNTED",
    //卸载外部介质
    "android.intent.action.MEDIA_MOUNTED",
    //挂载外部介质
    "android.os.action.POWER_SAVE_MODE_CHANGED",
  ];
}
