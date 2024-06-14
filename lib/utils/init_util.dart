import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mobile_command_tools/global.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';

import '../constants.dart';
import 'FileUtils.dart';

class InitUtil {
  static Future init(Map<String, dynamic> map) async {
    await _initSetting(map);
    _initDesktopPath();
    _initApkSigner();
    _initInnerAdb();
    _initMutualAppFile();
  }

  //获取桌面路径
  static void _initDesktopPath() async {
    if (Platform.isWindows) {
      Process.run(r"echo %USERPROFILE%", [], runInShell: true)
          .then((value) async {
        if (value.stdout != "") {
          Global.userPath =
              value.stdout.toString().split(PlatformUtils.getLineBreak())[0];
          Global.desktopPath = Constants.userPath + r"\Desktop";
          if (!await FileUtils.isExistFolder(Global.userPath)) {
            Global.desktopPath = Directory.current.path;
          }
          _initAdbPath();
        } else {
          Global.desktopPath = Directory.current.path;
        }
      });
    } else if (Platform.isMacOS) {
      Process.run(r"id", ["-un"], runInShell: true).then((value) async {
        if (value.stdout != "") {
          Global.userPath = "/Users/" +
              value.stdout.toString().split(PlatformUtils.getLineBreak())[0];
          Global.desktopPath = Global.userPath + r"/Desktop";
          if (!await FileUtils.isExistFolder(Global.userPath)) {
            String? path = await FileUtils.localPath(dir: FileUtils.TEMP_DIR);
            Global.desktopPath = path == null ? "" : path;
          }
          _initAdbPath();
        } else {
          Global.desktopPath = Directory.current.path;
        }
      });
    } else if (Platform.isLinux) {
      Process.run(r"id", ["-un"], runInShell: true).then((value) async {
        if (value.stdout != "") {
          Global.userPath = "/home/" +
              value.stdout.toString().split(PlatformUtils.getLineBreak())[0];
          Global.desktopPath = Global.userPath + r"/Desktop";
          if (!await FileUtils.isExistFolder(Constants.userPath)) {
            Global.desktopPath = Directory.current.path;
          }
          _initAdbPath();
        } else {
          Global.desktopPath = Directory.current.path;
        }
      });
    }
  }

  //获取系统默认的adb目录
  static void _initAdbPath() {
    if (Global.adbPath.isNotEmpty) {
      return;
    }
    if (Platform.isWindows) {
      Global.adbPath = Constants.outerAdbPath = Global.userPath +
          r"\AppData\Local\Android\sdk\platform-tools\adb.exe";
    } else if (Platform.isMacOS) {
      Global.adbPath = Constants.outerAdbPath =
          Global.userPath + r"/Library/Android/sdk/platform-tools/adb";
    } else if (Platform.isLinux) {
      Global.adbPath = Constants.outerAdbPath =
          Global.userPath + r"/Android/Sdk/platform-tools/adb";
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
    File versionFile = File(await FileUtils.getBasePath() +
        PlatformUtils.getSeparator() +
        "VERSION");
    String versionStr = await FileUtils.readFile(versionFile);

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
    if (!await directoryAdb.exists() || versionStr != Constants.APP_VERSION) {
      var buffer = await rootBundle.load(assetsAdbPath);
      await FileUtils.writeBytesFile(buffer, File(path));
      FileUtils.unZipFiles(directoryAdb.path, path);
    }
    FileUtils.writeFile(Constants.APP_VERSION, versionFile);
  }

  static void _initMutualAppFile() async {
    FileUtils.createFile(await FileUtils.getMutualAppPath("Activity"));
    FileUtils.createFile(await FileUtils.getMutualAppPath("Service"));
    if (!await FileUtils.isExistFile(
        await FileUtils.getMutualAppPath("BroadcastReceiver"))) {
      FileUtils.createFile(
          await FileUtils.getMutualAppPath("BroadcastReceiver"));
      String content = "";
      Constants.ANDROID_RECEIVER.forEach((element) {
        content = content + element + PlatformUtils.getLineBreak();
      });
      FileUtils.writeFile(
          content, File(await FileUtils.getMutualAppPath("BroadcastReceiver")));
    }
  }
}
