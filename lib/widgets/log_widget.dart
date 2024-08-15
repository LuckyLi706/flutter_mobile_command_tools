import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/notifier/log_change_notifier.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

///日志信息输出
class LogWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('日志信息'),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: MacosScrollbar(
                  child: ListView.builder(
                primary: true,
                reverse: true,
                itemBuilder: (context, index) {
                  return _logItemWidget(
                      context.watch<LogChangeNotifier>().logList[index]);
                },
                itemCount: context.watch<LogChangeNotifier>().logList.length,
              )),
            ))
          ],
        ));
  }

  Widget _logItemWidget(String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(value),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
