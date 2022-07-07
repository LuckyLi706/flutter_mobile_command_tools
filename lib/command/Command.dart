import 'dart:convert';
import 'dart:io';

import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/model/CommandResult.dart';
import 'package:flutter_mobile_command_tools/utils/FileUtils.dart';
import 'package:flutter_mobile_command_tools/utils/LogUtils.dart';
import 'package:flutter_mobile_command_tools/utils/PlatformUtils.dart';

class AndroidCommand {
  Future<List<String>> checkFirst(List<String> arguments,
      {String executable = "", String? workingDirectory}) async {
    if (Constants.adbPath == "") {
      throw "adb路径不能为空";
    }

    if (!await FileUtils.isExistFile(executable)) {
      throw executable + "该路径不存在";
    }

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

  Future<ProcessResult> execCommand(List<String> arguments,
      {String executable = "",
      String? workingDirectory,
      bool runInShell = true}) async {
    if (executable == "") {
      executable = Constants.adbPath;
    }
    arguments = await checkFirst(arguments,
        executable: executable, workingDirectory: workingDirectory);

    //对grep做处理,
    if (arguments.contains("grep") && !arguments.contains("dropbox")) {
      int index = arguments.indexOf("grep");
      arguments[index] = PlatformUtils.grepFindStr();
    }

    LogUtils.printLog(
        "executable:$executable,arguments:$arguments,workingDirectory:$workingDirectory");

    return await Process.run(executable, arguments,
        workingDirectory: workingDirectory,
        runInShell: runInShell,
        stdoutEncoding: Encoding.getByName("utf-8"));
  }

  Future<ProcessResult> execCommandSync(List<String> arguments,
      {String executable = "", String? workingDirectory}) async {
    if (executable == "") {
      executable = Constants.adbPath;
    }

    arguments = await checkFirst(arguments,
        executable: executable, workingDirectory: workingDirectory);

    LogUtils.printLog(
        "executable:$executable,arguments:$arguments,workingDirectory:$workingDirectory");

    //对grep做处理,
    if (arguments.contains("grep") && !arguments.contains("dropbox")) {
      int index = arguments.indexOf("grep");
      arguments[index] = PlatformUtils.grepFindStr();
    }

    return Process.runSync(executable, arguments,
        workingDirectory: workingDirectory,
        stdoutEncoding: Encoding.getByName("utf-8"));
  }

  CommandResult dealWithData(String arguments, ProcessResult processResult) {
    print(processResult.stdout);
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
              if (!element.contains("offline")) {
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
            value = value + "包名：${apkInfo[1].substring(5)}\n";
            value = value + "版本号：${apkInfo[2].split('=')[1]}\n";
            continue;
          } else if (line[i].startsWith("application-label:")) {
            value = value + "名字：${line[i].split(':')[1]}\n";
            continue;
          } else if (line[i].startsWith("launchable-activity")) {
            value = value +
                "启动类：${line[i].substring(20).split(' ')[1].split('=')[1]}\n";
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
}

class IOSCommand {
  Future<List<String>> checkFirst(
      List<String> arguments, String executable) async {
    if (Constants.currentIOSDevice.isNotEmpty) {
      if (Constants.IOS_GET_DEVICE != arguments[0] || arguments.length != 1) {
        arguments = ["-u", Constants.currentIOSDevice]..addAll(arguments);
      }
    }

    if (!await FileUtils.isExistFile(executable)) {
      throw executable + "该路径不存在";
    }
    return arguments;
  }

  Future<ProcessResult> execCommand(List<String> arguments,
      {String executable = "",
      String? workingDirectory,
      bool runInShell = false}) async {
    if (Platform.isWindows) {
      executable = executable + ".exe";
    }

    arguments = await checkFirst(arguments, executable);

    LogUtils.printLog(
        "executable:$executable,arguments:$arguments,workingDirectory:$workingDirectory");

    return await Process.run(executable, arguments,
        workingDirectory: workingDirectory,
        runInShell: runInShell,
        stdoutEncoding: Encoding.getByName("utf-8"));
  }

  Future<ProcessResult> execCommandSync(List<String> arguments,
      {String executable = "", String? workingDirectory}) async {
    if (Platform.isWindows) {
      executable = executable + ".exe";
    }

    arguments = await checkFirst(arguments, executable);

    LogUtils.printLog(
        "executable:$executable,arguments:$arguments,workingDirectory:$workingDirectory");

    return Process.runSync(executable, arguments,
        workingDirectory: workingDirectory,
        stdoutEncoding: Encoding.getByName("utf-8"));
  }

  CommandResult dealWithData(String arguments, ProcessResult processResult) {
    if (processResult.stderr != "") {
      return getProcessResult(true, processResult.stderr);
    }
    String data = processResult.stdout;
    switch (arguments) {
      case Constants.IOS_GET_DEVICE:
        List<String> devices = data.split(PlatformUtils.getLineBreak());
        List<String> currentDevices = [];
        devices.forEach((element) {
          if (element.isNotEmpty) {
            currentDevices.add(element.split("\t")[0]);
          }
        });
        if (currentDevices.length > 0) {
          return getProcessResult(false, currentDevices);
        } else {
          return getProcessResult(true, "无设备连接");
        }
      //包名获取形式
      // tv.danmaku.bilianime, "64800100", "Bilibili"
      // com.laiwang.DingTalk, "21728861", "DingTalk"
      case Constants.IOS_GET_THIRD_PACKAGE:
      case Constants.IOS_GET_SYSTEM_PACKAGE:
        List<String> packageNameList = data.split(PlatformUtils.getLineBreak());
        packageNameList.removeAt(0);
        List<String> packageNameFilter = [];
        Constants.mapIOSInfo.clear();
        packageNameList.forEach((element) {
          if (element.isNotEmpty) {
            List<String> iosInfo = element.split(",");
            if (!packageNameFilter.contains(iosInfo[0])) {
              packageNameFilter.add(iosInfo[0]);
              if (iosInfo.length >= 3) {
                Constants.mapIOSInfo[iosInfo[0]] =
                    "包名：${iosInfo[0]},版本号：${iosInfo[1]},名字：${iosInfo[2]}";
              } else {
                Constants.mapIOSInfo[iosInfo[0]] =
                    "包名：${iosInfo[0]},版本号：${iosInfo[1]}";
              }
            }
          }
        });
        return getProcessResult(false, packageNameFilter);
    }
    return getProcessResult(false, data);
  }
}

CommandResult getProcessResult(bool error, dynamic result) {
  CommandResult commandResult = CommandResult();
  commandResult.mError = error;
  commandResult.mResult = result;
  return commandResult;
}
