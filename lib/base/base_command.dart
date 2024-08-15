import 'dart:convert';
import 'dart:io';

abstract class BaseCommand {
  ///检测命令路径
  bool checkCommandPath() {
    return true;
  }

  ///处理参数
  List<String> checkArguments(List<String> arguments) {
    return arguments;
  }

  ///异步执行命令
  Future<ProcessResult> runCommand(List<String> arguments,
      {String executable = "",
      String? workingDirectory,
      bool runInShell = false}) async {
    if (checkCommandPath()) {
      arguments = checkArguments(arguments);

      return await Process.run(executable, arguments,
          workingDirectory: workingDirectory,
          runInShell: runInShell,
          stdoutEncoding: Encoding.getByName("utf-8"));
    } else {
      throw "命令路径不存在";
    }
  }

  ///同步执行命令
  ProcessResult runCommandSync(List<String> arguments,
      {String executable = "", String? workingDirectory}) {
    if (checkCommandPath()) {
      arguments = checkArguments(arguments);

      return Process.runSync(executable, arguments,
          workingDirectory: workingDirectory,
          stdoutEncoding: Encoding.getByName("utf-8"));
    } else {
      throw "命令路径不存在";
    }
  }
}
