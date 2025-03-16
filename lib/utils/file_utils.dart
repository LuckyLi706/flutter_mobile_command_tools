import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_mobile_command_tools/enum/file_name_type.dart';
import 'package:flutter_mobile_command_tools/enum/sim_operation_type.dart';
import 'package:flutter_mobile_command_tools/model/sim_operation_model.dart';
import 'package:flutter_mobile_command_tools/utils/number_utils.dart';
import 'package:flutter_mobile_command_tools/utils/platform_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../enum/dir_type.dart';

class FileUtils {
  static Future<String?> localPath(
      {DirType dirType = DirType.CURRENT_DIR}) async {
    Directory? _path;
    switch (dirType) {
      case DirType.CURRENT_DIR:
        _path = Directory.current;
        break;
      case DirType.DOWNLOAD_DIR:
        _path = await getDownloadsDirectory();
        break;
      case DirType.DOCUMENT_DIR:
        _path = await getApplicationDocumentsDirectory();
        break;
      default:
        _path = await getTemporaryDirectory();
        break;
    }
    return _path?.path;
  }

  /// 获取目录基地址
  static Future<String> getBasePath() async {
    String? path = await localPath(dirType: DirType.DOCUMENT_DIR);
    if (path != null) {
      path = path + PlatformUtils.getPathSeparator() + Constants.APP_NAME;
      bool isExist = await isExistFolder(path);
      if (!isExist) {
        await Directory(path).create();
      }
      return path;
    }
    return "";
  }

  //获取tools目录
  static Future<String> getToolPath() async {
    String toolDirectory = await getBasePath() +
        PlatformUtils.getPathSeparator() +
        Constants.TOOLS_DIRECTORY_NAME;
    if (!await isExistFolder(toolDirectory)) {
      await Directory(toolDirectory).create();
    }
    return toolDirectory;
  }

  /// 获取config目录
  static Future<String> getConfigPath() async {
    String configDirectory = await getBasePath() +
        PlatformUtils.getPathSeparator() +
        Constants.CONFIG_DIRECTORY_NAME;
    if (!await isExistFolder(configDirectory)) {
      await Directory(configDirectory).create();
    }
    return configDirectory;
  }

  static Future<String> getScriptPath() async {
    String configDirectory = await getBasePath() +
        PlatformUtils.getPathSeparator() +
        Constants.SCRIPT_DIRECTORY_NAME;
    if (!await isExistFolder(configDirectory)) {
      await Directory(configDirectory).create();
    }
    return configDirectory;
  }

  /// 获取config目录里面的文件
  static Future<String> getConfigFileByName(FileNameType fileNameType) async {
    String configFileName = await getConfigPath() +
        PlatformUtils.getPathSeparator() +
        fileNameType.value;
    if (!await isExistFile(configFileName)) {
      createFile(configFileName);
    }
    return configFileName;
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
    List<String> strList = [];
    String content = await readFile(File(filePath));
    if (content.isEmpty) {
      return strList;
    } else {
      strList = content.split(PlatformUtils.getLineBreak());
      return strList;
    }
  }

  static String getDirName(String dirPath) {
    return dirPath.split(PlatformUtils.getPathSeparator()).last;
  }

  static Future<File> writeFile(String data, String filePath) async {
    return File(filePath).writeAsString(data);
  }

