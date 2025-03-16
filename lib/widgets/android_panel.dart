import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/enum/click_type.dart';
import 'package:flutter_mobile_command_tools/mixin/android_panel_mixin.dart';
import 'package:flutter_mobile_command_tools/mixin/main_mixin.dart';
import 'package:flutter_mobile_command_tools/model/sim_operation_model.dart';
import 'package:flutter_mobile_command_tools/notifier/panel/android_panel_notifier.dart';
import 'package:flutter_mobile_command_tools/utils/file_utils.dart';
import 'package:flutter_mobile_command_tools/utils/notifier_utils.dart';
import 'package:provider/provider.dart';

import '../../utils/command_utils.dart';
import '../global.dart';
import 'android_log_widget.dart';

class AndroidPanel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _AndroidPanelState();
  }
}

class _AndroidPanelState extends State<AndroidPanel>
    with AutomaticKeepAliveClientMixin, AndroidPanelMixin {
  late Map<String, SimOperationModel> mapSimOperations = {};

  @override
  void initState() {
    super.initState();

    /// 首次去获取一下设备列表
    Future.delayed(Duration(milliseconds: 1000),
        () => {AndroidCommandUtils.sendConnectDeviceOrder()});

    FileUtils.readSimOperationFile().then((mapSimOperation) {
      if (mapSimOperation.isNotEmpty) {
        mapSimOperations = mapSimOperation;
        List<String> simOperationsKey = mapSimOperation.keys.toList();
        Provider.of<AndroidPanelNotifier>(Global.navigatorKey.currentContext!,
                listen: false)
            .simOperationKeyList = simOperationsKey;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      children: [
        Container(
            padding: EdgeInsets.all(10),
            width: 300,
            child: Column(
              children: [
                Expander(
                  initiallyExpanded: true,
                  header: Text(
                    '设备',
                  ),
                  content: Tooltip(
                    message: '我的设备',
                    child: ComboBox<String>(
                        isExpanded: true,
                        placeholder: Text('我的设备'),
                        value: context
                                    .watch<AndroidPanelNotifier>()
                                    .deviceList
                                    .length >
                                0
                            ? context.watch<AndroidPanelNotifier>().deviceList[
                                context
                                    .watch<AndroidPanelNotifier>()
                                    .deviceIndex]
                            : "",
                        items: context
                            .watch<AndroidPanelNotifier>()
                            .deviceList
                            .map((e) {
                          return ComboBoxItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (device) {
                          context.read<AndroidPanelNotifier>().deviceIndex =
                              context
                                  .read<AndroidPanelNotifier>()
                                  .deviceList
                                  .indexOf(device ?? '');
                        }),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expander(
                  header: Text('模拟操作'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: '我的脚本',
                        child: ComboBox<String>(
                            isExpanded: true,
                            placeholder: Text('我的脚本'),
                            value: context
                                        .watch<AndroidPanelNotifier>()
                                        .simOperationKeyList
                                        .length >
                                    0
                                ? context
                                        .watch<AndroidPanelNotifier>()
                                        .simOperationKeyList[
                                    context
                                        .watch<AndroidPanelNotifier>()
                                        .simOperationKeyIndex]
                                : "",
                            items: context
                                .watch<AndroidPanelNotifier>()
                                .simOperationKeyList
                                .map((e) {
                              return ComboBoxItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (device) {
                              context
                                      .read<AndroidPanelNotifier>()
                                      .simOperationKeyIndex =
                                  context
                                      .read<AndroidPanelNotifier>()
                                      .simOperationKeyList
                                      .indexOf(device ?? '');
                            }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Tooltip(
                        message: "是否重复执行",
                        child: Checkbox(
                          checked: true,
                          onChanged: (value) {
                            NotifierUtils.getAndroidPanelNotifier().isRepeat =
                                value ?? true;
                          },
                          content: Text("循环执行"),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Tooltip(
                        child: Checkbox(
                          checked: true,
                          onChanged: (value) {},
                          content: Text(
                            "随机间隔",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        message: "是否间隔时间随机，默认每条指令之间间隔1000毫秒",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextBox(
                              controller: TextEditingController(
                                  text: NotifierUtils.getAndroidPanelNotifier()
                                      .randomPeriod
                                      .split(',')[0]),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: TextBox(
                            onChanged: (value) {},
                            controller: TextEditingController(
                                text: NotifierUtils.getAndroidPanelNotifier()
                                    .randomPeriod
                                    .split(',')[1]),
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Button(
                            child: const Text('开始执行'),
                            onPressed: () => {
                              onClick(AndroidPanelClickType.SIM_OPERATION_START,
                                  params: mapSimOperations[context
                                          .read<AndroidPanelNotifier>()
                                          .simOperationKeyList[
                                      context
                                          .read<AndroidPanelNotifier>()
                                          .simOperationKeyIndex]])
                            },
                          ),
                          Button(
                            child: const Text('停止执行'),
                            onPressed: () => {},
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expander(
                  header: Text('应用管理'),
                  content: Column(
                    children: [
                      Tooltip(
                        message: '应用列表',
                        child: ComboBox<String>(
                            isExpanded: true,
                            placeholder: Text('应用列表'),
                            value: context
                                        .watch<AndroidPanelNotifier>()
                                        .packageList
                                        .length >
                                    0
                                ? context
                                        .watch<AndroidPanelNotifier>()
                                        .packageList[
                                    context
                                        .watch<AndroidPanelNotifier>()
                                        .packageIndex]
                                : "",
                            items: context
                                .watch<AndroidPanelNotifier>()
                                .simOperationKeyList
                                .map((e) {
                              return ComboBoxItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (device) {
                              context
                                      .read<AndroidPanelNotifier>()
                                      .packageIndex =
                                  context
                                      .read<AndroidPanelNotifier>()
                                      .packageList
                                      .indexOf(device ?? '');
                            }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Button(
                            child: const Text('获取当前包名'),
                            onPressed: () => {},
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Tooltip(
                            child: Button(
                              child: const Text('三方应用'),
                              onPressed: () => {},
                            ),
                            message: "获取应用级别的应用列表",
                          ),
                          Tooltip(
                            child: Button(
                              child: const Text('系统应用'),
                              onPressed: () => {},
                            ),
                            message: "获取系统级别的应用列表",
                          ),
                          Tooltip(
                            child: Button(
                              child: const Text('冷冻应用'),
                              onPressed: () => {},
                            ),
                            message: "获取被冷冻的应用列表",
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Tooltip(
                            child: Button(
                              child: const Text('隐藏应用'),
                              onPressed: () => {},
                            ),
                            message: "冻结应用列表当前选中的应用,此操作会让app在手机桌面消失",
                          ),
                          Tooltip(
                            child: Button(
                              child: const Text('展示应用'),
                              onPressed: () => {},
                            ),
                            message: "解除冷冻应用列表当前选中的应用,此操作会让app在手机桌面展示",
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            )),
        Divider(
          direction: Axis.vertical,
          size: 1,
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.all(10),
          child: AndroidLogWidget(),
        ))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
