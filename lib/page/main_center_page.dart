import 'package:flutter/cupertino.dart';
import 'package:flutter_mobile_command_tools/command/adb_command.dart';
import 'package:flutter_mobile_command_tools/notifier/devices_notifier.dart';
import 'package:flutter_mobile_command_tools/notifier/log_change_notifier.dart';
import 'package:flutter_mobile_command_tools/widgets/button_widget.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class DeviceCenterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DevicesChangeNotifier(),
      builder: (context, child) {
        return Wrap(
          runAlignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 10,
          children: [
            Consumer(builder: (BuildContext context,
                DevicesChangeNotifier devices, Widget? child) {
              return Visibility(
                child: PullDownWidget(devices.deviceList, (index) {
                  devices.index = index;
                  Constants.currentDevice = devices.deviceList[index];
                }, devices.index),
                visible: !devices.isHidden,
              );
            }),
            ButtonWidget('获取设备', () {
              AdbCommand command = AdbCommand();
              command.runCommand(Constants.ADB_CONNECT_DEVICES).then((value) {
                if (value.data is List) {
                  if (value.data.length == 0) {
                    context.read<DevicesChangeNotifier>().isHidden = true;
                  }
                  context.read<DevicesChangeNotifier>().deviceList = value.data;
                  context.read<DevicesChangeNotifier>().isHidden = false;
                }
              });
            }),
            ButtonWidget('当前Activity', () {
              ///context.read<LogChangeNotifier>().addLog("Hello,World");

              AdbCommand command = AdbCommand();
              command.runCommand(Constants.ADB_CURRENT_ACTIVITY);
            }),
          ],
        );
      },
    );
  }
}
