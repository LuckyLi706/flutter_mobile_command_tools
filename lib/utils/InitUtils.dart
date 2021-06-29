import 'dart:convert';
import 'dart:io';

import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';

import '../constants.dart';
import 'FileUtils.dart';

class InitUtils {
  //获取桌面路径
  static void initDesktop() async {
    await _initSetting();

    if (Platform.isWindows) {
      Process.run(r"echo %USERPROFILE%", [], runInShell: true).then((value) {
        if (value.stdout != "") {
          Constants.userPath =
              value.stdout.toString().split(PlatformUtils.getLineBreak())[0];
          Constants.desktopPath = Constants.userPath + r"/Desktop";
          _initAdbPath();
        } else {
          Constants.desktopPath = Directory.current.path;
        }
      });
    } else if (Platform.isMacOS) {
      Process.run(r"id", ["-un"], runInShell: true).then((value) {
        if (value.stdout != "") {
          Constants.userPath = "/Users/" +
              value.stdout.toString().split(PlatformUtils.getLineBreak())[0];
          Constants.desktopPath = Constants.userPath + r"/Desktop";
          _initAdbPath();
        } else {
          Constants.desktopPath = Directory.current.path;
        }
      });
    }
  }

  static void _initAdbPath() {
    if (Constants.adbPath.isNotEmpty) {
      return;
    }
    if (Platform.isWindows) {
      Constants.adbPath =
          Constants.userPath + r"\AppData\Local\Android\sdk\adb.exe";
    } else if (Platform.isMacOS) {
      Constants.adbPath =
          Constants.userPath + r"/Library/Android/sdk/platform-tools/adb";
    }
    print(Constants.adbPath);
  }

  static _initSetting() async {
    String value = await FileUtils.readSetting();
    Map<String, dynamic> map = jsonDecode(value);
    Constants.adbPath = map['adb'];
  }
}
