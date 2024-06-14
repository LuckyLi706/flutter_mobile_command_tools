import 'package:flutter/material.dart';
import 'package:flutter_mobile_command_tools/base/base_state_page.dart';
import 'package:flutter_mobile_command_tools/constants.dart';
import 'package:flutter_mobile_command_tools/generated/l10n.dart';
import 'package:flutter_mobile_command_tools/pages/main/main_controller.dart';
import 'package:flutter_mobile_command_tools/pages/main/widgets/log_info_widget.dart';
import 'package:flutter_mobile_command_tools/route/route_helper.dart';

import '../../main.dart';

/// @description: 主页面
/// @time 2024/5/23 14:06
/// @author lijie
/// @email jackyli706@gmail.com
class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState
    extends BaseStatePageWithController<MainPage, MainController> {
  @override
  Widget buildMainWidget() {
    return Row(
      children: [
        Expanded(
            child: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
              controller: controller?.mainScrollController,
              scrollDirection: Axis.vertical,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '基本操作',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '一些基本操作',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                            child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Checkbox(
                                          value: Constants.isRoot,
                                          onChanged: (isCheck) {}),
                                      Text("开启Root")
                                    ])),
                                Expanded(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Checkbox(
                                          value: Constants.isInnerAdb,
                                          onChanged: (isCheck) async {}),
                                      Text("内置ADB")
                                    ])),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: new TextButton(
                                        onPressed: () {},
                                        child: new Text("获取设备"))),
                                Expanded(
                                    child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: Constants.currentDevice,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      Constants.currentDevice =
                                          newValue == null ? "" : newValue;
                                    });
                                  },
                                  items: connectDeviceDdmi,
                                )),
                              ],
                            ),
                          ],
                        ))
                      ],
                    ),
                  ])),
        )),
        Expanded(
            child: Container(
          padding: EdgeInsets.all(20),
          child: LogInfoWidget(
            mainController: controller!,
          ),
        )),
      ],
    );
  }

  @override
  Widget? barRightWidget() {
    return IconButton(
        tooltip: S.of(context).setting,
        onPressed: () {
          RouteHelper.getInstance().pushName(RouteHelper.settingPage);
        },
        icon: Icon(
          Icons.settings,
          color: Colors.white.withOpacity(0.9),
        ));
  }

  @override
  Widget? barLeftWidget() {
    return Container();
  }

  @override
  MainController buildController() {
    return MainController();
  }
}
