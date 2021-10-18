import 'dart:io';

import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/model/CommandResult.dart';
import 'package:flutter_mobile_command_tools/utils/FileUtils.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';

class AndroidCommand {
  Future<String> checkFirst(List<String> arguments,
      {String executable = "", String? workingDirectory}) async {
    if (arguments[0] != Constants.ADB_CONNECT_DEVICES &&
        arguments[0] != Constants.ADB_WIRELESS_CONNECT &&
        arguments[0] != Constants.ADB_VERSION &&
        Constants.currentDevice.isEmpty) {
      throw "请先获取设备";
    }
    if (Constants.adbPath == "") {
      throw "adb路径不能为空";
    }
    if (executable == "") {
      executable = Constants.adbPath;
    }
    if (!await FileUtils.isExistFile(executable)) {
      throw executable + "该路径不存在";
    }
    return executable;
  }

  Future<ProcessResult> execCommand(List<String> arguments,
      {String executable = "",
      String? workingDirectory,
      bool runInShell = false}) async {
    if (arguments[0] != Constants.ADB_CONNECT_DEVICES &&
        arguments[0] != Constants.ADB_WIRELESS_DISCONNECT &&
        arguments[0] != Constants.ADB_WIRELESS_CONNECT &&
        arguments[0] != Constants.ADB_VERSION) {
      arguments = ["-s", Constants.currentDevice]..addAll(arguments);
    }
    executable = await checkFirst(arguments,
        executable: executable, workingDirectory: workingDirectory);
    print(
        "executable:$executable,arguments:$arguments,workingDirectory:$workingDirectory");
    return await Process.run(executable, arguments,
        workingDirectory: workingDirectory, runInShell: runInShell);
  }

  Future<ProcessResult> execCommandSync(List<String> arguments,
      {String executable = "", String? workingDirectory}) async {
    if (arguments[0] != Constants.ADB_CONNECT_DEVICES) {
      arguments = ["-s", Constants.currentDevice]..addAll(arguments);
    }
    executable = await checkFirst(arguments,
        executable: executable, workingDirectory: workingDirectory);
    return Process.runSync(executable, arguments,
        workingDirectory: workingDirectory);
  }

  CommandResult dealWithData(String arguments, ProcessResult processResult) {
    if (processResult.stderr != "") {
      return getProcessResult(true, processResult.stderr);
    }
    String data = processResult.stdout;
    switch (arguments) {
      case Constants.ADB_CONNECT_DEVICES:
        if (data.contains("List of devices attached")) {
          List<String> devices = data.split(PlatformUtils.getLineBreak());
          List<String> currentDevices = [];
          devices.forEach((element) {
            if (element.isNotEmpty && element != "List of devices attached") {
              currentDevices.add(element.split("\t")[0]);
            }
          });
          if (currentDevices.length > 0) {
            return getProcessResult(false, currentDevices);
          } else {
            return getProcessResult(true, "无设备连接");
          }
        } else {
          return getProcessResult(true, data);
        }
      case Constants.ADB_GET_PACKAGE:
        List<String> values = data.split('\n');
        for (int i = 0; i < values.length; i++) {
          //处理9.0版本手机顶级activity信息过滤改为mResumedActivity
          if (values[i].contains("mFocusedActivity") ||
              values[i].contains("mResumedActivity")) {
            int a = values[i].indexOf("u0");
            int b = values[i].indexOf('/');
            String packageName = values[i].substring(a + 3, b);
            return getProcessResult(false, packageName);
          }
          if (values[i].contains("error:")) {
            return getProcessResult(true, values[i]);
          }
        }
        return getProcessResult(true, "无信息");
      case Constants.ADB_GET_THIRD_PACKAGE:
      case Constants.ADB_GET_SYSTEM_PACKAGE:
        List<String> packageNameList = data.split(PlatformUtils.getLineBreak());
        List<String> packageNameFilter = [];
        packageNameList.forEach((element) {
          if (element.isNotEmpty) {
            packageNameFilter.add(element.replaceAll("package:", ""));
          }
        });
        return getProcessResult(false, packageNameFilter);
      case Constants.ADB_CURRENT_ACTIVITY:
        List<String> values = data.split('\n');
        for (int i = 0; i < values.length; i++) {
          //处理9.0版本手机顶级activity信息过滤改为mResumedActivity
          if (values[i].contains("mFocusedActivity") ||
              values[i].contains("mResumedActivity")) {
            List<String> listActivity = values[i].split(" ");
            return getProcessResult(
                false, listActivity[listActivity.length - 2].trim());
          }
          if (values[i].contains("error:")) {
            return getProcessResult(true, values[i]);
          }
        }
        break;
      case Constants.ADB_IP:
        String ip = data.split(":")[1].split(" ")[0];
        return getProcessResult(false, ip);
      case Constants.ADB_WIRELESS_CONNECT:
        if (data.contains("already") ||
            data.contains("failed") ||
            data.contains("cannot")) {
          //表示已经连接上了
          return getProcessResult(true, data);
        } else {
          return getProcessResult(
              false, data.replaceAll("connected to ", "").trim()); //移除换行符号
        }
      case Constants.ADB_WIRELESS_DISCONNECT:
        if (data.contains("error")) {
          return getProcessResult(true, data);
        }
        return getProcessResult(
            false, data.replaceAll("disconnected ", "").trim());
      case Constants.ADB_PULL_CRASH:
        if (data.isEmpty) {
          return getProcessResult(true, "无crash日志");
        } else {
          List<String> crashList = data.split(PlatformUtils.getLineBreak());
          List<String> times = [];
          crashList.forEach((element) {
            if (element.contains("data_app_crash")) {
              times.add(element.split("data_app_crash")[0].trim());
            }
          });
          if (times.length > 0) {
            return getProcessResult(false, times);
          }
          return getProcessResult(true, "无app crash日志");
        }
      case Constants.ADB_SEARCH_ALL_FILE_PATH:
        if (data.isEmpty) {
          return getProcessResult(true, "该目录无文件或者当前就是文件");
        } else {
          if (data.contains("No such file or directory")) {
            return getProcessResult(true, data);
          }
          List<String> crashList = data.split(PlatformUtils.getLineBreak());
          List<String> times = [];
          crashList.forEach((element) {
            if (!element.startsWith("/") && element.isNotEmpty) {
              times.add(element.trim());
            }
          });
          if (times.length > 0) {
            return getProcessResult(false, times);
          }
          return getProcessResult(true, "该目录无文件或者当前就是文件");
        }
    }
    return getProcessResult(false, data);
  }

  CommandResult getProcessResult(bool error, dynamic result) {
    CommandResult commandResult = CommandResult();
    commandResult.mError = error;
    commandResult.mResult = result;
    return commandResult;
  }
}
