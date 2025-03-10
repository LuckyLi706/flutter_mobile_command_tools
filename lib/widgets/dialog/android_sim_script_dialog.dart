import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/enum/sim_operation_type.dart';
import 'package:flutter_mobile_command_tools/model/sim_operation_model.dart';
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
  final SimOperationModel simOperationModel = new SimOperationModel();
  late SimOperation simOperation;

  @override
  void initState() {
    super.initState();
    simOperation = new SimOperation();
  }

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
                    simOperation = new SimOperation();
                    value.simTypeIndex = simOperationList.indexOf(device ?? '');
                  });
            }),
            SizedBox(
              height: 10,
            ),
            Consumer<AndroidSimScriptNotifier>(
                builder: (context, value, child) {
              if (value.simTypeIndex == 0) {
                return SwipeWidget(
                  simOperation: simOperation,
                );
              } else if (value.simTypeIndex == 1) {
                return TextWidget(
                  simOperation: simOperation,
                );
              } else if (value.simTypeIndex == 2) {
                return TapWidget(
                  simOperation: simOperation,
                );
              } else if (value.simTypeIndex == 3) {
                return EventWidget(
                  simOperation: simOperation,
                );
              } else if (value.simTypeIndex == 4) {
                return AdbWidget(
                  simOperation: simOperation,
                );
              } else if (value.simTypeIndex == 5) {
                return OtherWidget(
                  simOperation: simOperation,
                );
              }
              return TapWidget(
                simOperation: simOperation,
              );
            }),
            SizedBox(
              height: 10,
            ),
            Consumer<AndroidSimScriptNotifier>(
                builder: (context, model, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Tooltip(
                    message: "是否重复执行",
                    child: Checkbox(
                      checked: model.isRepeat,
                      onChanged: (value) {
                        model.isRepeat = value ?? false;
                      },
                      content: Text("循环执行"),
                    ),
                  ),
                  Tooltip(
                    child: Checkbox(
                      checked: model.isRandom,
                      onChanged: (value) {
                        model.isRandom = value ?? false;
                      },
                      content: Text("随机间隔"),
                    ),
                    message: "是否间隔时间随机，默认每条指令之间间隔1000毫秒",
                  ),
                  Tooltip(
                    message: "是否为单条指令，默认一个文件包含多条指令时候，将会执行文件中的所有指令",
                    child: Checkbox(
                      checked: model.isSingle,
                      onChanged: (value) {
                        model.isSingle = value ?? false;
                      },
                      content: Text("是否单条"),
                    ),
                  )
                ],
              );
            }),
            Button(
                child: Text('添加'),
                onPressed: () {
                  simOperationModel.simOperationList.add(simOperation);
                })
          ],
        ));
  }
}

class SwipeWidget extends StatelessWidget {
  final SimOperation simOperation;

  SwipeWidget({Key? key, required this.simOperation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextBox(
            onChanged: (value) {
              try {
                simOperation.simOperationType = SimOperationType.SWIPE;
                simOperation.x1 = int.parse(value);
              } catch (e) {
                simOperation.x1 = -1;
              }
            },
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: TextBox(
            onChanged: (value) {
              try {
                simOperation.simOperationType = SimOperationType.SWIPE;
                simOperation.y1 = int.parse(value);
              } catch (e) {
                simOperation.y1 = -1;
              }
            },
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: TextBox(
            onChanged: (value) {
              try {
                simOperation.simOperationType = SimOperationType.SWIPE;
                simOperation.x2 = int.parse(value);
              } catch (e) {
                simOperation.x2 = -1;
              }
            },
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: TextBox(
            onChanged: (value) {
              try {
                simOperation.simOperationType = SimOperationType.SWIPE;
                simOperation.y2 = int.parse(value);
              } catch (e) {
                simOperation.y2 = -1;
              }
            },
          ),
        ),
      ],
    );
  }
}

class TextWidget extends StatelessWidget {
  final SimOperation simOperation;

  TextWidget({Key? key, required this.simOperation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextBox();
  }
}

class TapWidget extends StatelessWidget {
  final SimOperation simOperation;

  TapWidget({Key? key, required this.simOperation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextBox(
            onChanged: (value) {
              try {
                simOperation.simOperationType = SimOperationType.TAP;
                simOperation.x1 = int.parse(value);
              } catch (e) {
                simOperation.x1 = -1;
              }
            },
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: TextBox(
            onChanged: (value) {
              try {
                simOperation.simOperationType = SimOperationType.TAP;
                simOperation.y1 = int.parse(value);
              } catch (e) {
                simOperation.y1 = -1;
              }
            },
          ),
        )
      ],
    );
  }
}

class EventWidget extends StatelessWidget {
  final SimOperation simOperation;

  EventWidget({Key? key, required this.simOperation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextBox(
      onChanged: (value) {
        simOperation.simOperationType = SimOperationType.EVENT;
        simOperation.text = value;
      },
    );
  }
}

class AdbWidget extends StatelessWidget {
  final SimOperation simOperation;

  AdbWidget({Key? key, required this.simOperation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextBox(
      onChanged: (value) {
        simOperation.simOperationType = SimOperationType.ADB;
        simOperation.text = value;
      },
    );
  }
}

class OtherWidget extends StatelessWidget {
  final SimOperation simOperation;

  OtherWidget({Key? key, required this.simOperation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextBox(
      onChanged: (value) {
        simOperation.simOperationType = SimOperationType.OTHER;
        simOperation.text = value;
      },
    );
  }
}
