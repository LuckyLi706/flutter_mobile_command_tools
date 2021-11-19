// ignore_for_file: slash_for_doc_comments

import 'dart:io';

import 'package:flutter_mobile_command_tools/constants.dart';

class PlatformUtils {
  static String getLineBreak() {
    if (Platform.isWindows) {
      return "\r\n";
    } else {
      return "\n";
    }
  }

  ///windows和linux系统的命令行指令不一样
  ///使用run命令拿到的输出结果总是在运行完成了才全部输出
  static Future<ProcessResult> runCommand(String commandStr,
      {bool runInShell = true, String? workDirectory}) {
    commandStr = javaCommand(commandStr);
    if (Platform.isMacOS || Platform.isLinux) {
      String executable = commandStr.split(" ")[0];
      List<String> arguments =
          commandStr.replaceFirst(executable, "").trim().split(" ");
      return Process.run(executable, arguments,
          runInShell: runInShell, workingDirectory: workDirectory);
    } else {
      return Process.run(commandStr, [],
          runInShell: runInShell, workingDirectory: workDirectory);
    }
  }

  /// ProcessStartMode 可以设置开启进程模式，但是我测试没成功，没法重定向输出流到我的文本上面来
  /// 在命令行界面倒是可以实时输出，可以了，可以拿到输出流然后
  /**
   *
      var stream = value.stdout;
      stream.listen((event) {
      _showLog(utf8.decode(event));
      }
   */
  static Future<Process> startCommand(String commandStr,
      {bool runInShell = true,
      String? workDirectory,
      ProcessStartMode mode = ProcessStartMode.normal}) {
    commandStr = javaCommand(commandStr);
    print(commandStr);
    if (Platform.isMacOS || Platform.isLinux) {
      String executable = commandStr.split(" ")[0];
      List<String> arguments =
          commandStr.replaceFirst(executable, "").trim().split(" ");
      return Process.start(executable, arguments,
          runInShell: runInShell, workingDirectory: workDirectory, mode: mode);
    } else {
      return Process.start(commandStr, [],
          runInShell: runInShell, workingDirectory: workDirectory, mode: mode);
    }
  }

  static String javaCommand(String command) {
    if (!command.startsWith("java")) {
      return command;
    }
    if (Constants.javaPath.isNotEmpty) {
      return command.replaceFirst("java", Constants.javaPath);
    }
    return command;
  }

  static String getSeparator() {
    if (Platform.isWindows) {
      return r"\";
    }
    return r"/";
  }
}
