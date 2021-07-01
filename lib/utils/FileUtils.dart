import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> get localPath async {
    try {
      final _path = await getTemporaryDirectory();
      return _path.path;
    } catch (e) {
      throw new Exception(e);
    }
  }

  static Future<File> _localFile(String file) async {
    final path = await localPath;
    return File('$path/' + file);
  }

  static Future<String> readSetting() async {
    try {
      final file = await _localFile("SETTING");
      String contents = file.readAsStringSync();
      return contents;
    } catch (e) {
      return "";
    }
  }

  static Future<File> writeSetting(Map map) async {
    final file = await _localFile("SETTING");
    String data = jsonEncode(map);
    return file.writeAsString(data);
  }

  static Future<bool> isExistFile(String filePath) async {
    File file = new File(filePath);
    return  await file.exists();
    //return isExist;
  }

  static Future<bool> isExistFolder(String folderPath) async {
    Directory folder = new Directory(folderPath);
    return  await folder.exists();
    //return isExist;
  }
}
