import 'dart:io';

import '../constants.dart';

class InitUtils {
  //获取桌面路径
  static void initDesktop() {
    if (Platform.isWindows) {
      Process.run(r"echo %USERPROFILE%\Desktop", [], runInShell: true)
          .then((value) => Constants.desktopPath = value.stdout.toString().split("\r\n")[0]);
    }
  }
}
