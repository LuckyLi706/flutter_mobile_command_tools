import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';

import '../constants.dart';
import 'FileUtils.dart';

class InitUtils {
  static void init() async {
    await _initSetting();
    _initDesktop();
    _initApkSigner();
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
      Process.run(r"id", ["-un"], runInShell: true).then((value) async{
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
    } else if (Platform.isLinux) {
      Constants.adbPath =
          Constants.userPath + r"/Android/Sdk/platform-tools/adb";
    }
    print(Constants.adbPath);
  }

  static _initSetting() async {
    String value = await FileUtils.readSetting();
    if (value.isNotEmpty) {
      Map<String, dynamic> map = jsonDecode(value);
      Constants.adbPath = map['adb'];
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
}
