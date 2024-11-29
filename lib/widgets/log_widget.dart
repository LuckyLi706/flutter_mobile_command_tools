import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/notifier/log_change_notifier.dart';
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
            Row(
              children: [
                Text('日志信息'),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text("清除日志"),
                      onPressed: () {
                        context.read<LogChangeNotifier>().clearLog();
                      },
                    )
                  ],
                ))
              ],
            ),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(10),
              child: Scrollbar(
                  controller:
                      context.read<LogChangeNotifier>().scrollController,
                  child: ListView.builder(
                    controller:
                        context.read<LogChangeNotifier>().scrollController,
                    itemBuilder: (context, index) {
                      return _logItemWidget(
                          context.watch<LogChangeNotifier>().logList[index]);
                    },
                    itemCount:
                        context.watch<LogChangeNotifier>().logList.length,
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
