import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';
import 'package:path_provider/path_provider.dart';

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
    String? path =
        Platform.isMacOS ? await localPath(dir: TEMP_DIR) : await localPath();
    if (path != null) {
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
    }
    return File('$path/' + file);
  }

  static Future<String> readSetting() async {
    return readFile(File("SETTING"));
  }

  static Future<String> readFile(File file) async {
    try {
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "";
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
        print("解压后的文件路径 = ${f.path}");
      } else {
        Directory(storageDir + "/" + file.name)..create(recursive: true);
      }
    }
    print("解压成功");
  }

  //获取内部adb路径
  static Future<String> getInnerAdbPath() async {
    String adbName = "adb";
    if (Platform.isWindows) {
      adbName = "adb.exe";
    }
    Directory directoryAdb = Directory(
        '${await FileUtils.localPath(dir: FileUtils.DOCUMENT_DIR)}' +
            PlatformUtils.getSeparator() +
            "adb");
    if (!await directoryAdb.exists()) {
      return "";
    }
    return directoryAdb.path + PlatformUtils.getSeparator() + adbName;
  }
}
