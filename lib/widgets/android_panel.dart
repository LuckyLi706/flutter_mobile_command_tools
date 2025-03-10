import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobile_command_tools/enum/adb_command_type.dart';
import 'package:flutter_mobile_command_tools/notifier/panel/android_panel_notifier.dart';
import 'package:provider/provider.dart';

import '../../global.dart';
import '../../utils/command_utils.dart';
import 'android_log_widget.dart';

class AndroidPanel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _AndroidPanelState();
  }
}

class _AndroidPanelState extends State<AndroidPanel>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();

    /// 首次去获取一下设备列表
    Future.delayed(Duration(milliseconds: 1000),
        () => {AndroidCommandUtils.sendConnectDeviceOrder()});
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
                  content: Tooltip(
                    message: '我的脚本',
                    child: ComboBox<String>(
                        isExpanded: true,
                        placeholder: Text('我的脚本'),
                        value: context
                                    .watch<AndroidPanelNotifier>()
                                    .scriptList
                                    .length >
                                0
                            ? context.watch<AndroidPanelNotifier>().scriptList[
                                context
                                    .watch<AndroidPanelNotifier>()
                                    .scriptIndex]
                            : "",
                        items: context
                            .watch<AndroidPanelNotifier>()
                            .scriptList
                            .map((e) {
                          return ComboBoxItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (device) {
                          context.read<AndroidPanelNotifier>().scriptIndex =
                              context
                                  .read<AndroidPanelNotifier>()
                                  .scriptList
                                  .indexOf(device ?? '');
                        }),
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
                                .scriptList
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
