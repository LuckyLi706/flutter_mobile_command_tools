import 'dart:io';

import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/enum/adb_command_type.dart';
import 'package:flutter_mobile_command_tools/enum/click_type.dart';
import 'package:flutter_mobile_command_tools/model/sim_operation_model.dart';
import 'package:flutter_mobile_command_tools/utils/log_utils.dart';
import 'package:flutter_mobile_command_tools/utils/number_utils.dart';

import '../enum/sim_operation_type.dart';
import '../utils/notifier_utils.dart';
import '../utils/platform_utils.dart';

/**
 * @Classname android_sim_operation_mixin
 * @Date 2025/3/16 18:43
 * @Created by jacky
 * @Description 安卓页面的混入类
 */
mixin AndroidPanelMixin {
  onClick(AndroidPanelClickType clickType, {dynamic params}) {
    switch (clickType) {
      case AndroidPanelClickType.SIM_OPERATION_START:
        _startSimOperation(params);
        break;
      case AndroidPanelClickType.SIM_OPERATION_STOP:
        _stopSimOperation();
        break;
    }
  }

  _startSimOperation(SimOperationModel simOperationModel) {
    bool isRepeat = NotifierUtils.getAndroidPanelNotifier().isRepeat;
    String randomPeriod = NotifierUtils.getAndroidPanelNotifier().randomPeriod;

    ///间隔最小值
    int randomMin = NumberUtils.safeStrToInt(randomPeriod.split(',')[0]);

    ///间隔最大值
    int randomMax = NumberUtils.safeStrToInt(randomPeriod.split(',')[1]) == 0
        ? 1000
        : NumberUtils.safeStrToInt(randomPeriod.split(',')[1]);

    List<Future> futureList = [];
    List<int> randomTimeList = [];
    for (int i = 0; i < simOperationModel.simOperationList.length; i++) {
      int randomTime = 0;
      //2种情况不随机延迟
      //1、当前是单条指令并且不重复
      //2、未开启指令随机
      if (simOperationModel.isSingle && !isRepeat) {
        randomTime = 0;
      } else {
        if (i == 0) {
          randomTime = NumberUtils.getRandom(randomMin, randomMax);
          randomTimeList.add(NumberUtils.getRandom(randomMin, randomMax));
        } else {
          randomTime = NumberUtils.getRandom(randomMin, randomMax) +
              randomTimeList[i - 1];
          randomTimeList.add(NumberUtils.getRandom(randomMin, randomMax) +
              randomTimeList[i - 1]);
        }
      }
      futureList.add(Future.delayed(Duration(milliseconds: randomTime), () {
        if (i == 0) {
          LogUtils.showLog('延迟时间：' + randomTimeList[0].toString());
        } else {
          LogUtils.showLog(
              '延迟时间：' + "${randomTimeList[i] - randomTimeList[i - 1]}");
        }
        List<String> commandArguments = [];
        SimOperation simOperation = simOperationModel.simOperationList[i];
        switch (simOperation.simOperationType) {
          case SimOperationType.SWIPE:
            commandArguments =
                AdbCommandType.ADB_SIM_OPERATION_SWIPE.value.split(' ');
            commandArguments.add(simOperation.x1.toString());
            commandArguments.add(simOperation.y1.toString());
            commandArguments.add(simOperation.x2.toString());
            commandArguments.add(simOperation.y2.toString());

            break;
          case SimOperationType.TEXT:
            commandArguments =
                AdbCommandType.ADB_SIM_OPERATION_TEXT.value.split(' ');
            commandArguments.add(simOperation.text);
            break;
          case SimOperationType.TAP:
            commandArguments =
                AdbCommandType.ADB_SIM_OPERATION_TAP.value.split(' ');
            commandArguments.add(simOperation.x1.toString());
            commandArguments.add(simOperation.y1.toString());
            break;
          case SimOperationType.EVENT:
            commandArguments =
                AdbCommandType.ADB_SIM_OPERATION_EVENT.value.split(' ');
            commandArguments.add(simOperation.text);
            break;
          case SimOperationType.ADB:
          case SimOperationType.OTHER:
            commandArguments = simOperation.text.split(' ');
            break;
        }

        if (simOperation.simOperationType == SimOperationType.OTHER) {
          LogUtils.showLog("执行指令：arguments:$commandArguments");
          PlatformUtils.runCommand(commandArguments.join(' ')).then((value) {
            LogUtils.showLog("执行结束：" + value.stdout + value.stderr);
          }).catchError((e) {
            LogUtils.showLog("执行出错：");
          });
        } else {
          LogUtils.showLog(
              "执行指令：adb:${Constants.adbPath},arguments:$commandArguments");
          Process.run(Constants.adbPath, commandArguments).then((value) {
            LogUtils.showLog("执行结束：" + value.stdout + value.stderr);
          }).catchError((e) {
            LogUtils.showLog("执行出错：");
          });
        }
      }));
    }

    Future.wait(futureList).then((value) {
      if (isRepeat) {
        NotifierUtils.getAndroidPanelNotifier().isRunning = true;
        _startSimOperation(simOperationModel);
      } else {
        LogUtils.showLog("停止模拟指令");
      }
    });
  }

  _stopSimOperation() {
    NotifierUtils.getAndroidPanelNotifier().isRunning = false;
  }
}
