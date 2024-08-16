import 'dart:convert';
import 'dart:io';

import 'package:flutter_mobile_command_tools/model/command_result_model.dart';
import 'package:flutter_mobile_command_tools/utils/FileUtils.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../notifier/log_change_notifier.dart';

abstract class BaseCommand {
  ///检测命令路径
  bool checkCommandPath(String executable) {
    if (executable.isNotEmpty) {
      if (!FileUtils.isExistFile(executable)) {
        return false;
      }
    }
    return true;
  }

  ///处理参数
  List<String> checkArguments(List<String> arguments) {
    return arguments;
  }

  CommandResultModel parseData(String command, ProcessResult processResult);

  ///异步执行命令
  Future<CommandResultModel> runCommand(String command,
      {String executable = "",
      String? workingDirectory,
      bool runInShell = false}) async {
    if (checkCommandPath(executable)) {
      List<String> arguments = command.split(" ");
      arguments = checkArguments(arguments);

      Provider.of<LogChangeNotifier>(Global.navigatorKey.currentContext!,
              listen: false)
          .addLog("${executable} ${arguments.join(" ")}");

      ProcessResult processResult = await Process.run(executable, arguments,
          workingDirectory: workingDirectory,
          runInShell: runInShell,
          stdoutEncoding: Encoding.getByName("utf-8"));
      CommandResultModel commandResultModel = parseData(command, processResult);
      if (commandResultModel.isSuccess) {
        Provider.of<LogChangeNotifier>(Global.navigatorKey.currentContext!,
                listen: false)
            .addLog(commandResultModel.data);
      } else {
        Provider.of<LogChangeNotifier>(Global.navigatorKey.currentContext!,
                listen: false)
            .addLog("错误信息：${commandResultModel.data}");
      }
      return commandResultModel;
    } else {
      throw "命令路径不存在";
    }
  }

  ///同步执行命令
  CommandResultModel runCommandSync(String command,
      {String executable = "", String? workingDirectory}) {
    if (checkCommandPath(executable)) {
      List<String> arguments = command.split(" ");
      arguments = checkArguments(arguments);

      Provider.of<LogChangeNotifier>(Global.navigatorKey.currentContext!,
              listen: false)
          .addLog("${executable} ${arguments.join(" ")}");

      ProcessResult processResult = Process.runSync(executable, arguments,
          workingDirectory: workingDirectory,
          stdoutEncoding: Encoding.getByName("utf-8"));
      CommandResultModel commandResultModel = parseData(command, processResult);
      if (commandResultModel.isSuccess) {
        Provider.of<LogChangeNotifier>(Global.navigatorKey.currentContext!,
                listen: false)
            .addLog(commandResultModel.data);
      } else {
        Provider.of<LogChangeNotifier>(Global.navigatorKey.currentContext!,
                listen: false)
            .addLog("错误信息：${commandResultModel.data}");
      }
      return commandResultModel;
    } else {
      throw "命令路径不存在";
    }
  }
}
