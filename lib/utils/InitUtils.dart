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
    if (Constants.outerAdbPath.isNotEmpty) {
      return;
    }
    if (Platform.isWindows) {
      Constants.adbPath = Constants.outerAdbPath = Constants.userPath +
          r"\AppData\Local\Android\sdk\platform-tools\adb.exe";
    } else if (Platform.isMacOS) {
      Constants.adbPath = Constants.outerAdbPath =
          Constants.adbPath + r"/Library/Android/sdk/platform-tools/adb";
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
    Directory directoryAdb = Directory(
        '${await FileUtils.localPath(dir: FileUtils.DOCUMENT_DIR)}/adb');
    var path = directoryAdb.path + ".zip";
    if (!await directoryAdb.exists()) {
      var buffer = await rootBundle.load('assets/windows/adb.zip');
      await FileUtils.writeBytesFile(buffer, File(path));
    }
    FileUtils.unZipFiles(directoryAdb.path, path);
  }
}