  static Future<File> writeBytesFile(ByteData data, File file) async {
    return file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  /**
   * 将模拟操作内容写入文件
   */
  static Future<File> writeSimOperationFile(
      SimOperationModel simOperationModel, String? fileName) async {
    List<String> simOperationContents = [];
    if (fileName == null || fileName.isEmpty) {
      DateTime now = DateTime.now();
      DateFormat formatter = DateFormat('yyyy-MM-dd_HH-mm');
      fileName = formatter.format(now);
    }
    String filePath =
        await getScriptPath() + PlatformUtils.getPathSeparator() + fileName;
    simOperationModel.isSingle
        ? simOperationContents.add('1')
        : simOperationContents.add('0');
    simOperationModel.simOperationList.forEach((simOperation) {
      if (simOperation.simOperationType == SimOperationType.SWIPE) {
        simOperationContents.add(
            "${simOperation.simOperationType.index},${simOperation.swipeType.index} ${simOperation.x1} ${simOperation.y1} ${simOperation.x2} ${simOperation.y2} ${simOperation.aliasName}");
      } else if (simOperation.simOperationType == SimOperationType.TAP) {
        simOperationContents.add(
            "${simOperation.simOperationType.index} ${simOperation.x1} ${simOperation.y1} ${simOperation.aliasName}");
      } else {
        simOperationContents.add(
            "${simOperation.simOperationType.index} ${simOperation.text} ${simOperation.aliasName}");
      }
    });
    return writeFile(
        simOperationContents.join(PlatformUtils.getLineBreak()), filePath);
  }

  /**
   * 读取所有模拟指令的文件
   */
  static Future<Map<String, SimOperationModel>> readSimOperationFile() async {
    String scriptFolderPath = await getScriptPath();
    Directory directory = new Directory(scriptFolderPath);
    if (directory.listSync().isNotEmpty) {
      List<FileSystemEntity> fileSystem = await directory.listSync();
      Map<String, SimOperationModel> simOperationModelMap = {};
      for (var fileSystemEntity in fileSystem) {
        String filePath = fileSystemEntity.path;
        List<String> contentList = await readFileByLine(filePath);
        SimOperationModel simOperationModel = new SimOperationModel();
        List<SimOperation> simOperationList = [];
        contentList[0] == '1'
            ? simOperationModel.isSingle = true
            : simOperationModel.isSingle = false;
        for (int i = 1; i < contentList.length; i++) {
          SimOperation simOperation = new SimOperation();
          String content = contentList[i];
          List<String> contentSplit = content.split(' ');

          /// 滑动指令
          if (contentSplit.length == 6) {
            if (contentSplit[0].contains(',')) {
              simOperation.simOperationType = SimOperationType.SWIPE;
              simOperation.swipeType = SwipeType.values[
                  NumberUtils.safeStrToInt(contentSplit[0].split(',')[1])];
              simOperation.x1 = NumberUtils.safeStrToInt(contentSplit[1]);
              simOperation.y1 = NumberUtils.safeStrToInt(contentSplit[2]);
              simOperation.x2 = NumberUtils.safeStrToInt(contentSplit[3]);
              simOperation.y2 = NumberUtils.safeStrToInt(contentSplit[4]);
              simOperation.aliasName = contentSplit[5];
              simOperationList.add(simOperation);
            } else {
              simOperation.simOperationType = SimOperationType.SWIPE;
              simOperation.swipeType =
                  SwipeType.values[NumberUtils.safeStrToInt(contentSplit[0])];
              simOperation.x1 = NumberUtils.safeStrToInt(contentSplit[1]);
              simOperation.y2 = NumberUtils.safeStrToInt(contentSplit[2]);
              simOperation.x2 = NumberUtils.safeStrToInt(contentSplit[3]);
              simOperation.y2 = NumberUtils.safeStrToInt(contentSplit[4]);
              simOperation.aliasName = contentSplit[5];
              simOperationList.add(simOperation);
            }
          } else if (contentSplit.length == 4) {
            simOperation.simOperationType = SimOperationType.TAP;
            simOperation.x1 = NumberUtils.safeStrToInt(contentSplit[1]);
            simOperation.y2 = NumberUtils.safeStrToInt(contentSplit[2]);
            simOperation.aliasName = contentSplit[3];
            simOperationList.add(simOperation);
          } else if (contentSplit.length == 3) {
            simOperation.simOperationType ==
                SimOperationType
                    .values[NumberUtils.safeStrToInt(contentSplit[0])];
            simOperation.text = contentSplit[1];
            simOperation.aliasName = contentSplit[2];
          } else {}
        }
        simOperationModel.simOperationList = simOperationList;
        simOperationModelMap[getDirName(filePath)] = simOperationModel;
      }
      return simOperationModelMap;
    } else {
      return {};
    }
  }

  static Future<File> writeSetting(Map map) async {
    String data = jsonEncode(map);
    return writeFile(data, (await localFile("SETTING")).path);
  }

  static bool isExistFile(String filePath) {
    File file = new File(filePath);
    return file.existsSync();
  }

  static Future<bool> isExistFolder(String folderPath) async {
    Directory folder = new Directory(folderPath);
    return await folder.exists();
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
        Directory(storageDir + "/" + file.name)..create(recursive: true);
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
        PlatformUtils.getPathSeparator() +
        Constants.TOOLS_DIRECTORY_NAME);
    if (!await directoryAdb.exists()) {
      return "";
    }
    return directoryAdb.path + PlatformUtils.getPathSeparator() + adbName;
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
        PlatformUtils.getPathSeparator() +
        Constants.TOOLS_DIRECTORY_NAME);
    if (!await directoryAdb.exists()) {
      return "";
    }
    return directoryAdb.path + PlatformUtils.getPathSeparator() + adbName;
  }

  static Future<String> getApkToolPath() async {
    Directory directoryAdb = Directory('${await getBasePath()}' +
        PlatformUtils.getPathSeparator() +
        Constants.TOOLS_DIRECTORY_NAME +
        PlatformUtils.getPathSeparator() +
        Constants.APK_TOOL_NAME);
    // if (!await directoryAdb.exists()) {
    //   return "";
    // }
    return directoryAdb.path + PlatformUtils.getPathSeparator() + "apktool.jar";
  }

  static Future<String> getFakerAndroidPath() async {
    Directory directoryAdb = Directory('${await getBasePath()}' +
        PlatformUtils.getPathSeparator() +
        Constants.TOOLS_DIRECTORY_NAME +
        PlatformUtils.getPathSeparator() +
        Constants.APK_TOOL_NAME);
    return directoryAdb.path +
        PlatformUtils.getPathSeparator() +
        "FakerAndroid.jar";
  }

  static Future<String> getUIToolsPath() async {
    Directory directoryAdb = Directory('${await getBasePath()}' +
        PlatformUtils.getPathSeparator() +
        Constants.TOOLS_DIRECTORY_NAME +
        PlatformUtils.getPathSeparator() +
        Constants.UI_TOOL_NAME);
    return directoryAdb.path;
  }

  static Future<String> getAaptToolsPath() async {
    String aaptName = "aapt";
    if (Platform.isWindows) {
      aaptName = "aapt.exe";
    } else {
      aaptName = "aapt";
    }
    Directory directoryAdb = Directory('${await getBasePath()}' +
        PlatformUtils.getPathSeparator() +
        Constants.TOOLS_DIRECTORY_NAME);
    return directoryAdb.path + PlatformUtils.getPathSeparator() + aaptName;
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

  static Future<String> getMutualAppPath(String name) async {
    String path =
        await getConfigPath() + PlatformUtils.getPathSeparator() + name;
    createFile(path);
    return path;
  }
}
