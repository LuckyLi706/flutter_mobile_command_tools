import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/enum/sim_operation_type.dart';
import 'package:flutter_mobile_command_tools/model/sim_operation_model.dart';
import 'package:flutter_mobile_command_tools/notifier/dialog/android_sim_script_notifier.dart';
import 'package:flutter_mobile_command_tools/utils/toast_utils.dart';
import 'package:provider/provider.dart';

class AndroidSimScriptDialog extends StatefulWidget {
  AndroidSimScriptDialog(Key? key) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AndroidSimScriptDialogState();
  }
}

class AndroidSimScriptDialogState extends State<AndroidSimScriptDialog> {
  final SimOperationModel simOperationModel = new SimOperationModel();
  late SimOperation simOperation;
  late String aliasName = '';
  late String fileName = '';

  @override
  void initState() {
    super.initState();
    simOperation = new SimOperation();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AndroidSimScriptNotifier>(
        create: (_) => AndroidSimScriptNotifier(),
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<AndroidSimScriptNotifier>(
                  builder: (context, value, child) {
                return ComboBox<SimOperationType>(
                    isExpanded: true,
                    value: value.simOperationType,
                    items: SimOperationType.values.map((e) {
                      return ComboBoxItem(
                        child: Text(e.value),
                        value: e,
                      );
                    }).toList(),
                    onChanged: (type) {
                      simOperation = new SimOperation();
                      value.simOperationType = type ?? SimOperationType.SWIPE;
                    });
              }),
              SizedBox(
                height: 10,
              ),
              Consumer<AndroidSimScriptNotifier>(
                  builder: (context, value, child) {
                if (value.simOperationType == SimOperationType.SWIPE) {
                  return SwipeWidget(
                    simOperation: simOperation,
                  );
                } else if (value.simOperationType == SimOperationType.TEXT) {
                  return TextWidget(
                    simOperation: simOperation,
                  );
                } else if (value.simOperationType == SimOperationType.TAP) {
                  return TapWidget(
                    simOperation: simOperation,
                  );
                } else if (value.simOperationType == SimOperationType.EVENT) {
                  return EventWidget(
                    simOperation: simOperation,
                  );
                } else if (value.simOperationType == SimOperationType.ADB) {
                  return AdbWidget(
                    simOperation: simOperation,
                  );
                } else if (value.simOperationType == SimOperationType.OTHER) {
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
              Row(
                children: [
                  Expanded(
                      child: TextBox(
                    placeholder: '指令别名',
                    onChanged: (value) {
                      aliasName = value;
                    },
                  )),
                  SizedBox(
                    width: 5,
                  ),
                  Button(
                      child: Text('添加到指令列表'),
                      onPressed: () {
                        if (context
                                .read<AndroidSimScriptNotifier>()
                                .simOperationType ==
                            SimOperationType.SWIPE) {
                          if (context
                                  .read<AndroidSimScriptNotifier>()
                                  .swipeType ==
                              SwipeType.SWIPE_CUSTOM) {
                            if (simOperation.x1 == 0) {
                              showToast(
                                  message: '滑动类型起点的x轴不能为空或者不是数字类型',
                                  title: '添加到指令列表');
                              return;
                            }
                            if (simOperation.y1 == 0) {
                              showToast(
                                  message: '滑动类型起点的y轴不能为空或者不是数字类型',
                                  title: '添加到指令列表');
                              return;
                            }
                            if (simOperation.x2 == 0) {
                              showToast(
                                  message: '滑动类型终点的x轴不能为空或者不是数字类型',
                                  title: '添加到指令列表');
                              return;
                            }
                            if (simOperation.y2 == 0) {
                              showToast(
                                  message: '滑动类型终点的y轴不能为空或者不是数字类型',
                                  title: '添加到指令列表');
                              return;
                            }
                          }
                        }

                        if (aliasName.isEmpty) {
                          showToast(message: '别名不能为空', title: '添加到指令列表');
                          return;
                        }

                        bool isExistAlias = false;
                        simOperationModel.simOperationList.forEach((value) {
                          if (value.aliasName == aliasName) {
                            isExistAlias = true;
                          }
                        });

                        if (isExistAlias) {
                          showToast(message: '别名不能相同', title: '添加到指令列表');
                          return;
                        }

                        simOperation.aliasName = aliasName;
                        simOperationModel.simOperationList.add(simOperation);
                        context
                                .read<AndroidSimScriptNotifier>()
                                .simOperationList =
                            simOperationModel.simOperationList;
                      }),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Consumer<AndroidSimScriptNotifier>(builder: (
                context,
                model,
                child,
              ) {
                return Row(
                  children: [
                    Expanded(
                        child: ComboBox<String>(
                            isExpanded: true,
                            value: model.simOperationList.length > 0
                                ? model
                                    .simOperationList[model.simOperationIndex]
                                    .aliasName
                                : '',
                            items: model.simOperationList.map((e) {
                              return ComboBoxItem(
                                child: Text(e.aliasName),
                                value: e.aliasName,
                              );
                            }).toList(),
                            placeholder: Text('指令列表'),
                            onChanged: (device) {})),
                    SizedBox(
                      width: 5,
                    ),
                    Button(
                        child: Text('编辑指令'),
                        onPressed: () {
                          simOperationModel.simOperationList.add(simOperation);
                        }),
                    SizedBox(
                      width: 5,
                    ),
                    Button(
                        child: Text('删除指令'),
                        onPressed: () {
                          simOperationModel.simOperationList.removeAt(context
                              .read<AndroidSimScriptNotifier>()
                              .simOperationIndex);
                          context
                                  .read<AndroidSimScriptNotifier>()
                                  .simOperationList =
                              simOperationModel.simOperationList;
                        }),
                  ],
                );
              }),
              SizedBox(
                height: 10,
              ),
              Consumer<AndroidSimScriptNotifier>(
                  builder: (context, model, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: "是否为单条指令，默认一个文件包含多条指令时候，将会执行文件中的所有指令",
                      child: Checkbox(
                        checked: model.isSingle,
                        onChanged: (value) {
                          model.isSingle = value ?? false;
                        },
                        content: Text("是否单条"),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Tooltip(
                          message: "可以自定义文件名，不选择默认使用当前时间保存",
                          child: Checkbox(
                            checked: model.isCustomFileName,
                            onChanged: (value) {
                              model.isCustomFileName = value ?? false;
                            },
                            content: Text("自定义文件名"),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: TextBox(
                          enabled: model.isCustomFileName,
                          onChanged: (value) {
                            fileName = value;
                          },
                        ))
                      ],
                    )
                  ],
                );
              }),
            ],
          );
        });
  }
}

