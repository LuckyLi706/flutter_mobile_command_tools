import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/notifier/dialog/android_sim_script_notifier.dart';
import 'package:provider/provider.dart';

class AndroidSimScriptDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AndroidSimScriptDialogState();
  }
}

class _AndroidSimScriptDialogState extends State<AndroidSimScriptDialog> {
  final simOperationList = ["swipe", "text", "tap", "event", "adb", "other"];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AndroidSimScriptNotifier>(
        create: (context) => AndroidSimScriptNotifier(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<AndroidSimScriptNotifier>(
                builder: (context, value, child) {
              return ComboBox<String>(
                  isExpanded: true,
                  value: simOperationList[value.simTypeIndex],
                  items: simOperationList.map((e) {
                    return ComboBoxItem(
                      child: Text(e),
                      value: e,
                    );
                  }).toList(),
                  onChanged: (device) {
                    value.simTypeIndex = simOperationList.indexOf(device ?? '');
                  });
            }),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Checkbox(
                  checked: true,
                  onChanged: (value) {},
                  content: Text("是否循环执行"),
                ),
                Checkbox(
                  checked: true,
                  onChanged: (value) {},
                  content: Text("是否随机间隔"),
                )
              ],
            )
          ],
        ));
  }
}
