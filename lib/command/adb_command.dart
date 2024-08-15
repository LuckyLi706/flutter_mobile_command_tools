import 'dart:io';

import 'package:flutter_mobile_command_tools/base/base_command.dart';
import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/global.dart';
import 'package:flutter_mobile_command_tools/model/CommandResult.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';

class AdbCommand extends BaseCommand {
  CommandResult dealWithData(String arguments, ProcessResult processResult) {
    if (processResult.stderr != "") {
      if (processResult.stderr
          .toString()
          .contains("more than one device/emulator")) {
        return getProcessResult(true, "当前设备大于等于两个,请先手动获取设备");
      }
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
              if (!element.contains("offline") &&
                  !element.contains("unauthorized")) {
                currentDevices.add(element.split("\t")[0]);
              } else {
                currentDevices.add(element);
              }
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
              values[i].contains("mResumedActivity") ||
              values[i].contains("mCurrentFocus")) {
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
      case Constants.ADB_GET_FREEZE_PACKAGE:
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
      case Constants.ADB_APK_PATH:
        return getProcessResult(
            false,
            data
                .replaceAll("package:", "")
                .replaceAll(PlatformUtils.getLineBreak(), ""));
      case Constants.AAPT_GET_APK_INFO:
        String value = "";
        List<String> line =
            data.replaceAll("\'", "").split(PlatformUtils.getLineBreak());
        for (int i = 0; i < line.length; i++) {
          //package: name='me.weishu.exp' versionCode='341' versionName='鏄嗕粦闀溌?.4.1' platformBuildVersionName='鏄嗕粦闀溌?.4.1' compileSdkVersion='28' compileSdkVersionCodename='9'
          //如果想不存在乱码，先重定向到txt里面去。
          if (line[i].startsWith("package")) {
            List<String> apkInfo = line[i].substring(8).split(' ');
            value = value + "packageName：${apkInfo[1].substring(5)}\n";
            value = value + "versionCode：${apkInfo[2].split('=')[1]}\n";
            value = value + "versionName：${apkInfo[3].split('=')[1]}\n";
            continue;
          } else if (line[i].startsWith("application-label:")) {
            value = value + "appName：${line[i].split(':')[1]}\n";
            continue;
          } else if (line[i].startsWith("launchable-activity")) {
            value = value +
                "launchActivity：${line[i].substring(20).split(' ')[1].split('=')[1]}\n";
            continue;
          }
        }
        return getProcessResult(false, value);
      case Constants.ADB_GET_PACKAGE_INFO_MAIN_ACTIVITY:
        List<String> line =
            data.replaceAll("\'", "").split(PlatformUtils.getLineBreak());
        int index = line.indexOf("      android.intent.action.MAIN:");
        String value = line[index + 1].trim().split(" ")[1];
        return getProcessResult(false, value);
    }
    return getProcessResult(false, data);
  }

  ///检测adb的路径
  @override
  bool checkCommandPath() {
    if (Global.adbPath == "") {
      return false;
    }
    return true;
  }

  @override
  List<String> checkArguments(List<String> arguments) {
    if (Constants.currentDevice.isNotEmpty) {
      if (arguments[0] != Constants.ADB_CONNECT_DEVICES &&
          arguments[0] != Constants.ADB_WIRELESS_DISCONNECT &&
          arguments[0] != Constants.ADB_WIRELESS_CONNECT &&
          arguments[0] != Constants.ADB_VERSION) {
        arguments = ["-s", Constants.currentDevice]..addAll(arguments);
      }
    }
    return arguments;
  }
}

CommandResult getProcessResult(bool error, dynamic result) {
  CommandResult commandResult = CommandResult();
  commandResult.mError = error;
  commandResult.mResult = result;
  return commandResult;
}