class SwipeWidget extends StatelessWidget {
  final SimOperation simOperation;

  SwipeWidget({Key? key, required this.simOperation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Tooltip(
              message: "自定义滑动",
              child: Checkbox(
                checked: context.watch<AndroidSimScriptNotifier>().swipeType ==
                    SwipeType.SWIPE_CUSTOM,
                onChanged: (value) {
                  if (value!) {
                    context.read<AndroidSimScriptNotifier>().swipeType =
                        SwipeType.SWIPE_CUSTOM;
                    simOperation.swipeType = SwipeType.SWIPE_CUSTOM;
                  }
                },
                content: Text("自定义"),
              ),
            ),
            Tooltip(
              message: "上滑",
              child: Checkbox(
                checked: context.watch<AndroidSimScriptNotifier>().swipeType ==
                    SwipeType.SWIPE_TOP,
                onChanged: (value) {
                  if (value!) {
                    context.read<AndroidSimScriptNotifier>().swipeType =
                        SwipeType.SWIPE_TOP;
                    simOperation.swipeType = SwipeType.SWIPE_TOP;
                  }
                },
                content: Text("上滑"),
              ),
            ),
            Tooltip(
              message: "下滑",
              child: Checkbox(
                checked: context.watch<AndroidSimScriptNotifier>().swipeType ==
                    SwipeType.SWIPE_BOTTOM,
                onChanged: (value) {
                  if (value!) {
                    context.read<AndroidSimScriptNotifier>().swipeType =
                        SwipeType.SWIPE_BOTTOM;
                    simOperation.swipeType = SwipeType.SWIPE_BOTTOM;
                  }
                },
                content: Text("下滑"),
              ),
            ),
            Tooltip(
              message: "左滑",
              child: Checkbox(
                checked: context.watch<AndroidSimScriptNotifier>().swipeType ==
                    SwipeType.SWIPE_LEFT,
                onChanged: (value) {
                  if (value!) {
                    context.read<AndroidSimScriptNotifier>().swipeType =
                        SwipeType.SWIPE_LEFT;
                    simOperation.swipeType = SwipeType.SWIPE_LEFT;
                  }
                },
                content: Text("左滑"),
              ),
            ),
            Tooltip(
              message: "右滑",
              child: Checkbox(
                checked: context.watch<AndroidSimScriptNotifier>().swipeType ==
                    SwipeType.SWIPE_RIGHT,
                onChanged: (value) {
                  if (value!) {
                    context.read<AndroidSimScriptNotifier>().swipeType =
                        SwipeType.SWIPE_RIGHT;
                    simOperation.swipeType = SwipeType.SWIPE_RIGHT;
                  }
                },
                content: Text("右滑"),
              ),
            ),
          ],
        ),
        Visibility(
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextBox(
                    onChanged: (value) {
                      try {
                        simOperation.simOperationType = SimOperationType.SWIPE;
                        simOperation.x1 = int.parse(value);
                      } catch (e) {
                        simOperation.x1 = 0;
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
                        simOperation.y1 = 0;
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
                        simOperation.x2 = 0;
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
                        simOperation.y2 = 0;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          visible: context.watch<AndroidSimScriptNotifier>().swipeType ==
              SwipeType.SWIPE_CUSTOM,
        )
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
