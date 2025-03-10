import 'package:fluent_ui/fluent_ui.dart';

class AndroidSimScriptDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AndroidSimScriptDialogState();
  }
}

class _AndroidSimScriptDialogState extends State<AndroidSimScriptDialog> {
  final simOperationList = ["swipe", "text", "tap", "event", "adb", "other"];
  var simOperationIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ComboBox<String>(
            isExpanded: true,
            value: simOperationList[simOperationIndex],
            items: simOperationList.map((e) {
              return ComboBoxItem(
                child: Text(e),
                value: e,
              );
            }).toList(),
            onChanged: (device) {
              simOperationIndex = simOperationList.indexOf(device ?? '');
              setState(() {});
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
    );
  }
}
