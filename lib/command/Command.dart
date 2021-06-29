import 'dart:io';

import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/model/CommandResult.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';

class AndroidCommand {
  Future<ProcessResult> execCommand(List<String> arguments,
      {String executable = "", String? workingDirectory}) async {
    if (arguments[0] != Constants.ADB_CONNECT_DEVICES &&
        Constants.currentDevice.isEmpty) {
      throw "请先获取设备";
    } else if (arguments[0] != Constants.ADB_CONNECT_DEVICES) {
      arguments = ["-s", Constants.currentDevice]..addAll(arguments);
      print(arguments);
    }
    if (executable == "") {
      return await Process.run(Constants.adbPath, arguments,
          workingDirectory: workingDirectory);
    } else {
      return await Process.run(executable, arguments,
          workingDirectory: workingDirectory);
    }
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
        }
        break;
      case Constants.ADB_GET_PACKAGE:
        List<String> values = data.split('\n');
        for (int i = 0; i < values.length; i++) {
          //处理9.0版本手机顶级activity信息过滤改为mResumedActivity
          if (values[i].contains("mFocusedActivity") ||
              values[i].contains("mResumedActivity")) {
            print(values[i]);
            int a = values[i].indexOf("u0");
            int b = values[i].indexOf('/');
            String packageName = values[i].substring(a + 3, b);
            print(packageName);
            return getProcessResult(false, packageName);
          }
          if (values[i].contains("error:")) {
            return getProcessResult(false, values[i]);
          }
        }
        break;
      case Constants.ADB_PULL_SCREEN_SHOT:
        return getProcessResult(false, data);
    }
    return getProcessResult(false, "");
  }

  CommandResult getProcessResult(bool error, dynamic result) {
    CommandResult commandResult = CommandResult();
    commandResult.mError = error;
    commandResult.mResult = result;
    return commandResult;
  }
}
