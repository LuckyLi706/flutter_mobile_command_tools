import 'package:flutter/cupertino.dart';
import 'package:flutter_mobile_command_tools/notifier/log_change_notifier.dart';
import 'package:flutter_mobile_command_tools/widgets/button_widget.dart';
import 'package:provider/provider.dart';

class DeviceCenterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ButtonWidget('获取设备', () {
          context.read<LogChangeNotifier>().addLog("Hello,World");
        })
      ],
    );
  }
}
