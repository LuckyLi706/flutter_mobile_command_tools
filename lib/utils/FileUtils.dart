import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';
import 'package:path_provider/path_provider.dart';

import '../constants.dart';

class FileUtils {
  static const String CURRENT_DIR = "0";
  static const String DOWNLOAD_DIR = "1";
  static const String TEMP_DIR = "2";
  static const String DOCUMENT_DIR = "3";

  static Future<String?> localPath({String dir = CURRENT_DIR}) async {
    Directory? _path;
    switch (dir) {
      case CURRENT_DIR:
        _path = Directory.current;
        break;
      case DOWNLOAD_DIR:
        _path = await getDownloadsDirectory();
        break;
      case DOCUMENT_DIR:
        _path = await getApplicationDocumentsDirectory();
        break;
      default:
        _path = await getTemporaryDirectory();
        break;
    }
    return _path?.path;
  }

  static Future<File> localFile(String file, {String subDir = ""}) async {
    String path = await getBasePath();
    if (subDir.isNotEmpty) {
      if (path != "/") {
        path = path + "/" + subDir;
      } else {
        path = path + subDir;
      }
      bool isExist = await isExistFolder(path);
      if (!isExist) {
        Directory(path).create();
      }
    }
    return File('$path/' + file);
  }

  //获取目录基地址
  static Future<String> getBasePath() async {
    String? path = await localPath(dir: DOCUMENT_DIR);
    if (path != null) {
      path = path + PlatformUtils.getSeparator() + Constants.APP_NAME;
      bool isExist = await isExistFolder(path);
      if (!isExist) {
        Directory(path).create();
      }
      return path;
    }
    return "";
  }

  //获取tools目录
  static Future<String> getToolPath() async {
    String toolDirectory = await getBasePath() +
        PlatformUtils.getSeparator() +
        Constants.TOOLS_DIRECTORY_NAME;
    if (!await isExistFolder(toolDirectory)) {
      Directory(toolDirectory).create();
    }
    return toolDirectory;
  }

  static Future<String> getConfigPath() async {
    String configDirectory = await getBasePath() +
        PlatformUtils.getSeparator() +
        Constants.CONFIG_DIRECTORY_NAME;
    if (!await isExistFolder(configDirectory)) {
      Directory(configDirectory).create();
    }
    return configDirectory;
  }

  static Future<String> readSetting() async {
    return readFile(await localFile("SETTING"));
  }

  static Future<String> readFile(File file) async {
    try {
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "";
    }
  }

  static Future<List<String>> readFileByLine(String filePath) async {
    List<String> strList = new List.empty();
    String content = await readFile(File(filePath));
    if (content.isEmpty) {
      return strList;
    } else {
      strList = content.split(PlatformUtils.getLineBreak());
      return strList;
    }
  }

  static Future<File> writeFile(String data, File file) async {
    return file.writeAsString(data);
  }

  static Future<File> writeBytesFile(ByteData data, File file) async {
    return file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static Future<File> writeSetting(Map map) async {
    String data = jsonEncode(map);
    return writeFile(data, await localFile("SETTING"));
  }

  static Future<bool> isExistFile(String filePath) async {
    File file = new File(filePath);
    return await file.exists();
    //return isExist;
  }

  static Future<bool> isExistFolder(String folderPath) async {
    Directory folder = new Directory(folderPath);
    return await folder.exists();
    //return isExist;
  }

  static void deleteFile(String filePath) async {
    if (await isExistFile(filePath)) {
      File(filePath).delete();
    }
  }

  static void createFile(String filePath) async {
    if (!await isExistFile(filePath)) {
      File(filePath).create();
    }
  }

  /// @storageDir 存储的目录
  /// @zipFilePath 解压的文件路径
  static unZipFiles(String storageDir, String zipFilePath) async {
    print("压缩文件路径zipFilePath = $zipFilePath");
    // 从磁盘读取Zip文件。
    List<int> bytes = File(zipFilePath).readAsBytesSync();
    // 解码Zip文件
    Archive archive = ZipDecoder().decodeBytes(bytes);
    // 将Zip存档的内容解压缩到磁盘。
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        List<int> tempData = file.content;
        File f = File(storageDir + "/" + file.name)
          ..createSync(recursive: true)
          ..writeAsBytesSync(tempData);

        if (Platform.isLinux || Platform.isMacOS) {
          //Linux or MacOS need run permission
          Process.runSync("chmod", ["+x", f.path], runInShell: true);
        }
        print("解压后的文件路径 = ${f.path}");
      } else {
        Directory(storageDir + "/" + file.name)
          ..create(recursive: true);
      }
    }
    deleteFile(zipFilePath);
  }

  //获取内部adb路径
  static Future<String> getInnerAdbPath() async {
    String adbName = "adb";
    if (Platform.isWindows) {
      adbName = "adb.exe";
    } else {
      adbName = "adb";
    }
    Directory directoryAdb = Directory('${await getBasePath()}' +
        PlatformUtils.getSeparator() +
        Constants.TOOLS_DIRECTORY_NAME);
    if (!await directoryAdb.exists()) {
      return "";
    }
    return directoryAdb.path + PlatformUtils.getSeparator() + adbName;
  }

  //获取内部fastboot路径
  static Future<String> getInnerFastBootPath() async {
    String adbName = "fastboot";
    if (Platform.isWindows) {
      adbName = "fastboot.exe";
    } else {
      adbName = "fastboot";
    }
    Directory directoryAdb = Directory('${await getBasePath()}' +
        PlatformUtils.getSeparator() +
        Constants.TOOLS_DIRECTORY_NAME);
    if (!await directoryAdb.exists()) {
      return "";
    }
    return directoryAdb.path + PlatformUtils.getSeparator() + adbName;
  }

  static Future<String> getApkToolPath() async {
    Directory directoryAdb = Directory('${await getBasePath()}' +
        PlatformUtils.getSeparator() +
        Constants.TOOLS_DIRECTORY_NAME +
        PlatformUtils.getSeparator() +
        Constants.APK_TOOL_NAME);
    if (!await directoryAdb.exists()) {
      return "";
    }
    return directoryAdb.path + PlatformUtils.getSeparator() + "apktool.jar";
  }

  static Future<String> getFakerAndroidPath() async {
    Directory directoryAdb = Directory('${await getBasePath()}' +
        PlatformUtils.getSeparator() +
        Constants.TOOLS_DIRECTORY_NAME +
        PlatformUtils.getSeparator() +
        Constants.APK_TOOL_NAME);
    if (!await directoryAdb.exists()) {
      return "";
    }
    return directoryAdb.path +
        PlatformUtils.getSeparator() +
        "FakerAndroid.jar";
  }

  static Future<String> getUIToolsPath() async {
    Directory directoryAdb = Directory('${await getBasePath()}' +
        PlatformUtils.getSeparator() +
        Constants.TOOLS_DIRECTORY_NAME +
        PlatformUtils.getSeparator() +
        Constants.UI_TOOL_NAME);
    if (!await directoryAdb.exists()) {
      return "";
    }
    return directoryAdb.path;
  }

  static Future<String> getMutualAppPath(String name) async {
    String path= await getConfigPath()+
        PlatformUtils.getSeparator() +
        name;
    createFile(path);
    return path;
  }
}
